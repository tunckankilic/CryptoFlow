import 'package:flutter_test/flutter_test.dart';
import 'package:market_3d/data/renderers/candle_mesh.dart';
import 'package:market_3d/market_3d.dart';

/// A block with body and wick sizes that are all distinct and none of them 1,
/// so a dropped or doubled factor cannot pass by coincidence.
CandleBlock blockUnderTest() {
  return CandleBlock(
    index: 3,
    openTime: DateTime.utc(2026, 1, 1),
    bodyCenter: const Vec3(6.0, 2.5, 0.0),
    bodySize: const Vec3(0.8, 3.0, 0.6),
    wickCenter: const Vec3(6.0, 3.0, 0.0),
    wickSize: const Vec3(0.12, 5.0, 0.12),
    bodyColor: const SceneColor(0.15, 0.72, 0.45),
    wickColor: const SceneColor(0.15, 0.72, 0.45),
    isBullish: true,
    isLive: false,
  );
}

/// Min and max of the mesh along [axis] (0 = x, 1 = y, 2 = z).
({double min, double max}) _extent(List<double> vertices, int axis) {
  var min = double.infinity;
  var max = double.negativeInfinity;
  for (var i = axis; i < vertices.length; i += 3) {
    if (vertices[i] < min) min = vertices[i];
    if (vertices[i] > max) max = vertices[i];
  }
  return (min: min, max: max);
}

void main() {
  group('CandleMesh.build', () {
    test('emits two boxes worth of vertices and indices', () {
      final geometry = CandleMesh.build(blockUnderTest());

      // 2 boxes x 6 faces x 4 corners, with one normal per vertex.
      expect(geometry.vertices.length, 2 * 24 * 3);
      expect(geometry.normals.length, 2 * 24 * 3);
      // 2 boxes x 6 faces x 2 triangles x 3 corners.
      expect(geometry.indices.length, 2 * 36);
    });

    test('every index addresses a vertex that exists', () {
      final geometry = CandleMesh.build(blockUnderTest());
      final vertexCount = geometry.vertices.length ~/ 3;

      expect(geometry.indices.every((i) => i >= 0 && i < vertexCount), isTrue);
    });

    test('bakes true extents into the vertices, not half of them', () {
      final block = blockUnderTest();
      final geometry = CandleMesh.build(block);
      final vertices = geometry.vertices.toList();

      // The wick is the tallest and thinnest part, so the mesh's overall
      // height is the wick's and its width is the body's. Both must equal the
      // block's stated full extent: `GeometryUtils.cube` spans -1..1, so a
      // renderer that scales it by `size` silently doubles every candle.
      final height = _extent(vertices, 1);
      expect(height.max - height.min, closeTo(block.wickSize.y, 1e-6));

      final width = _extent(vertices, 0);
      expect(width.max - width.min, closeTo(block.bodySize.x, 1e-6));

      final depth = _extent(vertices, 2);
      expect(depth.max - depth.min, closeTo(block.bodySize.z, 1e-6));
    });

    test('positions vertices relative to the block ground origin', () {
      final block = blockUnderTest();
      final geometry = CandleMesh.build(block);
      final vertices = geometry.vertices.toList();

      // x/z are relative to the candle's slot, so the mesh straddles zero on
      // both, and only the transform carries the candle down the series.
      final width = _extent(vertices, 0);
      expect(width.min, closeTo(-block.bodySize.x / 2, 1e-6));
      expect(width.max, closeTo(block.bodySize.x / 2, 1e-6));

      // y stays absolute: the ground plane is the origin, so the wick bottom
      // sits at the candle's low and nothing is buried under the floor.
      final height = _extent(vertices, 1);
      expect(height.min, closeTo(block.bottom, 1e-6));
      expect(height.max, closeTo(block.top, 1e-6));

      expect(CandleMesh.originOf(block).x, block.bodyCenter.x);
      expect(CandleMesh.originOf(block).y, 0);
    });

    test('gives each face its own outward normal', () {
      final geometry = CandleMesh.build(blockUnderTest());
      final normals = geometry.normals.toList();

      // Face normals are axis-aligned unit vectors; a shared-corner cube would
      // average them into diagonals and round the candle's edges off.
      for (var i = 0; i < normals.length; i += 3) {
        final length =
            normals[i] * normals[i] +
            normals[i + 1] * normals[i + 1] +
            normals[i + 2] * normals[i + 2];
        expect(length, closeTo(1.0, 1e-6));
        expect(
          normals.sublist(i, i + 3).where((c) => c != 0).length,
          1,
          reason: 'normal at vertex ${i ~/ 3} is not axis-aligned',
        );
      }
    });
  });
}
