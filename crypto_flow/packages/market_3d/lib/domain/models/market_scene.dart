import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:market/market.dart';

import 'candle_block.dart';
import 'price_scale.dart';
import 'scene_layout.dart';

/// A complete candle city, ready to be handed to a renderer.
///
/// Immutable: live updates replace a single block via [withBlock] rather than
/// mutating in place, so a bloc can emit new state without the renderer having
/// to diff the whole scene.
@immutable
class MarketScene extends Equatable {
  /// Trading pair the scene was built from, e.g. `BTCUSDT`.
  final String symbol;

  /// Candle interval the scene was built from, e.g. `1m`.
  final String interval;

  /// Candle geometry, oldest first.
  final List<CandleBlock> blocks;

  /// Price-to-height mapping shared by every block.
  final PriceScale scale;

  /// Geometry parameters used to build the blocks.
  final SceneLayout layout;

  const MarketScene({
    required this.symbol,
    required this.interval,
    required this.blocks,
    required this.scale,
    required this.layout,
  });

  /// An empty scene, used as the initial state before candles arrive.
  factory MarketScene.empty({
    String symbol = '',
    String interval = '',
    SceneLayout? layout,
  }) {
    final resolved = layout ?? SceneLayout.standard();
    return MarketScene(
      symbol: symbol,
      interval: interval,
      blocks: const [],
      scale: PriceScale(
        minPrice: 0,
        maxPrice: 1,
        height: resolved.sceneHeight,
      ),
      layout: resolved,
    );
  }

  /// Whether the scene has any geometry.
  bool get isEmpty => blocks.isEmpty;

  /// The still-open candle, or `null` when the scene has no live block.
  CandleBlock? get liveBlock {
    if (blocks.isEmpty) return null;
    final last = blocks.last;
    return last.isLive ? last : null;
  }

  /// Total width of the city along the x axis.
  double get width => layout.totalWidthFor(blocks.length);

  /// Translation a renderer applies to the whole city to centre it on the
  /// origin.
  ///
  /// Block positions are absolute in series space (`x = index * slotWidth`) so
  /// that appending a candle never moves the blocks that are already on
  /// screen. Centring is a property of the city as a whole, applied once to
  /// its root transform, which is what keeps live updates down to a single
  /// entity per tick.
  double get seriesCenterOffsetX {
    if (blocks.length < 2) return 0;
    return -((blocks.length - 1) * layout.slotWidth) / 2;
  }

  /// Highest point of any wick in the scene, used for camera framing.
  double get topExtent {
    if (blocks.isEmpty) return layout.sceneHeight;
    return blocks.map((b) => b.top).reduce((a, b) => a > b ? a : b);
  }

  /// Returns the block at [index], or `null` when out of range.
  CandleBlock? blockAt(int index) {
    if (index < 0 || index >= blocks.length) return null;
    return blocks[index];
  }

  /// Whether [candle] has escaped the current [scale] and the scene must be
  /// rebuilt instead of updated in place.
  ///
  /// This is the guard that keeps live updates cheap: as long as the live
  /// candle stays inside the range the scene was built for, only its own two
  /// boxes move.
  bool needsRescaleFor(Candle candle) => !scale.coversCandle(candle);

  /// Returns a copy of this scene with [block] replacing the block at the same
  /// index, or appended when it extends the series by one.
  ///
  /// Throws a [RangeError] when [block] would leave a gap in the series.
  MarketScene withBlock(CandleBlock block) {
    if (block.index < 0 || block.index > blocks.length) {
      throw RangeError.index(block.index, blocks, 'block.index');
    }

    final updated = List<CandleBlock>.of(blocks);
    if (block.index == blocks.length) {
      updated.add(block);
    } else {
      updated[block.index] = block;
    }
    return copyWith(blocks: updated);
  }

  /// Creates a copy of this scene with the given fields replaced.
  MarketScene copyWith({
    String? symbol,
    String? interval,
    List<CandleBlock>? blocks,
    PriceScale? scale,
    SceneLayout? layout,
  }) {
    return MarketScene(
      symbol: symbol ?? this.symbol,
      interval: interval ?? this.interval,
      blocks: blocks ?? this.blocks,
      scale: scale ?? this.scale,
      layout: layout ?? this.layout,
    );
  }

  @override
  List<Object?> get props => [symbol, interval, blocks, scale, layout];
}
