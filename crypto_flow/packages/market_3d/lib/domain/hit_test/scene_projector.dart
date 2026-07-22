import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart';

import '../models/candle_block.dart';
import '../models/vec3.dart';

/// A projected point in viewport coordinates.
///
/// [x]/[y] are logical pixels with the origin in the top-left corner, matching
/// Flutter's `localPosition`, not the engine's y-up normalised device space.
/// [depth] is the point's distance along the camera's view axis (the clip-space
/// `w`), so a smaller value is nearer the camera.
@immutable
class ScreenPoint {
  final double x;
  final double y;
  final double depth;

  const ScreenPoint(this.x, this.y, this.depth);
}

/// The axis-aligned screen-space box a block occupies.
@immutable
class ScreenBounds {
  final double left;
  final double top;
  final double right;
  final double bottom;

  /// Depth of the block's centre — used to pick the nearest block when
  /// several overlap under the same tap.
  final double depth;

  const ScreenBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.depth,
  });

  /// Whether ([x], [y]) falls inside the box.
  bool contains(double x, double y) =>
      x >= left && x <= right && y >= top && y <= bottom;

  /// Shortest distance from ([x], [y]) to the box, `0` when inside.
  double distanceTo(double x, double y) {
    final dx = x < left
        ? left - x
        : x > right
            ? x - right
            : 0.0;
    final dy = y < top
        ? top - y
        : y > bottom
            ? y - bottom
            : 0.0;
    if (dx == 0 && dy == 0) return 0;
    return math.sqrt(dx * dx + dy * dy);
  }
}

/// Projects scene geometry into viewport coordinates.
///
/// Deliberately engine-agnostic: it takes a view-projection matrix and a
/// viewport size and does the rest in plain maths, so hit-testing is
/// unit-testable without a live engine. The renderer supplies the matrix its
/// own camera is currently using rather than this class guessing a field of
/// view — the numbers are the engine's, the geometry is ours.
class SceneProjector {
  /// `projection * view` for the camera the scene is currently drawn with.
  final Matrix4 viewProjection;

  /// Viewport width in the same units as the tap coordinates (logical pixels).
  final double viewportWidth;

  /// Viewport height in the same units as the tap coordinates.
  final double viewportHeight;

  /// The x translation the renderer applied to the whole city, i.e. the
  /// scene's `seriesCenterOffsetX` frozen at the last full scene build.
  ///
  /// Block positions are absolute in series space, so this is the difference
  /// between where a block thinks it is and where it is actually drawn.
  final double seriesOffsetX;

  const SceneProjector({
    required this.viewProjection,
    required this.viewportWidth,
    required this.viewportHeight,
    this.seriesOffsetX = 0,
  });

  /// Projects a world-space point, or returns `null` when it sits behind the
  /// camera (a non-positive clip `w`, which would otherwise mirror the point
  /// onto the visible half of the screen).
  ScreenPoint? project(Vec3 point) => _project(point.x, point.y, point.z);

  /// The screen-space box covering [block]'s body and wick.
  ///
  /// Returns `null` when any corner falls behind the camera — a partially
  /// clipped candle is not worth hit-testing precisely, and treating it as a
  /// miss is safer than reporting a mirrored box somewhere on screen.
  ScreenBounds? boundsOf(CandleBlock block) {
    final centerX = block.bodyCenter.x + seriesOffsetX;
    final centerZ = block.bodyCenter.z;
    final halfWidth = math.max(block.bodySize.x, block.wickSize.x) / 2;
    final halfDepth = math.max(block.bodySize.z, block.wickSize.z) / 2;

    final bodyTop = block.bodyCenter.y + block.bodySize.y / 2;
    final bodyBottom = block.bodyCenter.y - block.bodySize.y / 2;
    final minY = math.min(block.bottom, bodyBottom);
    final maxY = math.max(block.top, bodyTop);

    var left = double.infinity;
    var top = double.infinity;
    var right = double.negativeInfinity;
    var bottom = double.negativeInfinity;

    for (final x in [centerX - halfWidth, centerX + halfWidth]) {
      for (final y in [minY, maxY]) {
        for (final z in [centerZ - halfDepth, centerZ + halfDepth]) {
          final corner = _project(x, y, z);
          if (corner == null) return null;
          if (corner.x < left) left = corner.x;
          if (corner.x > right) right = corner.x;
          if (corner.y < top) top = corner.y;
          if (corner.y > bottom) bottom = corner.y;
        }
      }
    }

    final center = _project(centerX, (minY + maxY) / 2, centerZ);
    if (center == null) return null;

    return ScreenBounds(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      depth: center.depth,
    );
  }

  ScreenPoint? _project(double x, double y, double z) {
    final clip = viewProjection.transformed(Vector4(x, y, z, 1.0));
    if (clip.w <= 1e-6) return null;

    final ndcX = clip.x / clip.w;
    final ndcY = clip.y / clip.w;

    // Normalised device coordinates run -1..1 with y pointing up; viewport
    // coordinates run 0..size with y pointing down.
    return ScreenPoint(
      (ndcX + 1) / 2 * viewportWidth,
      (1 - ndcY) / 2 * viewportHeight,
      clip.w,
    );
  }
}
