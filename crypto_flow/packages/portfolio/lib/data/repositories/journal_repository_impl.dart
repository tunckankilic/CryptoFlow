import 'package:core/error/exceptions.dart';
import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_tag.dart';
import '../../domain/entities/trade_emotion.dart';
import '../../domain/entities/trade_side.dart';
import '../../domain/entities/trading_stats.dart';
import '../../domain/entities/stats_period.dart';
import '../../domain/repositories/journal_repository.dart';
import '../local/daos/journal_dao.dart';
import '../local/daos/tag_dao.dart';
import '../models/journal_entry_model.dart';
import '../models/journal_tag_model.dart';

/// Implementation of JournalRepository using local database
class JournalRepositoryImpl implements JournalRepository {
  final JournalDao journalDao;
  final TagDao tagDao;

  JournalRepositoryImpl({
    required this.journalDao,
    required this.tagDao,
  });

  // ==================== CRUD Operations ====================

  @override
  Future<Either<Failure, int>> addEntry(JournalEntry entry) async {
    try {
      final model = JournalEntryModel.fromEntity(entry);
      final id = await journalDao.insertEntry(model);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to add journal entry: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateEntry(JournalEntry entry) async {
    try {
      final model = JournalEntryModel.fromEntity(entry);
      await journalDao.updateEntry(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update journal entry: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEntry(int id) async {
    try {
      await journalDao.deleteEntry(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete journal entry: $e'));
    }
  }

  @override
  Future<Either<Failure, JournalEntry>> getEntryById(int id) async {
    try {
      final model = await journalDao.getEntryById(id);
      if (model == null) {
        return Left(CacheFailure(message: 'Journal entry not found'));
      }
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get journal entry: $e'));
    }
  }

  @override
  Future<Either<Failure, List<JournalEntry>>> getEntries({
    String? symbol,
    TradeSide? side,
    DateTimeRange? range,
    String? tag,
    int? limit,
  }) async {
    try {
      List<JournalEntryModel> models;

      if (tag != null) {
        models = await journalDao.getEntriesByTag(tag);
      } else {
        models = await journalDao.getAllEntries(
          symbol: symbol,
          side: side,
          range: range,
        );
      }

      if (limit != null && models.length > limit) {
        models = models.sublist(0, limit);
      }

      final entries = models.map((m) => m.toEntity()).toList();
      return Right(entries);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get journal entries: $e'));
    }
  }

  // ==================== Search and Streams ====================

  @override
  Future<Either<Failure, List<JournalEntry>>> searchEntries(
      String query) async {
    try {
      final models = await journalDao.searchEntries(query);
      final entries = models.map((m) => m.toEntity()).toList();
      return Right(entries);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to search journal entries: $e'));
    }
  }

  @override
  Stream<List<JournalEntry>> watchEntries() {
    return journalDao
        .watchEntries()
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  // ==================== Statistical Analysis ====================

  @override
  Future<Either<Failure, TradingStats>> calculateStats(
      StatsPeriod period) async {
    try {
      final int? days = _periodToDays(period);
      final now = DateTime.now();

      // Get all necessary metrics
      final totalEntries = await journalDao.getAllEntries();
      final periodEntries = days != null
          ? totalEntries
              .where((e) =>
                  e.entryDate.isAfter(now.subtract(Duration(days: days))))
              .toList()
          : totalEntries;

      final closedEntries =
          periodEntries.where((e) => e.exitDate != null).toList();

      if (closedEntries.isEmpty) {
        return Right(_emptyStats(period, now));
      }

      final winCount = closedEntries.where((e) => (e.pnl ?? 0) > 0).length;
      final lossCount = closedEntries.where((e) => (e.pnl ?? 0) < 0).length;
      final totalTrades = closedEntries.length;

      final winRate = totalTrades > 0 ? (winCount / totalTrades) * 100 : 0.0;

      final totalPnl = await journalDao.getTotalPnl(days: days);
      final grossProfit = await journalDao.getGrossProfit(days: days);
      final grossLoss = await journalDao.getGrossLoss(days: days);
      final averageRR = await journalDao.getAverageRR(days: days);
      final largestWin = await journalDao.getLargestWin(days: days);
      final largestLoss = await journalDao.getLargestLoss(days: days);

      // Calculate profit factor: grossProfit / |grossLoss|
      final profitFactor = grossLoss != 0 ? grossProfit / grossLoss.abs() : 0.0;

      final periodStart = days != null
          ? now.subtract(Duration(days: days))
          : (totalEntries.isNotEmpty
              ? totalEntries
                  .map((e) => e.entryDate)
                  .reduce((a, b) => a.isBefore(b) ? a : b)
              : now);

      final stats = TradingStats(
        id: 0, // ID will be set by database
        period: period,
        periodStart: periodStart,
        periodEnd: now,
        totalTrades: totalTrades,
        winCount: winCount,
        lossCount: lossCount,
        winRate: winRate,
        totalPnl: totalPnl,
        averageRR: averageRR,
        largestWin: largestWin,
        largestLoss: largestLoss,
        profitFactor: profitFactor,
        updatedAt: now,
      );

      return Right(stats);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to calculate stats: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getPnlBySymbol({
    int? days,
  }) async {
    try {
      final pnlMap = await journalDao.getPnlBySymbol(days: days);
      return Right(pnlMap);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get P&L by symbol: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<TradeEmotion, double>>> getPnlByEmotion({
    int? days,
  }) async {
    try {
      final pnlMap = await journalDao.getPnlByEmotion(days: days);

      // Convert String keys to TradeEmotion enum
      final emotionMap = <TradeEmotion, double>{};
      for (final entry in pnlMap.entries) {
        final emotion = TradeEmotionX.fromJson(entry.key);
        emotionMap[emotion] = entry.value;
      }

      return Right(emotionMap);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get P&L by emotion: $e'));
    }
  }

  @override
  Future<Either<Failure, List<double>>> getEquityCurve({int? days}) async {
    try {
      final now = DateTime.now();
      final cutoffDate =
          days != null ? now.subtract(Duration(days: days)) : null;

      // Get all entries sorted by date
      final entries = await journalDao.getAllEntries();

      // Filter by date if needed
      var filteredEntries = entries;
      if (cutoffDate != null) {
        filteredEntries =
            entries.where((e) => e.entryDate.isAfter(cutoffDate)).toList();
      }

      // Sort by entry date
      filteredEntries.sort((a, b) => a.entryDate.compareTo(b.entryDate));

      // Calculate cumulative P&L
      final equityCurve = <double>[];
      double cumulative = 0.0;

      for (final entry in filteredEntries) {
        if (entry.pnl != null) {
          cumulative += entry.pnl!;
          equityCurve.add(cumulative);
        }
      }

      return Right(equityCurve);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get equity curve: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getMaxDrawdown({int? days}) async {
    try {
      final equityCurveResult = await getEquityCurve(days: days);

      return equityCurveResult.fold(
        (failure) => Left(failure),
        (equityCurve) {
          if (equityCurve.isEmpty) {
            return const Right(0.0);
          }

          double maxDrawdown = 0.0;
          double peak = equityCurve[0];

          for (final equity in equityCurve) {
            if (equity > peak) {
              peak = equity;
            }

            final drawdown = peak - equity;
            if (drawdown > maxDrawdown) {
              maxDrawdown = drawdown;
            }
          }

          // Return as percentage if peak > 0
          final drawdownPercentage =
              peak > 0 ? (maxDrawdown / peak) * 100 : 0.0;

          return Right(drawdownPercentage);
        },
      );
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to calculate max drawdown: $e'));
    }
  }

  // ==================== Tag Operations ====================

  @override
  Future<Either<Failure, List<JournalTag>>> getTags() async {
    try {
      final models = await tagDao.getAllTags();
      final tags = models.map((m) => m.toEntity()).toList();
      return Right(tags);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get tags: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> addTag(JournalTag tag) async {
    try {
      final model = JournalTagModel.fromEntity(tag);
      final id = await tagDao.insertTag(model);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to add tag: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTag(int id) async {
    try {
      await tagDao.deleteTag(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete tag: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementTagUsage(int tagId) async {
    try {
      await tagDao.incrementUsage(tagId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to increment tag usage: $e'));
    }
  }

  // ==================== Private Helper Methods ====================

  /// Convert StatsPeriod to number of days
  int? _periodToDays(StatsPeriod period) {
    switch (period) {
      case StatsPeriod.daily:
        return 1;
      case StatsPeriod.weekly:
        return 7;
      case StatsPeriod.monthly:
        return 30;
      case StatsPeriod.allTime:
        return null;
    }
  }

  /// Create empty stats for when there are no entries
  TradingStats _emptyStats(StatsPeriod period, DateTime now) {
    final periodStart = _periodToDays(period) != null
        ? now.subtract(Duration(days: _periodToDays(period)!))
        : now;

    return TradingStats(
      id: 0,
      period: period,
      periodStart: periodStart,
      periodEnd: now,
      totalTrades: 0,
      winCount: 0,
      lossCount: 0,
      winRate: 0.0,
      totalPnl: 0.0,
      averageRR: 0.0,
      largestWin: 0.0,
      largestLoss: 0.0,
      profitFactor: 0.0,
      updatedAt: now,
    );
  }
}
