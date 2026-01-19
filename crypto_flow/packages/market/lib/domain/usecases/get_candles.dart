import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import '../entities/candle.dart';
import '../repositories/market_repository.dart';

/// Use case to fetch historical candlestick data from REST API
class GetCandlesUseCase implements UseCase<List<Candle>, CandlesParams> {
  final MarketRepository repository;

  GetCandlesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Candle>>> call(CandlesParams params) {
    return repository.getCandles(
      params.symbol,
      params.interval,
      limit: params.limit,
      startTime: params.startTime,
      endTime: params.endTime,
    );
  }
}

/// Parameters for fetching candlestick data
class CandlesParams extends Equatable {
  /// Trading pair symbol (e.g., "BTCUSDT")
  final String symbol;

  /// Candlestick interval (e.g., "1m", "5m", "15m", "1h", "4h", "1d", "1w")
  final String interval;

  /// Number of candles to fetch (default: 500, max: 1500)
  final int limit;

  /// Optional start time for historical data
  final DateTime? startTime;

  /// Optional end time for historical data
  final DateTime? endTime;

  const CandlesParams({
    required this.symbol,
    required this.interval,
    this.limit = 500,
    this.startTime,
    this.endTime,
  });

  @override
  List<Object?> get props => [symbol, interval, limit, startTime, endTime];
}

/// Supported candlestick intervals
class CandleInterval {
  static const String oneMinute = '1m';
  static const String threeMinutes = '3m';
  static const String fiveMinutes = '5m';
  static const String fifteenMinutes = '15m';
  static const String thirtyMinutes = '30m';
  static const String oneHour = '1h';
  static const String twoHours = '2h';
  static const String fourHours = '4h';
  static const String sixHours = '6h';
  static const String eightHours = '8h';
  static const String twelveHours = '12h';
  static const String oneDay = '1d';
  static const String threeDays = '3d';
  static const String oneWeek = '1w';
  static const String oneMonth = '1M';

  static const List<String> all = [
    oneMinute,
    threeMinutes,
    fiveMinutes,
    fifteenMinutes,
    thirtyMinutes,
    oneHour,
    twoHours,
    fourHours,
    sixHours,
    eightHours,
    twelveHours,
    oneDay,
    threeDays,
    oneWeek,
    oneMonth,
  ];
}
