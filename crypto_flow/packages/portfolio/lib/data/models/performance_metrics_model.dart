import '../../domain/entities/performance_metrics.dart';

class MonthlyReturnModel {
  final String month;
  final double returnPct;
  final double returnAbs;

  const MonthlyReturnModel({
    required this.month,
    required this.returnPct,
    required this.returnAbs,
  });

  factory MonthlyReturnModel.fromJson(Map<String, dynamic> json) {
    return MonthlyReturnModel(
      month: json['month'] as String? ?? '',
      returnPct: (json['returnPct'] as num?)?.toDouble() ?? 0,
      returnAbs: (json['returnAbs'] as num?)?.toDouble() ?? 0,
    );
  }

  MonthlyReturn toEntity() => MonthlyReturn(
        month: month,
        returnPct: returnPct,
        returnAbs: returnAbs,
      );
}

class BenchmarkComparisonModel {
  final String symbol;
  final double portfolioReturnPct;
  final double benchmarkReturnPct;
  final double alpha;

  const BenchmarkComparisonModel({
    required this.symbol,
    required this.portfolioReturnPct,
    required this.benchmarkReturnPct,
    required this.alpha,
  });

  factory BenchmarkComparisonModel.fromJson(Map<String, dynamic> json) {
    return BenchmarkComparisonModel(
      symbol: json['symbol'] as String? ?? '',
      portfolioReturnPct: (json['portfolioReturnPct'] as num?)?.toDouble() ?? 0,
      benchmarkReturnPct: (json['benchmarkReturnPct'] as num?)?.toDouble() ?? 0,
      alpha: (json['alpha'] as num?)?.toDouble() ?? 0,
    );
  }

  BenchmarkComparison toEntity() => BenchmarkComparison(
        symbol: symbol,
        portfolioReturnPct: portfolioReturnPct,
        benchmarkReturnPct: benchmarkReturnPct,
        alpha: alpha,
      );
}

class PerformanceMetricsModel {
  final String period;
  final double totalReturn;
  final double totalReturnPct;
  final double sharpeRatio;
  final double sortinoRatio;
  final double maxDrawdown;
  final double maxDrawdownPct;
  final double winRate;
  final double profitFactor;
  final List<MonthlyReturnModel> monthlyReturns;
  final List<BenchmarkComparisonModel> benchmarks;

  const PerformanceMetricsModel({
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

  factory PerformanceMetricsModel.fromJson(Map<String, dynamic> json) {
    return PerformanceMetricsModel(
      period: json['period'] as String? ?? 'monthly',
      totalReturn: (json['totalReturn'] as num?)?.toDouble() ?? 0,
      totalReturnPct: (json['totalReturnPct'] as num?)?.toDouble() ?? 0,
      sharpeRatio: (json['sharpeRatio'] as num?)?.toDouble() ?? 0,
      sortinoRatio: (json['sortinoRatio'] as num?)?.toDouble() ?? 0,
      maxDrawdown: (json['maxDrawdown'] as num?)?.toDouble() ?? 0,
      maxDrawdownPct: (json['maxDrawdownPct'] as num?)?.toDouble() ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0,
      profitFactor: (json['profitFactor'] as num?)?.toDouble() ?? 0,
      monthlyReturns: (json['monthlyReturns'] as List<dynamic>?)
              ?.map(
                  (e) => MonthlyReturnModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      benchmarks: (json['benchmarks'] as List<dynamic>?)
              ?.map((e) =>
                  BenchmarkComparisonModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  PerformanceMetrics toEntity() => PerformanceMetrics(
        period: period,
        totalReturn: totalReturn,
        totalReturnPct: totalReturnPct,
        sharpeRatio: sharpeRatio,
        sortinoRatio: sortinoRatio,
        maxDrawdown: maxDrawdown,
        maxDrawdownPct: maxDrawdownPct,
        winRate: winRate,
        profitFactor: profitFactor,
        monthlyReturns: monthlyReturns.map((m) => m.toEntity()).toList(),
        benchmarks: benchmarks.map((b) => b.toEntity()).toList(),
      );
}
