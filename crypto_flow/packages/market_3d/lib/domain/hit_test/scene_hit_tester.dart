import '../models/market_scene.dart';
import '../models/scene_tap.dart';
import 'scene_projector.dart';

/// Resolves a tap on the viewport to a candle in the scene.
///
/// Screen-space rather than ray-picked on purpose: every block's position and
/// size is already deterministic, engine-agnostic data, so projecting those
/// boxes with the camera's own matrices answers the question without needing
/// an engine's ray-intersection API — and keeps the whole decision in code a
/// unit test can drive.
///
/// The trade-off is that a block is tested as its screen-space bounding box,
/// not its exact silhouette, and occlusion is approximated by depth ordering
/// rather than resolved per pixel. At city scale a candle is a handful of
/// pixels wide, so the box *is* the silhouette for practical purposes, and the
/// nearest overlapping candle is the one a user means.
class SceneHitTester {
  /// How far outside a candle's bounds a tap still counts, in logical pixels.
  ///
  /// A candle in a 100-block city is only a few pixels wide — narrower than a
  /// fingertip — so an exact-bounds-only test would read as unresponsive. The
  /// slop is only consulted when nothing was hit exactly, so it never steals a
  /// tap that landed squarely on a candle.
  final double touchSlop;

  const SceneHitTester({this.touchSlop = 14.0});

  /// Returns the tap for viewport position ([tapX], [tapY]).
  ///
  /// A tap inside more than one block's bounds resolves to the nearest one.
  /// A tap that hits nothing returns [SceneTap.miss], which is what dismisses
  /// the inspect panel — misses are part of the contract, not an error.
  SceneTap hitTest({
    required MarketScene scene,
    required SceneProjector projector,
    required double tapX,
    required double tapY,
  }) {
    int? exactIndex;
    var exactDepth = double.infinity;

    int? nearIndex;
    var nearDistance = double.infinity;
    var nearDepth = double.infinity;

    for (final block in scene.blocks) {
      final bounds = projector.boundsOf(block);
      if (bounds == null) continue;

      if (bounds.contains(tapX, tapY)) {
        if (bounds.depth < exactDepth) {
          exactDepth = bounds.depth;
          exactIndex = block.index;
        }
        continue;
      }

      // Only worth measuring while no exact hit has been found.
      if (exactIndex != null) continue;

      final distance = bounds.distanceTo(tapX, tapY);
      if (distance > touchSlop) continue;
      if (distance < nearDistance ||
          (distance == nearDistance && bounds.depth < nearDepth)) {
        nearDistance = distance;
        nearDepth = bounds.depth;
        nearIndex = block.index;
      }
    }

    return SceneTap(exactIndex ?? nearIndex);
  }
}
