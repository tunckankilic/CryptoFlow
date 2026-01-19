import 'package:equatable/equatable.dart';

/// Events for OrderBookBloc
abstract class OrderBookEvent extends Equatable {
  const OrderBookEvent();

  @override
  List<Object?> get props => [];
}

/// Load order book snapshot
class LoadOrderBook extends OrderBookEvent {
  final String symbol;
  final int depth;

  const LoadOrderBook({
    required this.symbol,
    this.depth = 20,
  });

  @override
  List<Object?> get props => [symbol, depth];
}

/// Subscribe to order book updates
class SubscribeToOrderBook extends OrderBookEvent {
  final String symbol;
  final int depth;

  const SubscribeToOrderBook({
    required this.symbol,
    this.depth = 20,
  });

  @override
  List<Object?> get props => [symbol, depth];
}

/// Unsubscribe from order book
class UnsubscribeFromOrderBook extends OrderBookEvent {
  const UnsubscribeFromOrderBook();
}

/// Internal: Order book updated
class OrderBookReceived extends OrderBookEvent {
  final dynamic orderBook;

  const OrderBookReceived(this.orderBook);

  @override
  List<Object?> get props => [orderBook];
}
