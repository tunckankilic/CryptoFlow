import 'package:equatable/equatable.dart';
import '../../../domain/entities/journal_entry.dart';
import 'journal_filter.dart';
import 'journal_sort.dart';

/// Base class for all journal states
abstract class JournalState extends Equatable {
  const JournalState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class JournalInitial extends JournalState {
  const JournalInitial();
}

/// Loading journal data
class JournalLoading extends JournalState {
  const JournalLoading();
}

/// Journal data loaded successfully
class JournalLoaded extends JournalState {
  final List<JournalEntry> entries;
  final JournalFilter filter;
  final JournalSort sort;
  final int totalCount;

  const JournalLoaded({
    required this.entries,
    required this.filter,
    required this.sort,
    required this.totalCount,
  });

  /// Create a copy with updated fields
  JournalLoaded copyWith({
    List<JournalEntry>? entries,
    JournalFilter? filter,
    JournalSort? sort,
    int? totalCount,
  }) {
    return JournalLoaded(
      entries: entries ?? this.entries,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  List<Object?> get props => [entries, filter, sort, totalCount];
}

/// CRUD operation completed successfully
class JournalEntrySuccess extends JournalState {
  final String message;

  const JournalEntrySuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error loading or managing journal
class JournalError extends JournalState {
  final String message;

  const JournalError(this.message);

  @override
  List<Object?> get props => [message];
}
