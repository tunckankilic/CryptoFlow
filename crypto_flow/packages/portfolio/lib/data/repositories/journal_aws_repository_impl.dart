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
import '../datasources/journal_remote_datasource.dart';
import '../local/daos/journal_dao.dart';
import '../local/daos/tag_dao.dart';
import '../models/journal_entry_model.dart';
import '../models/journal_tag_model.dart';

/// AWS-backed [JournalRepository] implementation.
///
/// Strategy: remote-first for CRUD, local DAO fallback for reads and for
/// complex analytics that the backend doesn't fully support.
/// Tag operations are local-only (no backend tag management).
class JournalAwsRepositoryImpl implements JournalRepository {
  final JournalRemoteDataSource remoteDataSource;
  final JournalDao journalDao;
  final TagDao tagDao;

  JournalAwsRepositoryImpl({
    required this.remoteDataSource,
    required this.journalDao,
    required this.tagDao,
  });

  // ==================== CRUD Operations ====================

  @override
  Future<Either<Failure, int>> addEntry(JournalEntry entry) async {
    try {
      final created = await remoteDataSource.createEntry(entry);
      // Cache locally — also insert via DAO for offline access
      final model = JournalEntryModel.fromEntity(created);
      final localId = await journalDao.insertEntry(model);
      return Right(localId);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add journal entry: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateEntry(JournalEntry entry) async {
    try {
      final remoteId = entry.transactionId ?? entry.id.toString();
      await remoteDataSource.updateEntry(remoteId, entry);
      // Also update local
      final model = JournalEntryModel.fromEntity(entry);
      await journalDao.updateEntry(model);
      return const Right(null);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update journal entry: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEntry(int id) async {
    try {
      // Try to find remote ID from local entry
      final localEntry = await journalDao.getEntryById(id);
      if (localEntry?.transactionId != null) {
        await remoteDataSource.deleteEntry(localEntry!.transactionId!);
      }
      await journalDao.deleteEntry(id);
      return const Right(null);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (_) {
      // Delete locally even if remote fails
      try {
        await journalDao.deleteEntry(id);
        return const Right(null);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete entry: $e'));
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
      final entries = await remoteDataSource.getEntries();
      var filtered = entries.toList();

      if (symbol != null) {
        filtered = filtered.where((e) => e.symbol == symbol).toList();
      }
      if (side != null) {
        filtered = filtered.where((e) => e.side == side).toList();
      }
      if (range != null) {
        filtered = filtered
            .where((e) =>
                e.entryDate.isAfter(range.start) &&
                e.entryDate.isBefore(range.end))
            .toList();
      }
      if (tag != null) {
        filtered = filtered.where((e) => e.tags.contains(tag)).toList();
      }
      if (limit != null && filtered.length > limit) {
        filtered = filtered.sublist(0, limit);
      }
      return Right(filtered);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (_) {
      return _entriesFallback(symbol: symbol, side: side, range: range, tag: tag, limit: limit);
    } on NetworkException {
      return _entriesFallback(symbol: symbol, side: side, range: range, tag: tag, limit: limit);
    } catch (e) {
      return _entriesFallback(symbol: symbol, side: side, range: range, tag: tag, limit: limit);
    }
  }

  Future<Either<Failure, List<JournalEntry>>> _entriesFallback({
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
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  // ==================== Search and Streams ====================

  @override
  Future<Either<Failure, List<JournalEntry>>> searchEntries(
      String query) async {
    // Search is local-only (backend doesn't have a search endpoint)
    try {
      final models = await journalDao.searchEntries(query);
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to search entries: $e'));
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
      final periodStr = period == StatsPeriod.weekly
          ? 'weekly'
          : period == StatsPeriod.allTime
              ? 'all'
              : 'monthly';
      final stats = await remoteDataSource.getStats(period: periodStr);
      return Right(stats);
    } catch (_) {
      // Fallback to local calculation
      return _calculateStatsLocally(period);
    }
  }

  Future<Either<Failure, TradingStats>> _calculateStatsLocally(
      StatsPeriod period) async {
    try {
      final now = DateTime.now();
      final days = _periodToDays(period);
      final entries = await journalDao.getAllEntries();
      final periodEntries = days != null
          ? entries
              .where(
                  (e) => e.entryDate.isAfter(now.subtract(Duration(days: days))))
              .toList()
          : entries;

      final closed = periodEntries.where((e) => e.exitDate != null).toList();
      if (closed.isEmpty) return Right(_emptyStats(period, now));

      final winCount = closed.where((e) => (e.pnl ?? 0) > 0).length;
      final lossCount = closed.where((e) => (e.pnl ?? 0) < 0).length;
      final totalPnl = await journalDao.getTotalPnl(days: days);
      final largestWin = await journalDao.getLargestWin(days: days);
      final largestLoss = await journalDao.getLargestLoss(days: days);
      final averageRR = await journalDao.getAverageRR(days: days);
      final grossProfit = await journalDao.getGrossProfit(days: days);
      final grossLoss = await journalDao.getGrossLoss(days: days);

      return Right(TradingStats(
        id: 0,
        period: period,
        periodStart:
            days != null ? now.subtract(Duration(days: days)) : now,
        periodEnd: now,
        totalTrades: closed.length,
        winCount: winCount,
        lossCount: lossCount,
        winRate: closed.isNotEmpty ? (winCount / closed.length) * 100 : 0,
        totalPnl: totalPnl,
        averageRR: averageRR,
        largestWin: largestWin,
        largestLoss: largestLoss,
        profitFactor: grossLoss != 0 ? grossProfit / grossLoss.abs() : 0,
        updatedAt: now,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getPnlBySymbol({
    int? days,
  }) async {
    try {
      return Right(await journalDao.getPnlBySymbol(days: days));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Map<TradeEmotion, double>>> getPnlByEmotion({
    int? days,
  }) async {
    try {
      final pnlMap = await journalDao.getPnlByEmotion(days: days);
      final emotionMap = <TradeEmotion, double>{};
      for (final entry in pnlMap.entries) {
        emotionMap[TradeEmotionX.fromJson(entry.key)] = entry.value;
      }
      return Right(emotionMap);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<double>>> getEquityCurve({int? days}) async {
    try {
      final now = DateTime.now();
      final cutoff = days != null ? now.subtract(Duration(days: days)) : null;
      var entries = await journalDao.getAllEntries();
      if (cutoff != null) {
        entries = entries.where((e) => e.entryDate.isAfter(cutoff)).toList();
      }
      entries.sort((a, b) => a.entryDate.compareTo(b.entryDate));

      final curve = <double>[];
      double cumulative = 0;
      for (final entry in entries) {
        if (entry.pnl != null) {
          cumulative += entry.pnl!;
          curve.add(cumulative);
        }
      }
      return Right(curve);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, double>> getMaxDrawdown({int? days}) async {
    final curveResult = await getEquityCurve(days: days);
    return curveResult.fold(
      (failure) => Left(failure),
      (curve) {
        if (curve.isEmpty) return const Right(0.0);
        double maxDD = 0, peak = curve[0];
        for (final eq in curve) {
          if (eq > peak) peak = eq;
          final dd = peak - eq;
          if (dd > maxDD) maxDD = dd;
        }
        return Right(peak > 0 ? (maxDD / peak) * 100 : 0.0);
      },
    );
  }

  // ==================== Tag Operations (local-only) ====================

  @override
  Future<Either<Failure, List<JournalTag>>> getTags() async {
    try {
      final models = await tagDao.getAllTags();
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, int>> addTag(JournalTag tag) async {
    try {
      final model = JournalTagModel.fromEntity(tag);
      return Right(await tagDao.insertTag(model));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTag(int id) async {
    try {
      await tagDao.deleteTag(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> incrementTagUsage(int tagId) async {
    try {
      await tagDao.incrementUsage(tagId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  // ==================== Private helpers ====================

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

  TradingStats _emptyStats(StatsPeriod period, DateTime now) {
    final start = _periodToDays(period) != null
        ? now.subtract(Duration(days: _periodToDays(period)!))
        : now;
    return TradingStats(
      id: 0,
      period: period,
      periodStart: start,
      periodEnd: now,
      totalTrades: 0,
      winCount: 0,
      lossCount: 0,
      winRate: 0,
      totalPnl: 0,
      averageRR: 0,
      largestWin: 0,
      largestLoss: 0,
      profitFactor: 0,
      updatedAt: now,
    );
  }
}
