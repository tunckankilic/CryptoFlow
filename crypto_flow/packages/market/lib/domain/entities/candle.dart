import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents a candlestick (OHLCV) data point
@immutable
class Candle extends Equatable {
  /// Candle open time
  final DateTime openTime;

  /// Candle close time
  final DateTime closeTime;

  /// Opening price
  final double open;

  /// Highest price during this candle
  final double high;

  /// Lowest price during this candle
  final double low;

  /// Closing price
  final double close;

  /// Trading volume in base asset
  final double volume;

  /// Number of trades during this candle
  final int trades;

  const Candle({
    required this.openTime,
    required this.closeTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.trades,
  });

  /// Returns true if this is a bullish (green) candle
  bool get isBullish => close >= open;

  /// Returns true if this is a bearish (red) candle
  bool get isBearish => close < open;

  /// Returns the absolute size of the candle body
  double get bodySize => (close - open).abs();

  /// Returns the size of the upper wick/shadow
  double get upperWick => high - (isBullish ? close : open);

  /// Returns the size of the lower wick/shadow
  double get lowerWick => (isBullish ? open : close) - low;

  /// Returns the total range (high - low)
  double get range => high - low;

  /// Returns the percentage change
  double get changePercent => open != 0 ? ((close - open) / open) * 100 : 0;

  /// Returns true if this is a doji candle (very small body)
  bool get isDoji => bodySize < (range * 0.1);

  /// Creates a copy of this Candle with the given fields replaced
  Candle copyWith({
    DateTime? openTime,
    DateTime? closeTime,
    double? open,
    double? high,
    double? low,
    double? close,
    double? volume,
    int? trades,
  }) {
    return Candle(
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
      trades: trades ?? this.trades,
    );
  }

  @override
  List<Object?> get props => [
        openTime,
        closeTime,
        open,
        high,
        low,
        close,
        volume,
        trades,
      ];
}
