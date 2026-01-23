import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import '../entities/order_book.dart';
import '../repositories/market_repository.dart';

/// Use case to fetch order book snapshot from REST API
class GetOrderBookUseCase implements UseCase<OrderBook, OrderBookParams> {
  final MarketRepository repository;

  GetOrderBookUseCase(this.repository);

  @override
  Future<Either<Failure, OrderBook>> call(OrderBookParams params) {
    return repository.getOrderBook(params.symbol, limit: params.limit);
  }
}

/// Parameters for fetching order book
class OrderBookParams extends Equatable {
  /// Trading pair symbol (e.g., "BTCUSDT")
  final String symbol;

  /// Number of price levels to fetch (5, 10, 20, 50, 100, 500, 1000, 5000)
  final int limit;

  const OrderBookParams({
    required this.symbol,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [symbol, limit];
}

/// Supported order book depth limits
class OrderBookDepth {
  static const int level5 = 5;
  static const int level10 = 10;
  static const int level20 = 20;
  static const int level50 = 50;
  static const int level100 = 100;
  static const int level500 = 500;
  static const int level1000 = 1000;
  static const int level5000 = 5000;

  static const List<int> all = [
    level5,
    level10,
    level20,
    level50,
    level100,
    level500,
    level1000,
    level5000,
  ];
}
