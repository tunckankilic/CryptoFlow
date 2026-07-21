import 'package:equatable/equatable.dart';

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
