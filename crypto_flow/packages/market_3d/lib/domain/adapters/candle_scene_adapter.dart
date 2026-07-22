import 'package:market/market.dart';

import '../models/candle_block.dart';
import '../models/market_scene.dart';
import '../models/price_scale.dart';
import '../models/scene_layout.dart';
import '../models/vec3.dart';

/// Turns market candles into engine-agnostic scene geometry.
///
/// This is the whole data-to-3D translation: prices become heights, direction
/// becomes colour, series position becomes an x offset. It knows nothing about
/// any rendering engine and is therefore fully unit-testable.
class CandleSceneAdapter {
  /// Geometry parameters applied to every block this adapter builds.
  final SceneLayout layout;

  CandleSceneAdapter({SceneLayout? layout})
      : layout = layout ?? SceneLayout.standard();

  /// Builds a complete scene from [candles], oldest first.
  ///
  /// When [lastCandleIsLive] is true the newest candle is marked live and
  /// brightened, which is the normal case while a kline stream is running.
  MarketScene buildScene({
    required String symbol,
    required String interval,
    required List<Candle> candles,
    bool lastCandleIsLive = true,
  }) {
    if (candles.isEmpty) {
      return MarketScene.empty(
        symbol: symbol,
        interval: interval,
        layout: layout,
      );
    }

    final scale = PriceScale.fromCandles(
      candles,
      height: layout.sceneHeight,
      paddingRatio: layout.pricePaddingRatio,
    );

    final blocks = <CandleBlock>[];
    for (var i = 0; i < candles.length; i++) {
      blocks.add(
        buildBlock(
          candle: candles[i],
          index: i,
          scale: scale,
          isLive: lastCandleIsLive && i == candles.length - 1,
        ),
      );
    }

    return MarketScene(
      symbol: symbol,
      interval: interval,
      blocks: blocks,
      scale: scale,
      layout: layout,
    );
  }

  /// Builds the geometry for a single candle at [index] under [scale].
  CandleBlock buildBlock({
    required Candle candle,
    required int index,
    required PriceScale scale,
    required bool isLive,
  }) {
    final x = index * layout.slotWidth;

    final openY = scale.yOf(candle.open);
    final closeY = scale.yOf(candle.close);
    final highY = scale.yOf(candle.high);
    final lowY = scale.yOf(candle.low);

    final bodyHeight = (closeY - openY).abs();
    final wickHeight = highY - lowY;

    final baseColor =
        candle.isBullish ? layout.palette.bullish : layout.palette.bearish;

    return CandleBlock(
      index: index,
      openTime: candle.openTime,
      bodyCenter: Vec3(x, (openY + closeY) / 2, 0),
      bodySize: Vec3(
        layout.blockWidth,
        bodyHeight < layout.minBodyHeight ? layout.minBodyHeight : bodyHeight,
        layout.blockDepth,
      ),
      wickCenter: Vec3(x, (highY + lowY) / 2, 0),
      wickSize: Vec3(
        layout.wickThickness,
        wickHeight < layout.minBodyHeight ? layout.minBodyHeight : wickHeight,
        layout.wickThickness,
      ),
      bodyColor:
          isLive ? baseColor.scaled(layout.palette.liveBrightness) : baseColor,
      wickColor: layout.palette.wick,
      isBullish: candle.isBullish,
      isLive: isLive,
    );
  }

  /// Builds the live block for [candle] against an existing [scene].
  ///
  /// Reuses the scene's price scale so the rest of the city stays put. The
  /// index is resolved by open time: a candle already in the series updates
  /// that block, a newly opened candle appends one past the end.
  CandleBlock liveBlockFor(MarketScene scene, Candle candle) {
    return buildBlock(
      candle: candle,
      index: _indexFor(scene, candle),
      scale: scene.scale,
      isLive: true,
    );
  }

  /// Applies a live [candle] to [scene], returning the updated scene.
  ///
  /// Callers must check [MarketScene.needsRescaleFor] first: when the candle
  /// has escaped the scene's price range the correct move is a full rebuild
  /// via [buildScene], not an in-place update, because every other block's
  /// height would now be wrong.
  MarketScene applyLiveCandle(MarketScene scene, Candle candle) {
    final block = liveBlockFor(scene, candle);
    final previousLiveIndex = block.index - 1;

    var updated = scene;
    // A newly opened candle freezes the one before it: drop the live
    // brightening so only one block ever reads as live.
    if (block.index == scene.blocks.length && previousLiveIndex >= 0) {
      final previous = scene.blocks[previousLiveIndex];
      if (previous.isLive) {
        updated = updated.withBlock(
          previous.copyWith(
            isLive: false,
            bodyColor: previous.isBullish
                ? layout.palette.bullish
                : layout.palette.bearish,
          ),
        );
      }
    }

    return updated.withBlock(block);
  }

  int _indexFor(MarketScene scene, Candle candle) {
    for (var i = scene.blocks.length - 1; i >= 0; i--) {
      if (scene.blocks[i].openTime == candle.openTime) return i;
    }
    return scene.blocks.length;
  }
}
