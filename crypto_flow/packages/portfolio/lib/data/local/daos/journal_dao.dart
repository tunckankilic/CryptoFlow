import 'package:drift/drift.dart';
import 'package:flutter/material.dart' as flutter;

import '../../datasources/portfolio_database.dart';
import '../../models/journal_entry_model.dart';
import '../../../domain/entities/trade_side.dart';
import '../../../domain/entities/trade_emotion.dart';

/// Data Access Object for Journal Entries
/// Provides comprehensive CRUD operations and statistical queries
class JournalDao {
  final PortfolioDatabase _db;

  JournalDao(this._db);

  // ==================== Basic CRUD Operations ====================

  /// Get all journal entries with optional filters
  Future<List<JournalEntryModel>> getAllEntries({
    String? symbol,
    TradeSide? side,
    flutter.DateTimeRange? range,
  }) async {
    var query = _db.select(_db.journalEntries);

    if (symbol != null) {
      query = query..where((e) => e.symbol.equals(symbol));
    }

    if (side != null) {
      query = query..where((e) => e.side.equals(side.toJson()));
    }

    if (range != null) {
      query = query
        ..where((e) => e.entryDate.isBiggerOrEqualValue(range.start))
        ..where((e) => e.entryDate.isSmallerOrEqualValue(range.end));
    }

    query = query
      ..orderBy([
        (e) => OrderingTerm(expression: e.entryDate, mode: OrderingMode.desc)
      ]);

    final results = await query.get();
    return results.map((e) => JournalEntryModel.fromDrift(e)).toList();
  }

  /// Get a single journal entry by ID
  Future<JournalEntryModel?> getEntryById(int id) async {
    final result = await (_db.select(_db.journalEntries)
          ..where((e) => e.id.equals(id)))
        .getSingleOrNull();

    return result != null ? JournalEntryModel.fromDrift(result) : null;
  }

  /// Get journal entries that contain the specified tag
  Future<List<JournalEntryModel>> getEntriesByTag(String tag) async {
    final results = await (_db.select(_db.journalEntries)
          ..where((e) => e.tags.contains(tag))
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.entryDate, mode: OrderingMode.desc)
          ]))
        .get();

    return results.map((e) => JournalEntryModel.fromDrift(e)).toList();
  }

  /// Insert a new journal entry
  Future<int> insertEntry(JournalEntryModel entry) async {
    return await _db.into(_db.journalEntries).insert(entry.toDrift());
  }

  /// Update an existing journal entry
  Future<bool> updateEntry(JournalEntryModel entry) async {
    return await _db.update(_db.journalEntries).replace(entry.toDrift());
  }

  /// Delete a journal entry by ID
  Future<int> deleteEntry(int id) async {
    return await (_db.delete(_db.journalEntries)..where((e) => e.id.equals(id)))
        .go();
  }

  // ==================== Query Operations ====================

  /// Get the most recent journal entries
  Future<List<JournalEntryModel>> getRecentEntries({int limit = 20}) async {
    final results = await (_db.select(_db.journalEntries)
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.entryDate, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();

    return results.map((e) => JournalEntryModel.fromDrift(e)).toList();
  }

  /// Search journal entries by query string in notes and strategy fields
  Future<List<JournalEntryModel>> searchEntries(String query) async {
    final searchPattern = '%$query%';
    final results = await (_db.select(_db.journalEntries)
          ..where((e) =>
              e.notes.like(searchPattern) | e.strategy.like(searchPattern))
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.entryDate, mode: OrderingMode.desc)
          ]))
        .get();

    return results.map((e) => JournalEntryModel.fromDrift(e)).toList();
  }

  // ==================== Statistical Queries ====================

  /// Get win rate for a specified period (in days)
  Future<double> getWinRate({int? days}) async {
    final entries = await _getEntriesInPeriod(days);

    if (entries.isEmpty) return 0.0;

    final closedEntries = entries.where((e) => e.exitDate != null).toList();
    if (closedEntries.isEmpty) return 0.0;

    final winCount = closedEntries.where((e) => (e.pnl ?? 0) > 0).length;
    return (winCount / closedEntries.length) * 100;
  }

  /// Get total P&L for a specified period (in days)
  Future<double> getTotalPnl({int? days}) async {
    final entries = await _getEntriesInPeriod(days);
    return entries.fold<double>(0.0, (sum, entry) => sum + (entry.pnl ?? 0.0));
  }

  /// Get gross profit (sum of all positive P&L) for a specified period
  Future<double> getGrossProfit({int? days}) async {
    final entries = await _getEntriesInPeriod(days);
    return entries
        .where((e) => (e.pnl ?? 0) > 0)
        .fold<double>(0.0, (sum, entry) => sum + (entry.pnl ?? 0.0));
  }

  /// Get gross loss (sum of all negative P&L) for a specified period
  Future<double> getGrossLoss({int? days}) async {
    final entries = await _getEntriesInPeriod(days);
    return entries
        .where((e) => (e.pnl ?? 0) < 0)
        .fold<double>(0.0, (sum, entry) => sum + (entry.pnl ?? 0.0));
  }

  /// Get average risk/reward ratio for a specified period
  Future<double> getAverageRR({int? days}) async {
    final entries = await _getEntriesInPeriod(days);
    final entriesWithRR =
        entries.where((e) => e.riskRewardRatio != null).toList();

    if (entriesWithRR.isEmpty) return 0.0;

    final totalRR = entriesWithRR.fold(
        0.0, (sum, entry) => sum + (entry.riskRewardRatio ?? 0.0));
    return totalRR / entriesWithRR.length;
  }

  /// Get largest winning trade for a specified period
  Future<double> getLargestWin({int? days}) async {
    final entries = await _getEntriesInPeriod(days);
    final wins = entries.where((e) => (e.pnl ?? 0) > 0).toList();

    if (wins.isEmpty) return 0.0;

    return wins.map((e) => e.pnl ?? 0.0).reduce((a, b) => a > b ? a : b);
  }

  /// Get largest losing trade for a specified period
  Future<double> getLargestLoss({int? days}) async {
    final entries = await _getEntriesInPeriod(days);
    final losses = entries.where((e) => (e.pnl ?? 0) < 0).toList();

    if (losses.isEmpty) return 0.0;

    return losses.map((e) => e.pnl ?? 0.0).reduce((a, b) => a < b ? a : b);
  }

  /// Get trade count grouped by emotion
  Future<Map<String, int>> getTradeCountByEmotion() async {
    final entries = await getAllEntries();
    final Map<String, int> emotionCounts = {};

    for (final entry in entries) {
      final emotion = entry.emotion.toJson();
      emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
    }

    return emotionCounts;
  }

  /// Get P&L grouped by symbol for a specified period
  Future<Map<String, double>> getPnlBySymbol({int? days}) async {
    final entries = await _getEntriesInPeriod(days);
    final Map<String, double> symbolPnl = {};

    for (final entry in entries) {
      symbolPnl[entry.symbol] =
          (symbolPnl[entry.symbol] ?? 0.0) + (entry.pnl ?? 0.0);
    }

    return symbolPnl;
  }

  /// Get P&L grouped by emotion for a specified period
  Future<Map<String, double>> getPnlByEmotion({int? days}) async {
    final entries = await _getEntriesInPeriod(days);
    final Map<String, double> emotionPnl = {};

    for (final entry in entries) {
      final emotion = entry.emotion.toJson();
      emotionPnl[emotion] = (emotionPnl[emotion] ?? 0.0) + (entry.pnl ?? 0.0);
    }

    return emotionPnl;
  }

  // ==================== Stream Operations ====================

  /// Watch all journal entries for real-time updates
  Stream<List<JournalEntryModel>> watchEntries() {
    return (_db.select(_db.journalEntries)
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.entryDate, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((entries) =>
            entries.map((e) => JournalEntryModel.fromDrift(e)).toList());
  }

  // ==================== Private Helper Methods ====================

  /// Get entries within a specified period (in days from now)
  Future<List<JournalEntryModel>> _getEntriesInPeriod(int? days) async {
    if (days == null) {
      return await getAllEntries();
    }

    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return await getAllEntries(
      range: flutter.DateTimeRange(start: cutoffDate, end: DateTime.now()),
    );
  }
}
