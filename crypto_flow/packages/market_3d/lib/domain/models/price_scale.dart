import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:market/market.dart';

/// Maps prices onto the vertical axis of the scene.
///
/// The scale is built once per scene from the visible candles and then reused
/// for live updates, so a growing live candle only moves its own geometry
/// instead of rescaling the whole city on every tick. Use [covers] to detect
/// when a live price has escaped the current range and the scene needs a
/// rebuild — see [MarketScene.needsRescaleFor].
@immutable
class PriceScale extends Equatable {
  /// Price mapped to `y = 0`.
  final double minPrice;

  /// Price mapped to `y = height`.
  final double maxPrice;

  /// Height of the scale in scene units.
  final double height;

  const PriceScale({
    required this.minPrice,
    required this.maxPrice,
    required this.height,
  });

  /// Builds a scale covering every candle in [candles], with [paddingRatio] of
  /// headroom added above and below so the city never touches the ground plane
  /// or the top of the frame.
  ///
  /// A flat market (all prices equal) collapses to a scale that maps every
  /// price to the middle of the range rather than dividing by zero.
  factory PriceScale.fromCandles(
    List<Candle> candles, {
    double height = 10.0,
    double paddingRatio = 0.08,
  }) {
    if (candles.isEmpty) {
      return PriceScale(minPrice: 0, maxPrice: 1, height: height);
    }

    var low = candles.first.low;
    var high = candles.first.high;
    for (final candle in candles) {
      if (candle.low < low) low = candle.low;
      if (candle.high > high) high = candle.high;
    }

    final range = high - low;
    final padding = range > 0 ? range * paddingRatio : (high.abs() * 0.01) + 1;

    return PriceScale(
      minPrice: low - padding,
      maxPrice: high + padding,
      height: height,
    );
  }

  /// The price span covered by this scale.
  double get priceRange => maxPrice - minPrice;

  /// Converts a price into a scene `y` coordinate.
  ///
  /// Prices outside `[minPrice, maxPrice]` map outside `[0, height]`; this is
  /// intentional so a live candle stays geometrically correct until the next
  /// rescale.
  double yOf(double price) {
    if (priceRange <= 0) return height / 2;
    return ((price - minPrice) / priceRange) * height;
  }

  /// Converts a scene `y` coordinate back into a price.
  double priceOf(double y) {
    if (height <= 0) return minPrice;
    return minPrice + (y / height) * priceRange;
  }

  /// Whether [price] falls inside the range this scale was built for.
  bool covers(double price) => price >= minPrice && price <= maxPrice;

  /// Whether the full high/low range of [candle] fits inside this scale.
  bool coversCandle(Candle candle) => covers(candle.low) && covers(candle.high);

  /// Creates a copy of this scale with the given fields replaced.
  PriceScale copyWith({double? minPrice, double? maxPrice, double? height}) {
    return PriceScale(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      height: height ?? this.height,
    );
  }

  @override
  List<Object?> get props => [minPrice, maxPrice, height];
}
