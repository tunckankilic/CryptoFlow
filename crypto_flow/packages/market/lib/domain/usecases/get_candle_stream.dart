import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import '../entities/candle.dart';
import '../repositories/websocket_repository.dart';

/// Use case to subscribe to real-time candlestick updates via WebSocket
class GetCandleStreamUseCase
    implements StreamUseCase<Candle, CandleStreamParams> {
  final WebSocketRepository repository;

  GetCandleStreamUseCase(this.repository);

  @override
  Stream<Either<Failure, Candle>> call(CandleStreamParams params) {
    return repository.getCandleStream(params.symbol, params.interval);
  }
}

/// Parameters for candlestick stream subscription
class CandleStreamParams extends Equatable {
  /// Trading pair symbol (e.g., "BTCUSDT")
  final String symbol;

  /// Candlestick interval (e.g., "1m", "5m", "1h")
  final String interval;

  const CandleStreamParams({
    required this.symbol,
    required this.interval,
  });

  @override
  List<Object?> get props => [symbol, interval];
}
