import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import '../entities/ticker.dart';
import '../repositories/websocket_repository.dart';

/// Use case to subscribe to real-time ticker updates via WebSocket
class GetTickerStreamUseCase
    implements StreamUseCase<Ticker, TickerStreamParams> {
  final WebSocketRepository repository;

  GetTickerStreamUseCase(this.repository);

  @override
  Stream<Either<Failure, Ticker>> call(TickerStreamParams params) {
    return repository.getTickerStream(params.symbol);
  }
}

/// Parameters for ticker stream subscription
class TickerStreamParams extends Equatable {
  final String symbol;

  const TickerStreamParams({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}
