import 'dart:math' as math;

import 'package:thermion_flutter/thermion_flutter.dart';

import '../../domain/models/depth_surface.dart';

/// Builds the order book depth terrain as raw vertex data, one mesh per side.
///
/// A side is the cumulative-volume curve of [DepthSurface.bids] or
/// [DepthSurface.asks] extruded along z into a solid ribbon: the sample
/// heights form the top edge, the ground plane forms the bottom, and the two
/// z faces close it in. That is the 2D depth chart every trader already reads,
/// given thickness so it catches the scene's single directional light.
///
/// One [Geometry] per side rather than one per level: the whole bid ribbon is
/// a single colour, so merging it costs one asset and one material instead of
/// twenty of each. Two assets carry the entire terrain.
///
/// Vertices are absolute in surface space (x from the price offset, y the
/// scaled cumulative volume, z the extrusion) — unlike `CandleMesh`, which
/// emits relative to a per-candle origin because individual candles get
/// replaced. A side is only ever rebuilt whole, so there is nothing to gain
/// from a local frame. The renderer's transform places the whole ribbon.
abstract final class DepthMesh {
  /// Builds one side's ribbon, or `null` when [samples] cannot form one.
  ///
  /// A single level has no segment to extrude along, and an empty side has no
  /// geometry at all; both yield `null` so the caller simply skips that side
  /// rather than handing the engine an empty buffer.
  static Geometry? buildSide(List<DepthSample> samples, DepthLayout layout) {
    if (samples.length < 2) return null;

    final halfDepth = layout.sideDepth / 2;

    // Grown rather than pre-sized: degenerate quads are dropped (see [_quad]),
    // so the final count isn't known up front. A 20-level side lands around
    // 230 vertices — small enough that the copy into a [Float32List] at the
    // end is cheaper than the arithmetic to predict the exact size.
    final vertices = <double>[];
    final normals = <double>[];
    final indices = <int>[];

    for (var i = 0; i < samples.length - 1; i++) {
      final x0 = samples[i].position.x;
      final y0 = samples[i].height;
      final x1 = samples[i + 1].position.x;
      final y1 = samples[i + 1].height;

      // Top of the ribbon: follows the cumulative curve's slope.
      _quad(
        vertices,
        normals,
        indices,
        [x0, y0, halfDepth],
        [x1, y1, halfDepth],
        [x1, y1, -halfDepth],
        [x0, y0, -halfDepth],
        outward: const [0.0, 1.0, 0.0],
      );

      // The two z faces, ground to curve.
      _quad(
        vertices,
        normals,
        indices,
        [x0, 0, halfDepth],
        [x1, 0, halfDepth],
        [x1, y1, halfDepth],
        [x0, y0, halfDepth],
        outward: const [0.0, 0.0, 1.0],
      );
      _quad(
        vertices,
        normals,
        indices,
        [x0, 0, -halfDepth],
        [x1, 0, -halfDepth],
        [x1, y1, -halfDepth],
        [x0, y0, -halfDepth],
        outward: const [0.0, 0.0, -1.0],
      );
    }

    // End caps. The inner one faces the mid price across the spread valley,
    // the outer one faces away from it — both derived from the sign of x
    // rather than from a bid/ask flag, so this function needs to know nothing
    // about which side it is building.
    final first = samples.first;
    final last = samples.last;
    _cap(vertices, normals, indices, first, halfDepth, facing: -_sign(first));
    _cap(vertices, normals, indices, last, halfDepth, facing: _sign(last));

    // No bottom face: the ribbon sits flush on the ground plane, and the
    // camera's elevation is clamped above the horizon (see `OrbitCameraState`),
    // so it can never be seen.

    if (indices.isEmpty) return null;

    return Geometry(
      Float32List.fromList(vertices),
      indices,
      normals: Float32List.fromList(normals),
    );
  }

  /// Writes the vertical cap closing the ribbon at [sample]'s price level.
  static void _cap(
    List<double> vertices,
    List<double> normals,
    List<int> indices,
    DepthSample sample,
    double halfDepth, {
    required double facing,
  }) {
    final x = sample.position.x;
    final y = sample.height;
    _quad(
      vertices,
      normals,
      indices,
      [x, 0, -halfDepth],
      [x, 0, halfDepth],
      [x, y, halfDepth],
      [x, y, -halfDepth],
      outward: [facing, 0.0, 0.0],
    );
  }

  static double _sign(DepthSample sample) => sample.position.x < 0 ? -1.0 : 1.0;

  /// Appends one quad, given its four corners in perimeter order.
  ///
  /// The face normal is derived from the corners themselves rather than being
  /// passed in, and [outward] is only a hint used to decide winding: if the
  /// derived normal points away from it, the loop is reversed and the normal
  /// negated. Getting the winding wrong by hand on eight differently-oriented
  /// faces is the easy mistake here, and a back-facing triangle is invisible
  /// rather than obviously broken — so the hint only has to have the right
  /// sign, not the right value.
  ///
  /// A quad whose corners are collinear or coincident (a zero-quantity book
  /// leaves the z faces flat on the ground) has no area and is dropped. That
  /// can never discard a visible triangle: cumulative quantity is
  /// monotonically non-decreasing, so a zero-height far corner implies a
  /// zero-height near one too.
  static void _quad(
    List<double> vertices,
    List<double> normals,
    List<int> indices,
    List<double> p0,
    List<double> p1,
    List<double> p2,
    List<double> p3, {
    required List<double> outward,
  }) {
    final ux = p1[0] - p0[0];
    final uy = p1[1] - p0[1];
    final uz = p1[2] - p0[2];
    final vx = p2[0] - p0[0];
    final vy = p2[1] - p0[1];
    final vz = p2[2] - p0[2];

    var nx = uy * vz - uz * vy;
    var ny = uz * vx - ux * vz;
    var nz = ux * vy - uy * vx;

    final length = math.sqrt(nx * nx + ny * ny + nz * nz);
    if (length < 1e-9) return;

    nx /= length;
    ny /= length;
    nz /= length;

    var corners = [p0, p1, p2, p3];
    if (nx * outward[0] + ny * outward[1] + nz * outward[2] < 0) {
      corners = [p3, p2, p1, p0];
      nx = -nx;
      ny = -ny;
      nz = -nz;
    }

    final firstVertex = vertices.length ~/ 3;
    for (final corner in corners) {
      vertices.addAll(corner);
      normals
        ..add(nx)
        ..add(ny)
        ..add(nz);
    }

    indices.addAll([
      firstVertex,
      firstVertex + 1,
      firstVertex + 2,
      firstVertex,
      firstVertex + 2,
      firstVertex + 3,
    ]);
  }
}
