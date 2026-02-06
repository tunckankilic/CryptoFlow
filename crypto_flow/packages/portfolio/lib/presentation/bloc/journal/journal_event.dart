import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/journal_entry.dart';
import '../../../domain/entities/trade_side.dart';
import 'journal_filter.dart';
import 'journal_sort.dart';

/// Base class for all journal events
abstract class JournalEvent extends Equatable {
  const JournalEvent();

  @override
  List<Object?> get props => [];
}

/// Load journal entries with optional filters
class JournalEntriesRequested extends JournalEvent {
  final String? symbol;
  final TradeSide? side;
  final DateTimeRange? range;

  const JournalEntriesRequested({
    this.symbol,
    this.side,
    this.range,
  });

  @override
  List<Object?> get props => [symbol, side, range];
}

/// Add a new journal entry
class JournalEntryAdded extends JournalEvent {
  final JournalEntry entry;

  const JournalEntryAdded(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// Update an existing journal entry
class JournalEntryUpdated extends JournalEvent {
  final JournalEntry entry;

  const JournalEntryUpdated(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// Delete a journal entry by ID
class JournalEntryDeleted extends JournalEvent {
  final int id;

  const JournalEntryDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

/// Search journal entries by query
class JournalSearched extends JournalEvent {
  final String query;

  const JournalSearched(this.query);

  @override
  List<Object?> get props => [query];
}

/// Change the active filter
class JournalFilterChanged extends JournalEvent {
  final JournalFilter filter;

  const JournalFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Change the sort order
class JournalSortChanged extends JournalEvent {
  final JournalSort sort;

  const JournalSortChanged(this.sort);

  @override
  List<Object?> get props => [sort];
}

/// Internal event when entries are updated from database stream
class JournalEntriesUpdated extends JournalEvent {
  const JournalEntriesUpdated();
}
