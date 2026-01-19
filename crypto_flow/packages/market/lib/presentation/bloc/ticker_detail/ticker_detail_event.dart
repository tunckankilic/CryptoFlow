import 'package:equatable/equatable.dart';

/// Events for TickerDetailBloc
abstract class TickerDetailEvent extends Equatable {
  const TickerDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load ticker details
class LoadTickerDetail extends TickerDetailEvent {
  final String symbol;

  const LoadTickerDetail(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

/// Subscribe to real-time ticker updates
class SubscribeToTickerUpdates extends TickerDetailEvent {
  final String symbol;

  const SubscribeToTickerUpdates(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

/// Unsubscribe from ticker updates
class UnsubscribeFromTickerUpdates extends TickerDetailEvent {
  const UnsubscribeFromTickerUpdates();
}

/// Change chart interval
class ChangeInterval extends TickerDetailEvent {
  final String interval;

  const ChangeInterval(this.interval);

  @override
  List<Object?> get props => [interval];
}

/// Load order book
class LoadOrderBook extends TickerDetailEvent {
  final String symbol;
  final int depth;

  const LoadOrderBook(this.symbol, {this.depth = 20});

  @override
  List<Object?> get props => [symbol, depth];
}

/// Subscribe to order book updates
class SubscribeToOrderBook extends TickerDetailEvent {
  final String symbol;
  final int depth;

  const SubscribeToOrderBook(this.symbol, {this.depth = 20});

  @override
  List<Object?> get props => [symbol, depth];
}

/// Internal: Ticker updated from WebSocket
class TickerUpdated extends TickerDetailEvent {
  final dynamic ticker;

  const TickerUpdated(this.ticker);

  @override
  List<Object?> get props => [ticker];
}

/// Internal: Candle updated from WebSocket
class CandleUpdated extends TickerDetailEvent {
  final dynamic candle;

  const CandleUpdated(this.candle);

  @override
  List<Object?> get props => [candle];
}

/// Internal: Order book updated from WebSocket
class OrderBookUpdated extends TickerDetailEvent {
  final dynamic orderBook;

  const OrderBookUpdated(this.orderBook);

  @override
  List<Object?> get props => [orderBook];
}
