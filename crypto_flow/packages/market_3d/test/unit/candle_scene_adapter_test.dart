import 'package:flutter_test/flutter_test.dart';
import 'package:market/market.dart';
import 'package:market_3d/market_3d.dart';

import '../helpers/candle_fixtures.dart';

void main() {
  final adapter = CandleSceneAdapter();
  final layout = adapter.layout;

  List<Candle> risingSeries() => [
        candleAt(0, open: 100, high: 106, low: 98, close: 104),
        candleAt(1, open: 104, high: 112, low: 103, close: 110),
        candleAt(2, open: 110, high: 118, low: 108, close: 109),
      ];

  MarketScene sceneOf(List<Candle> candles) => adapter.buildScene(
        symbol: 'BTCUSDT',
        interval: '1m',
        candles: candles,
      );

  group('buildScene', () {
    test('creates one block per candle, in series order', () {
      final scene = sceneOf(risingSeries());

      expect(scene.blocks, hasLength(3));
      expect(scene.blocks.map((b) => b.index), [0, 1, 2]);
      expect(
        scene.blocks.map((b) => b.openTime),
        risingSeries().map((c) => c.openTime),
      );
    });

    test('lays blocks out one slot apart along x', () {
      final scene = sceneOf(risingSeries());

      expect(scene.blocks[0].bodyCenter.x, 0);
      expect(scene.blocks[1].bodyCenter.x, closeTo(layout.slotWidth, 1e-9));
      expect(scene.blocks[2].bodyCenter.x, closeTo(layout.slotWidth * 2, 1e-9));
    });

    test('scales body height by price movement', () {
      final scene = sceneOf(risingSeries());
      final scale = scene.scale;

      final second = scene.blocks[1];
      final expectedHeight = (scale.yOf(110) - scale.yOf(104)).abs();

      expect(second.bodySize.y, closeTo(expectedHeight, 1e-9));
      expect(
        second.bodyCenter.y,
        closeTo((scale.yOf(104) + scale.yOf(110)) / 2, 1e-9),
      );
    });

    test('spans the wick from low to high', () {
      final scene = sceneOf(risingSeries());
      final scale = scene.scale;
      final first = scene.blocks[0];

      expect(first.bottom, closeTo(scale.yOf(98), 1e-9));
      expect(first.top, closeTo(scale.yOf(106), 1e-9));
      expect(first.wickSize.x, closeTo(layout.wickThickness, 1e-9));
    });

    test('colours bullish and bearish candles differently', () {
      final scene = adapter.buildScene(
        symbol: 'BTCUSDT',
        interval: '1m',
        candles: risingSeries(),
        lastCandleIsLive: false,
      );

      expect(scene.blocks[0].isBullish, isTrue);
      expect(scene.blocks[0].bodyColor, layout.palette.bullish);
      expect(scene.blocks[2].isBullish, isFalse);
      expect(scene.blocks[2].bodyColor, layout.palette.bearish);
    });

    test('brightens the live candle only', () {
      final scene = sceneOf(risingSeries());

      expect(scene.blocks[0].isLive, isFalse);
      expect(scene.blocks.last.isLive, isTrue);
      expect(
        scene.blocks.last.bodyColor.r,
        greaterThan(layout.palette.bearish.r),
      );
    });

    test('gives a doji a minimum visible body', () {
      final scene = sceneOf([
        candleAt(0, open: 100, high: 101, low: 99, close: 100),
      ]);

      expect(scene.blocks.first.bodySize.y, layout.minBodyHeight);
    });

    test('returns an empty scene for no candles', () {
      final scene = adapter.buildScene(
        symbol: 'BTCUSDT',
        interval: '1m',
        candles: const [],
      );

      expect(scene.isEmpty, isTrue);
      expect(scene.liveBlock, isNull);
      expect(scene.seriesCenterOffsetX, 0);
    });

    test('centres the city through the root offset, not block positions', () {
      final scene = sceneOf(risingSeries());

      expect(scene.seriesCenterOffsetX, closeTo(-layout.slotWidth, 1e-9));
    });
  });

  group('applyLiveCandle', () {
    test('updates the open candle in place without touching the others', () {
      final scene = sceneOf(risingSeries());
      final grown = candleAt(2, open: 110, high: 118, low: 108, close: 116);

      final updated = adapter.applyLiveCandle(scene, grown);

      expect(updated.blocks, hasLength(3));
      expect(updated.blocks[0], scene.blocks[0]);
      expect(updated.blocks[1], scene.blocks[1]);
      expect(updated.blocks[2].isLive, isTrue);
      expect(
        updated.blocks[2].bodyCenter.y,
        greaterThan(scene.blocks[2].bodyCenter.y),
      );
    });

    test('reuses the existing scale so the city stays put', () {
      final scene = sceneOf(risingSeries());
      final grown = candleAt(2, open: 110, high: 118, low: 108, close: 116);

      final updated = adapter.applyLiveCandle(scene, grown);

      expect(updated.scale, scene.scale);
      expect(updated.blocks[2].bodyCenter.x, scene.blocks[2].bodyCenter.x);
    });

    test('appends a newly opened candle and freezes the previous one', () {
      final scene = sceneOf(risingSeries());
      final opened = candleAt(3, open: 109, high: 110, low: 109, close: 109.5);

      final updated = adapter.applyLiveCandle(scene, opened);

      expect(updated.blocks, hasLength(4));
      expect(updated.blocks[3].isLive, isTrue);
      expect(updated.blocks[2].isLive, isFalse);
      expect(updated.blocks[2].bodyColor, layout.palette.bearish);
      expect(
        updated.blocks[3].bodyCenter.x,
        closeTo(layout.slotWidth * 3, 1e-9),
      );
    });

    test('leaves already placed blocks at the same x after an append', () {
      final scene = sceneOf(risingSeries());
      final opened = candleAt(3, open: 109, high: 110, low: 109, close: 109.5);

      final updated = adapter.applyLiveCandle(scene, opened);

      for (var i = 0; i < scene.blocks.length; i++) {
        expect(updated.blocks[i].bodyCenter.x, scene.blocks[i].bodyCenter.x);
      }
      expect(updated.seriesCenterOffsetX, lessThan(scene.seriesCenterOffsetX));
    });
  });

  group('needsRescaleFor', () {
    test('is false while the live candle stays inside the range', () {
      final scene = sceneOf(risingSeries());
      final inRange = candleAt(2, open: 110, high: 118, low: 108, close: 117);

      expect(scene.needsRescaleFor(inRange), isFalse);
    });

    test('is true once the live candle breaks out of the range', () {
      final scene = sceneOf(risingSeries());
      final breakout = candleAt(2, open: 110, high: 400, low: 108, close: 390);

      expect(scene.needsRescaleFor(breakout), isTrue);
    });
  });

  group('MarketScene.withBlock', () {
    test('rejects a block that would leave a gap in the series', () {
      final scene = sceneOf(risingSeries());
      final stray = scene.blocks.first.copyWith(index: 9);

      expect(() => scene.withBlock(stray), throwsRangeError);
    });
  });
}
