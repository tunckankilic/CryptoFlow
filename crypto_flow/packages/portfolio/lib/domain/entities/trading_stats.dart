import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'stats_period.dart';

/// Represents aggregated trading statistics for a period
@immutable
class TradingStats extends Equatable {
  /// Unique identifier
  final int id;

  /// Time period
  final StatsPeriod period;

  /// Period start date
  final DateTime periodStart;

  /// Period end date
  final DateTime periodEnd;

  /// Total number of trades
  final int totalTrades;

  /// Number of winning trades
  final int winCount;

  /// Number of losing trades
  final int lossCount;

  /// Win rate as percentage
  final double winRate;

  /// Total profit/loss
  final double totalPnl;

  /// Average risk/reward ratio
  final double averageRR;

  /// Largest winning trade
  final double largestWin;

  /// Largest losing trade
  final double largestLoss;

  /// Profit factor (gross profit / gross loss)
  final double profitFactor;

  /// Last update timestamp
  final DateTime updatedAt;

  const TradingStats({
    required this.id,
    required this.period,
    required this.periodStart,
    required this.periodEnd,
    required this.totalTrades,
    required this.winCount,
    required this.lossCount,
    required this.winRate,
    required this.totalPnl,
    required this.averageRR,
    required this.largestWin,
    required this.largestLoss,
    required this.profitFactor,
    required this.updatedAt,
  });

  /// Creates a copy with the given fields replaced
  TradingStats copyWith({
    int? id,
    StatsPeriod? period,
    DateTime? periodStart,
    DateTime? periodEnd,
    int? totalTrades,
    int? winCount,
    int? lossCount,
    double? winRate,
    double? totalPnl,
    double? averageRR,
    double? largestWin,
    double? largestLoss,
    double? profitFactor,
    DateTime? updatedAt,
  }) {
    return TradingStats(
      id: id ?? this.id,
      period: period ?? this.period,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      totalTrades: totalTrades ?? this.totalTrades,
      winCount: winCount ?? this.winCount,
      lossCount: lossCount ?? this.lossCount,
      winRate: winRate ?? this.winRate,
      totalPnl: totalPnl ?? this.totalPnl,
      averageRR: averageRR ?? this.averageRR,
      largestWin: largestWin ?? this.largestWin,
      largestLoss: largestLoss ?? this.largestLoss,
      profitFactor: profitFactor ?? this.profitFactor,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        period,
        periodStart,
        periodEnd,
        totalTrades,
        winCount,
        lossCount,
        winRate,
        totalPnl,
        averageRR,
        largestWin,
        largestLoss,
        profitFactor,
        updatedAt,
      ];
}
