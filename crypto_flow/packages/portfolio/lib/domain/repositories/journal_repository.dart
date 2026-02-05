import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../entities/journal_entry.dart';
import '../entities/journal_tag.dart';
import '../entities/trade_emotion.dart';
import '../entities/trade_side.dart';
import '../entities/trading_stats.dart';
import '../entities/stats_period.dart';

/// Abstract repository interface for journal operations
/// Uses Either<Failure, T> pattern for error handling
abstract class JournalRepository {
  // ==================== CRUD Operations ====================

  /// Add a new journal entry
  Future<Either<Failure, int>> addEntry(JournalEntry entry);

  /// Update an existing journal entry
  Future<Either<Failure, void>> updateEntry(JournalEntry entry);

  /// Delete a journal entry by ID
  Future<Either<Failure, void>> deleteEntry(int id);

  /// Get a single journal entry by ID
  Future<Either<Failure, JournalEntry>> getEntryById(int id);

  /// Get journal entries with optional filters
  Future<Either<Failure, List<JournalEntry>>> getEntries({
    String? symbol,
    TradeSide? side,
    DateTimeRange? range,
    String? tag,
    int? limit,
  });

  // ==================== Search and Streams ====================

  /// Search journal entries by query string
  Future<Either<Failure, List<JournalEntry>>> searchEntries(String query);

  /// Watch all journal entries for real-time updates
  Stream<List<JournalEntry>> watchEntries();

  // ==================== Statistical Analysis ====================

  /// Calculate trading statistics for a specified period
  Future<Either<Failure, TradingStats>> calculateStats(StatsPeriod period);

  /// Get P&L grouped by symbol
  Future<Either<Failure, Map<String, double>>> getPnlBySymbol({int? days});

  /// Get P&L grouped by emotion
  Future<Either<Failure, Map<TradeEmotion, double>>> getPnlByEmotion({
    int? days,
  });

  /// Get equity curve (cumulative P&L over time)
  Future<Either<Failure, List<double>>> getEquityCurve({int? days});

  /// Calculate maximum drawdown
  Future<Either<Failure, double>> getMaxDrawdown({int? days});

  // ==================== Tag Operations ====================

  /// Get all tags
  Future<Either<Failure, List<JournalTag>>> getTags();

  /// Add a new tag
  Future<Either<Failure, int>> addTag(JournalTag tag);

  /// Delete a tag by ID
  Future<Either<Failure, void>> deleteTag(int id);

  /// Increment tag usage count
  Future<Either<Failure, void>> incrementTagUsage(int tagId);
}
