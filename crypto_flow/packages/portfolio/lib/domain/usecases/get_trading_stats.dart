import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../entities/stats_period.dart';
import '../entities/trading_stats.dart';
import '../repositories/journal_repository.dart';

/// Parameters for GetTradingStats use case
class GetTradingStatsParams {
  final StatsPeriod period;

  GetTradingStatsParams({required this.period});
}

/// Use case to calculate trading statistics for a period
/// Returns comprehensive stats including win rate, profit factor, etc.
class GetTradingStats implements UseCase<TradingStats, GetTradingStatsParams> {
  final JournalRepository repository;

  GetTradingStats(this.repository);

  @override
  Future<Either<Failure, TradingStats>> call(
      GetTradingStatsParams params) async {
    // Calculate and return stats from repository
    return await repository.calculateStats(params.period);
  }
}
