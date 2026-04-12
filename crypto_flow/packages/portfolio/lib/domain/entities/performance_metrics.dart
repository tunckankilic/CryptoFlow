import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents a single month's return data
@immutable
class MonthlyReturn extends Equatable {
  final String month; // YYYY-MM
  final double returnPct;
  final double returnAbs;

  const MonthlyReturn({
    required this.month,
    required this.returnPct,
    required this.returnAbs,
  });

  @override
  List<Object?> get props => [month, returnPct, returnAbs];
}

/// Represents a benchmark comparison (e.g., vs BTC, ETH)
@immutable
class BenchmarkComparison extends Equatable {
  final String symbol;
  final double portfolioReturnPct;
  final double benchmarkReturnPct;
  final double alpha;

  const BenchmarkComparison({
    required this.symbol,
    required this.portfolioReturnPct,
    required this.benchmarkReturnPct,
    required this.alpha,
  });

  @override
  List<Object?> get props =>
      [symbol, portfolioReturnPct, benchmarkReturnPct, alpha];
}

/// Aggregated performance analytics metrics
@immutable
class PerformanceMetrics extends Equatable {
  final String period;
  final double totalReturn;
  final double totalReturnPct;
  final double sharpeRatio;
  final double sortinoRatio;
  final double maxDrawdown;
  final double maxDrawdownPct;
  final double winRate;
  final double profitFactor;
  final List<MonthlyReturn> monthlyReturns;
  final List<BenchmarkComparison> benchmarks;

  const PerformanceMetrics({
    required this.period,
    required this.totalReturn,
    required this.totalReturnPct,
    required this.sharpeRatio,
    required this.sortinoRatio,
    required this.maxDrawdown,
    required this.maxDrawdownPct,
    required this.winRate,
    required this.profitFactor,
    required this.monthlyReturns,
    required this.benchmarks,
  });

  @override
  List<Object?> get props => [
        period,
        totalReturn,
        totalReturnPct,
        sharpeRatio,
        sortinoRatio,
        maxDrawdown,
        maxDrawdownPct,
        winRate,
        profitFactor,
        monthlyReturns,
        benchmarks,
      ];
}
