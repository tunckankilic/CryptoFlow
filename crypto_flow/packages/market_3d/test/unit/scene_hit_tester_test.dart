import 'package:flutter_test/flutter_test.dart';
import 'package:market/market.dart';
import 'package:market_3d/market_3d.dart';
import 'package:vector_math/vector_math_64.dart';

import '../helpers/candle_fixtures.dart';

/// Viewport the tests project into — deliberately not square, so a bug that
/// swaps width and height cannot pass.
const double _viewportWidth = 400;
const double _viewportHeight = 800;

/// Builds the same kind of `projection * view` matrix the renderer reads off
/// its live camera, using vector_math's own helpers rather than reimplementing
/// them, so the test exercises [SceneProjector]'s conversion and nothing else.
Matrix4 viewProjection({
  required Vector3 eye,
  required Vector3 focus,
  double fovYDegrees = 45,
}) {
  final projection = makePerspectiveMatrix(
    radians(fovYDegrees),
    _viewportWidth / _viewportHeight,
    0.1,
    1000,
  );
  final view = makeViewMatrix(eye, focus, Vector3(0, 1, 0));
  return projection.multiplied(view);
}

SceneProjector projectorFor(
  Matrix4 matrix, {
  double seriesOffsetX = 0,
}) {
  return SceneProjector(
    viewProjection: matrix,
    viewportWidth: _viewportWidth,
    viewportHeight: _viewportHeight,
    seriesOffsetX: seriesOffsetX,
  );
}

void main() {
  final adapter = CandleSceneAdapter();

  MarketScene sceneOf(List<Candle> candles) => adapter.buildScene(
        symbol: 'BTCUSDT',
        interval: '1m',
        candles: candles,
        lastCandleIsLive: false,
      );

  final threeCandles = [
    candleAt(0, open: 100, high: 106, low: 98, close: 104),
    candleAt(1, open: 104, high: 112, low: 103, close: 110),
    candleAt(2, open: 110, high: 118, low: 108, close: 109),
  ];

  group('SceneProjector', () {
    test('projects the point the camera looks at to the viewport centre', () {
      final projector = projectorFor(
        viewProjection(eye: Vector3(0, 0, 10), focus: Vector3.zero()),
      );

      final point = projector.project(const Vec3(0, 0, 0));

      expect(point, isNotNull);
      expect(point!.x, closeTo(_viewportWidth / 2, 0.001));
      expect(point.y, closeTo(_viewportHeight / 2, 0.001));
      expect(point.depth, closeTo(10, 0.001));
    });

    test('maps world +y to a smaller screen y (screen space points down)', () {
      final projector = projectorFor(
        viewProjection(eye: Vector3(0, 0, 10), focus: Vector3.zero()),
      );

      final above = projector.project(const Vec3(0, 1, 0))!;
      final right = projector.project(const Vec3(1, 0, 0))!;

      expect(above.y, lessThan(_viewportHeight / 2));
      expect(right.x, greaterThan(_viewportWidth / 2));
    });

    test('returns null for a point behind the camera', () {
      final projector = projectorFor(
        viewProjection(eye: Vector3(0, 0, 10), focus: Vector3.zero()),
      );

      expect(projector.project(const Vec3(0, 0, 40)), isNull);
    });

    test('applies the series offset to block bounds', () {
      final scene = sceneOf(threeCandles);
      final matrix = viewProjection(
        eye: Vector3(0, 5, 25),
        focus: Vector3(0, 5, 0),
      );
      final block = scene.blocks[2];

      final centred = projectorFor(matrix).boundsOf(block)!;
      final shifted = projectorFor(
        matrix,
        seriesOffsetX: scene.seriesCenterOffsetX,
      ).boundsOf(block)!;

      // seriesCenterOffsetX is negative, so the city moves left on screen.
      expect(shifted.left, lessThan(centred.left));
    });
  });

  group('SceneHitTester', () {
    const hitTester = SceneHitTester();

    /// Centre of [block] in viewport coordinates — where a user aiming at that
    /// candle would actually put their finger.
    ({double x, double y}) screenCentreOf(
      SceneProjector projector,
      CandleBlock block,
    ) {
      final bounds = projector.boundsOf(block)!;
      return (
        x: (bounds.left + bounds.right) / 2,
        y: (bounds.top + bounds.bottom) / 2,
      );
    }

    test('resolves a tap on each candle to that candle', () {
      final scene = sceneOf(threeCandles);
      final projector = projectorFor(
        viewProjection(eye: Vector3(0, 6, 24), focus: Vector3(0, 5, 0)),
        seriesOffsetX: scene.seriesCenterOffsetX,
      );

      for (final block in scene.blocks) {
        final centre = screenCentreOf(projector, block);
        final tap = hitTester.hitTest(
          scene: scene,
          projector: projector,
          tapX: centre.x,
          tapY: centre.y,
        );

        expect(tap.hitBlock, isTrue);
        expect(tap.blockIndex, block.index, reason: 'block ${block.index}');
      }
    });

    test('reports a miss for empty space well away from the city', () {
      final scene = sceneOf(threeCandles);
      final projector = projectorFor(
        viewProjection(eye: Vector3(0, 6, 24), focus: Vector3(0, 5, 0)),
        seriesOffsetX: scene.seriesCenterOffsetX,
      );

      final tap = hitTester.hitTest(
        scene: scene,
        projector: projector,
        tapX: 8,
        tapY: _viewportHeight - 8,
      );

      expect(tap.hitBlock, isFalse);
      expect(tap.blockIndex, isNull);
    });

    test('picks the nearest candle when several line up behind each other', () {
      // Three identical candles viewed straight down the x axis: every block
      // sits on the camera's view axis, so all three project onto the same
      // point and their bounds all contain the tap. Only the depth ordering
      // can separate them, and the camera is on -x, so block 0 is nearest.
      final identical = [
        candleAt(0, open: 100, high: 110, low: 90, close: 105),
        candleAt(1, open: 100, high: 110, low: 90, close: 105),
        candleAt(2, open: 100, high: 110, low: 90, close: 105),
      ];
      final scene = sceneOf(identical);
      final projector = projectorFor(
        viewProjection(eye: Vector3(-30, 5, 0), focus: Vector3(0, 5, 0)),
        seriesOffsetX: scene.seriesCenterOffsetX,
      );

      final centre = screenCentreOf(projector, scene.blocks[1]);

      // Guard the premise: if the blocks did not actually overlap, the test
      // below would pass without ever exercising the depth tie-break.
      for (final block in scene.blocks) {
        expect(
          projector.boundsOf(block)!.contains(centre.x, centre.y),
          isTrue,
          reason: 'block ${block.index} should overlap the tap',
        );
      }

      final tap = hitTester.hitTest(
        scene: scene,
        projector: projector,
        tapX: centre.x,
        tapY: centre.y,
      );

      expect(tap.blockIndex, 0);
    });

    test('falls back to the nearest candle within the touch slop', () {
      final scene = sceneOf(threeCandles);
      final projector = projectorFor(
        viewProjection(eye: Vector3(0, 6, 24), focus: Vector3(0, 5, 0)),
        seriesOffsetX: scene.seriesCenterOffsetX,
      );
      final bounds = projector.boundsOf(scene.blocks[0])!;

      // Just outside block 0's left edge, and further from every other block.
      const slop = 6.0;
      final tap = hitTester.hitTest(
        scene: scene,
        projector: projector,
        tapX: bounds.left - slop,
        tapY: (bounds.top + bounds.bottom) / 2,
      );

      expect(tap.blockIndex, 0);
    });

    test('an empty scene always misses', () {
      final scene = MarketScene.empty(symbol: 'BTCUSDT', interval: '1m');
      final projector = projectorFor(
        viewProjection(eye: Vector3(0, 5, 20), focus: Vector3(0, 5, 0)),
      );

      final tap = hitTester.hitTest(
        scene: scene,
        projector: projector,
        tapX: _viewportWidth / 2,
        tapY: _viewportHeight / 2,
      );

      expect(tap.blockIndex, isNull);
    });
  });
}
