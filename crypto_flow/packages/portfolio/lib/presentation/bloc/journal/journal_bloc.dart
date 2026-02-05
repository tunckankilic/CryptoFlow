import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/journal_entry.dart';
import '../../../domain/repositories/journal_repository.dart';
import '../../../domain/usecases/add_journal_entry.dart';
import '../../../domain/usecases/delete_journal_entry.dart';
import '../../../domain/usecases/get_journal_entries.dart';
import '../../../domain/usecases/update_journal_entry.dart';
import 'journal_event.dart';
import 'journal_filter.dart';
import 'journal_sort.dart';
import 'journal_state.dart';

/// BLoC for managing journal entries
class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final GetJournalEntries getJournalEntries;
  final AddJournalEntry addJournalEntry;
  final UpdateJournalEntry updateJournalEntry;
  final DeleteJournalEntry deleteJournalEntry;
  final JournalRepository repository;

  StreamSubscription? _entriesSubscription;
  JournalFilter _currentFilter = const JournalFilter.empty();
  JournalSort _currentSort = JournalSort.dateDesc;

  JournalBloc({
    required this.getJournalEntries,
    required this.addJournalEntry,
    required this.updateJournalEntry,
    required this.deleteJournalEntry,
    required this.repository,
  }) : super(const JournalInitial()) {
    on<JournalEntriesRequested>(_onEntriesRequested);
    on<JournalEntryAdded>(_onEntryAdded);
    on<JournalEntryUpdated>(_onEntryUpdated);
    on<JournalEntryDeleted>(_onEntryDeleted);
    on<JournalSearched>(_onSearched);
    on<JournalFilterChanged>(_onFilterChanged);
    on<JournalSortChanged>(_onSortChanged);
    on<JournalEntriesUpdated>(_onEntriesUpdated);

    // Start watching for database changes
    _watchEntries();
  }

  /// Load journal entries with optional filters
  Future<void> _onEntriesRequested(
    JournalEntriesRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(const JournalLoading());

    final result = await getJournalEntries(
      GetJournalEntriesParams(
        symbol: event.symbol,
        side: event.side,
        range: event.range,
      ),
    );

    result.fold(
      (failure) => emit(JournalError(failure.message)),
      (entries) {
        final sortedEntries = _sortEntries(entries, _currentSort);
        emit(JournalLoaded(
          entries: sortedEntries,
          filter: _currentFilter,
          sort: _currentSort,
          totalCount: entries.length,
        ));
      },
    );
  }

  /// Add a new journal entry
  Future<void> _onEntryAdded(
    JournalEntryAdded event,
    Emitter<JournalState> emit,
  ) async {
    final result = await addJournalEntry(
      AddJournalEntryParams(entry: event.entry),
    );

    result.fold(
      (failure) => emit(JournalError(failure.message)),
      (_) {
        emit(const JournalEntrySuccess('Entry added successfully'));
        // Reload entries
        add(const JournalEntriesRequested());
      },
    );
  }

  /// Update an existing journal entry
  Future<void> _onEntryUpdated(
    JournalEntryUpdated event,
    Emitter<JournalState> emit,
  ) async {
    final result = await updateJournalEntry(
      UpdateJournalEntryParams(entry: event.entry),
    );

    result.fold(
      (failure) => emit(JournalError(failure.message)),
      (_) {
        emit(const JournalEntrySuccess('Entry updated successfully'));
        // Reload entries
        add(const JournalEntriesRequested());
      },
    );
  }

  /// Delete a journal entry
  Future<void> _onEntryDeleted(
    JournalEntryDeleted event,
    Emitter<JournalState> emit,
  ) async {
    final result = await deleteJournalEntry(
      DeleteJournalEntryParams(id: event.id),
    );

    result.fold(
      (failure) => emit(JournalError(failure.message)),
      (_) {
        emit(const JournalEntrySuccess('Entry deleted successfully'));
        // Reload entries
        add(const JournalEntriesRequested());
      },
    );
  }

  /// Search journal entries
  Future<void> _onSearched(
    JournalSearched event,
    Emitter<JournalState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const JournalEntriesRequested());
      return;
    }

    emit(const JournalLoading());

    final result = await repository.searchEntries(event.query);

    result.fold(
      (failure) => emit(JournalError(failure.message)),
      (entries) {
        final sortedEntries = _sortEntries(entries, _currentSort);
        emit(JournalLoaded(
          entries: sortedEntries,
          filter: _currentFilter,
          sort: _currentSort,
          totalCount: entries.length,
        ));
      },
    );
  }

  /// Change active filter
  Future<void> _onFilterChanged(
    JournalFilterChanged event,
    Emitter<JournalState> emit,
  ) async {
    _currentFilter = event.filter;
    emit(const JournalLoading());

    final result = await getJournalEntries(
      GetJournalEntriesParams(
        symbol: event.filter.symbol,
        side: event.filter.side,
        range: event.filter.dateRange,
      ),
    );

    result.fold(
      (failure) => emit(JournalError(failure.message)),
      (entries) {
        // Apply additional client-side filters
        var filteredEntries = entries;

        if (event.filter.emotion != null) {
          filteredEntries = filteredEntries
              .where((e) => e.emotion == event.filter.emotion)
              .toList();
        }

        if (event.filter.tags.isNotEmpty) {
          filteredEntries = filteredEntries
              .where(
                  (e) => e.tags.any((tag) => event.filter.tags.contains(tag)))
              .toList();
        }

        if (event.filter.onlyWins) {
          filteredEntries =
              filteredEntries.where((e) => (e.pnl ?? 0) > 0).toList();
        }

        if (event.filter.onlyLosses) {
          filteredEntries =
              filteredEntries.where((e) => (e.pnl ?? 0) < 0).toList();
        }

        final sortedEntries = _sortEntries(filteredEntries, _currentSort);
        emit(JournalLoaded(
          entries: sortedEntries,
          filter: _currentFilter,
          sort: _currentSort,
          totalCount: filteredEntries.length,
        ));
      },
    );
  }

  /// Change sort order
  Future<void> _onSortChanged(
    JournalSortChanged event,
    Emitter<JournalState> emit,
  ) async {
    _currentSort = event.sort;

    if (state is JournalLoaded) {
      final currentState = state as JournalLoaded;
      final sortedEntries = _sortEntries(currentState.entries, event.sort);
      emit(currentState.copyWith(
        entries: sortedEntries,
        sort: event.sort,
      ));
    }
  }

  /// Handle entries updated from stream
  Future<void> _onEntriesUpdated(
    JournalEntriesUpdated event,
    Emitter<JournalState> emit,
  ) async {
    // Reload entries when database changes
    add(const JournalEntriesRequested());
  }

  /// Watch for database changes
  void _watchEntries() {
    _entriesSubscription = repository.watchEntries().listen(
      (_) {
        add(const JournalEntriesUpdated());
      },
    );
  }

  /// Sort entries based on sort option
  List<JournalEntry> _sortEntries(
      List<JournalEntry> entries, JournalSort sort) {
    final sortedList = List<JournalEntry>.from(entries);

    switch (sort) {
      case JournalSort.dateDesc:
        sortedList.sort((a, b) => b.entryDate.compareTo(a.entryDate));
        break;
      case JournalSort.dateAsc:
        sortedList.sort((a, b) => a.entryDate.compareTo(b.entryDate));
        break;
      case JournalSort.pnlDesc:
        sortedList.sort((a, b) => (b.pnl ?? 0).compareTo(a.pnl ?? 0));
        break;
      case JournalSort.pnlAsc:
        sortedList.sort((a, b) => (a.pnl ?? 0).compareTo(b.pnl ?? 0));
        break;
      case JournalSort.rrDesc:
        sortedList.sort((a, b) =>
            (b.riskRewardRatio ?? 0).compareTo(a.riskRewardRatio ?? 0));
        break;
    }

    return sortedList;
  }

  @override
  Future<void> close() {
    _entriesSubscription?.cancel();
    return super.close();
  }
}
