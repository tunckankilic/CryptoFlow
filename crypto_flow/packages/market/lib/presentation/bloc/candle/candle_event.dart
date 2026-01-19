import 'package:equatable/equatable.dart';

/// Events for CandleBloc
abstract class CandleEvent extends Equatable {
  const CandleEvent();

  @override
  List<Object?> get props => [];
}

/// Load historical candles
class LoadCandles extends CandleEvent {
  final String symbol;
  final String interval;
  final int limit;

  const LoadCandles({
    required this.symbol,
    this.interval = '1h',
    this.limit = 100,
  });

  @override
  List<Object?> get props => [symbol, interval, limit];
}

/// Subscribe to live candle updates
class SubscribeToCandleStream extends CandleEvent {
  final String symbol;
  final String interval;

  const SubscribeToCandleStream({
    required this.symbol,
    required this.interval,
  });

  @override
  List<Object?> get props => [symbol, interval];
}

/// Unsubscribe from candle stream
class UnsubscribeFromCandleStream extends CandleEvent {
  const UnsubscribeFromCandleStream();
}

/// Change interval
class ChangeCandleInterval extends CandleEvent {
  final String interval;

  const ChangeCandleInterval(this.interval);

  @override
  List<Object?> get props => [interval];
}

/// Internal: Candle updated from WebSocket
class CandleReceived extends CandleEvent {
  final dynamic candle;

  const CandleReceived(this.candle);

  @override
  List<Object?> get props => [candle];
}
