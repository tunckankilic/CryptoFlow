import 'package:equatable/equatable.dart';
import 'package:market/market.dart';

/// Events for [Market3DBloc].
abstract class Market3DEvent extends Equatable {
  const Market3DEvent();

  @override
  List<Object?> get props => [];
}

/// Loads historical candles for the 3D city.
///
/// Mirrors `CandleBloc`'s `LoadCandles`, renamed to avoid an ambiguous import
/// where a file needs both the `market` and `market_3d` barrels.
class LoadMarket3DCandles extends Market3DEvent {
  final String symbol;
  final String interval;
  final int limit;

  const LoadMarket3DCandles({
    required this.symbol,
    this.interval = '1m',
    this.limit = 100,
  });

  @override
  List<Object?> get props => [symbol, interval, limit];
}

/// Subscribes to live candle updates for the loaded series.
///
/// Mirrors `CandleBloc`'s `SubscribeToCandleStream`.
class SubscribeToMarket3DStream extends Market3DEvent {
  final String symbol;
  final String interval;

  const SubscribeToMarket3DStream({
    required this.symbol,
    required this.interval,
  });

  @override
  List<Object?> get props => [symbol, interval];
}

/// Internal: a candle update arrived from the WebSocket stream.
class Market3DCandleReceived extends Market3DEvent {
  final Candle candle;

  const Market3DCandleReceived(this.candle);

  @override
  List<Object?> get props => [candle];
}

/// Internal: the WebSocket stream reported an error.
class Market3DStreamError extends Market3DEvent {
  final String message;

  const Market3DStreamError(this.message);

  @override
  List<Object?> get props => [message];
}
