import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import '../entities/order_book.dart';
import '../repositories/websocket_repository.dart';

/// Use case to subscribe to real-time order book updates via WebSocket
class GetOrderBookStreamUseCase
    implements StreamUseCase<OrderBook, OrderBookStreamParams> {
  final WebSocketRepository repository;

  GetOrderBookStreamUseCase(this.repository);

  @override
  Stream<Either<Failure, OrderBook>> call(OrderBookStreamParams params) {
    return repository.getOrderBookStream(params.symbol, depth: params.depth);
  }
}

/// Parameters for order book stream subscription
class OrderBookStreamParams extends Equatable {
  /// Trading pair symbol (e.g., "BTCUSDT")
  final String symbol;

  /// Depth level (5, 10, or 20 for WebSocket streams)
  final int depth;

  const OrderBookStreamParams({
    required this.symbol,
    this.depth = 20,
  });

  @override
  List<Object?> get props => [symbol, depth];
}
