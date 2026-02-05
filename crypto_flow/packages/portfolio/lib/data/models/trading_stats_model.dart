import '../../domain/entities/trading_stats.dart' as domain;
import '../../domain/entities/stats_period.dart';
import '../datasources/portfolio_database.dart' as db;

/// Data model for TradingStats entity
class TradingStatsModel extends domain.TradingStats {
  const TradingStatsModel({
    required super.id,
    required super.period,
    required super.periodStart,
    required super.periodEnd,
    required super.totalTrades,
    required super.winCount,
    required super.lossCount,
    required super.winRate,
    required super.totalPnl,
    required super.averageRR,
    required super.largestWin,
    required super.largestLoss,
    required super.profitFactor,
    required super.updatedAt,
  });

  /// Create from JSON
  factory TradingStatsModel.fromJson(Map<String, dynamic> json) {
    return TradingStatsModel(
      id: json['id'] as int,
      period: StatsPeriodX.fromJson(json['period'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      totalTrades: json['totalTrades'] as int,
      winCount: json['winCount'] as int,
      lossCount: json['lossCount'] as int,
      winRate: (json['winRate'] as num).toDouble(),
      totalPnl: (json['totalPnl'] as num).toDouble(),
      averageRR: (json['averageRR'] as num).toDouble(),
      largestWin: (json['largestWin'] as num).toDouble(),
      largestLoss: (json['largestLoss'] as num).toDouble(),
      profitFactor: (json['profitFactor'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period.toJson(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'totalTrades': totalTrades,
      'winCount': winCount,
      'lossCount': lossCount,
      'winRate': winRate,
      'totalPnl': totalPnl,
      'averageRR': averageRR,
      'largestWin': largestWin,
      'largestLoss': largestLoss,
      'profitFactor': profitFactor,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to domain entity
  domain.TradingStats toEntity() {
    return domain.TradingStats(
      id: id,
      period: period,
      periodStart: periodStart,
      periodEnd: periodEnd,
      totalTrades: totalTrades,
      winCount: winCount,
      lossCount: lossCount,
      winRate: winRate,
      totalPnl: totalPnl,
      averageRR: averageRR,
      largestWin: largestWin,
      largestLoss: largestLoss,
      profitFactor: profitFactor,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory TradingStatsModel.fromEntity(domain.TradingStats stats) {
    return TradingStatsModel(
      id: stats.id,
      period: stats.period,
      periodStart: stats.periodStart,
      periodEnd: stats.periodEnd,
      totalTrades: stats.totalTrades,
      winCount: stats.winCount,
      lossCount: stats.lossCount,
      winRate: stats.winRate,
      totalPnl: stats.totalPnl,
      averageRR: stats.averageRR,
      largestWin: stats.largestWin,
      largestLoss: stats.largestLoss,
      profitFactor: stats.profitFactor,
      updatedAt: stats.updatedAt,
    );
  }

  /// Create from Drift row
  factory TradingStatsModel.fromDrift(db.TradingStat driftRow) {
    return TradingStatsModel(
      id: driftRow.id,
      period: StatsPeriodX.fromJson(driftRow.period),
      periodStart: driftRow.periodStart,
      periodEnd: driftRow.periodEnd,
      totalTrades: driftRow.totalTrades,
      winCount: driftRow.winCount,
      lossCount: driftRow.lossCount,
      winRate: driftRow.winRate,
      totalPnl: driftRow.totalPnl,
      averageRR: driftRow.averageRR,
      largestWin: driftRow.largestWin,
      largestLoss: driftRow.largestLoss,
      profitFactor: driftRow.profitFactor,
      updatedAt: driftRow.updatedAt,
    );
  }

  /// Convert to Drift companion
  db.TradingStatsCompanion toDrift() {
    return db.TradingStatsCompanion.insert(
      period: period.toJson(),
      periodStart: periodStart,
      periodEnd: periodEnd,
      totalTrades: totalTrades,
      winCount: winCount,
      lossCount: lossCount,
      winRate: winRate,
      totalPnl: totalPnl,
      averageRR: averageRR,
      largestWin: largestWin,
      largestLoss: largestLoss,
      profitFactor: profitFactor,
      updatedAt: updatedAt,
    );
  }
}
