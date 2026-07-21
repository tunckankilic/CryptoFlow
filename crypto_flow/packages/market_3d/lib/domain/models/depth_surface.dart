import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'scene_color.dart';
import 'vec3.dart';

/// Geometry parameters for the order book depth terrain.
@immutable
class DepthLayout extends Equatable {
  /// Width along the x axis covered by one side of the book.
  final double sideWidth;

  /// Depth along the z axis of the terrain strip.
  final double sideDepth;

  /// Scene height the largest cumulative volume maps to.
  final double maxHeight;

  /// Gap along the x axis between the bid and ask sides, centred on the mid
  /// price so the spread reads as a visible valley.
  final double spreadGap;

  /// Colour of the bid (buy) side.
  final SceneColor bidColor;

  /// Colour of the ask (sell) side.
  final SceneColor askColor;

  const DepthLayout({
    this.sideWidth = 5.0,
    this.sideDepth = 3.0,
    this.maxHeight = 4.0,
    this.spreadGap = 0.4,
    required this.bidColor,
    required this.askColor,
  });

  /// Default layout, colour-matched to the candle palette.
  factory DepthLayout.standard() {
    return DepthLayout(
      bidColor: SceneColor.fromBytes(38, 166, 154),
      askColor: SceneColor.fromBytes(239, 83, 80),
    );
  }

  /// Creates a copy of this layout with the given fields replaced.
  DepthLayout copyWith({
    double? sideWidth,
    double? sideDepth,
    double? maxHeight,
    double? spreadGap,
    SceneColor? bidColor,
    SceneColor? askColor,
  }) {
    return DepthLayout(
      sideWidth: sideWidth ?? this.sideWidth,
      sideDepth: sideDepth ?? this.sideDepth,
      maxHeight: maxHeight ?? this.maxHeight,
      spreadGap: spreadGap ?? this.spreadGap,
      bidColor: bidColor ?? this.bidColor,
      askColor: askColor ?? this.askColor,
    );
  }

  @override
  List<Object?> get props =>
      [sideWidth, sideDepth, maxHeight, spreadGap, bidColor, askColor];
}

/// One price level of the depth terrain.
@immutable
class DepthSample extends Equatable {
  /// Price level from the order book.
  final double price;

  /// Quantity resting at this exact level.
  final double quantity;

  /// Total quantity at this level and every level closer to the mid price.
  final double cumulativeQuantity;

  /// Surface vertex for this level: `x` from the price offset, `y` equal to
  /// the scaled cumulative volume, `z` on the terrain's centre line.
  final Vec3 position;

  const DepthSample({
    required this.price,
    required this.quantity,
    required this.cumulativeQuantity,
    required this.position,
  });

  /// Height of the surface at this level.
  double get height => position.y;

  @override
  List<Object?> get props => [price, quantity, cumulativeQuantity, position];
}

/// Bid and ask depth rendered as a two-sided surface.
@immutable
class DepthSurface extends Equatable {
  /// Trading pair the surface was built from.
  final String symbol;

  /// Mid price, mapped to `x = 0`.
  final double midPrice;

  /// Bid levels, nearest the mid price first.
  final List<DepthSample> bids;

  /// Ask levels, nearest the mid price first.
  final List<DepthSample> asks;

  /// Largest cumulative quantity on either side, used to normalise heights.
  final double maxCumulativeQuantity;

  /// Geometry parameters used to build the samples.
  final DepthLayout layout;

  const DepthSurface({
    required this.symbol,
    required this.midPrice,
    required this.bids,
    required this.asks,
    required this.maxCumulativeQuantity,
    required this.layout,
  });

  /// An empty surface, used before the first order book snapshot arrives.
  factory DepthSurface.empty({String symbol = '', DepthLayout? layout}) {
    return DepthSurface(
      symbol: symbol,
      midPrice: 0,
      bids: const [],
      asks: const [],
      maxCumulativeQuantity: 0,
      layout: layout ?? DepthLayout.standard(),
    );
  }

  /// Whether the surface has any geometry.
  bool get isEmpty => bids.isEmpty && asks.isEmpty;

  @override
  List<Object?> get props =>
      [symbol, midPrice, bids, asks, maxCumulativeQuantity, layout];
}
