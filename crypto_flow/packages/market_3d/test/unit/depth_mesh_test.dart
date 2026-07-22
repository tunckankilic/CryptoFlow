import 'package:flutter_test/flutter_test.dart';
import 'package:market_3d/data/renderers/depth_mesh.dart';
import 'package:market_3d/market_3d.dart';

import '../helpers/candle_fixtures.dart';

/// A book deep enough to exercise several segments per side, with distinct
/// quantities so a dropped or duplicated level cannot pass by coincidence.
final _book = orderBook(
  bids: [
    [99.0, 2.0],
    [98.0, 3.0],
    [97.0, 5.0],
    [95.0, 1.0],
  ],
  asks: [
    [101.0, 1.0],
    [102.0, 2.0],
    [104.0, 4.0],
    [108.0, 6.0],
  ],
);

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
  final adapter = DepthSceneAdapter();
  final surface = adapter.buildSurface(_book);
  final layout = adapter.layout;

  group('DepthMesh.buildSide', () {
    test('returns null for a side that cannot form a ribbon', () {
      // One level has no segment to extrude along, and no level has nothing
      // to extrude at all — both are skipped rather than handed to the engine
      // as an empty buffer.
      expect(DepthMesh.buildSide(const [], layout), isNull);
      expect(DepthMesh.buildSide([surface.bids.first], layout), isNull);
    });

    test('emits one normal per vertex and whole triangles', () {
      for (final samples in [surface.bids, surface.asks]) {
        final geometry = DepthMesh.buildSide(samples, layout)!;

        expect(geometry.vertices.length % 3, 0);
        expect(geometry.normals.length, geometry.vertices.length);
        expect(geometry.indices.length % 3, 0);
      }
    });

    test('every index addresses a vertex that exists', () {
      for (final samples in [surface.bids, surface.asks]) {
        final geometry = DepthMesh.buildSide(samples, layout)!;
        final vertexCount = geometry.vertices.length ~/ 3;

        expect(
          geometry.indices.every((i) => i >= 0 && i < vertexCount),
          isTrue,
        );
      }
    });

    test('winds every triangle to face the way its normals point', () {
      // The single mistake this mesh is prone to: eight differently-oriented
      // faces, and a back-facing triangle is invisible rather than visibly
      // wrong, so it would survive a screenshot check. Comparing each
      // triangle's geometric normal against its stored vertex normals catches
      // it without a device.
      for (final samples in [surface.bids, surface.asks]) {
        final geometry = DepthMesh.buildSide(samples, layout)!;
        final vertices = geometry.vertices;
        final normals = geometry.normals;

        for (var t = 0; t < geometry.indices.length; t += 3) {
          final a = geometry.indices[t] * 3;
          final b = geometry.indices[t + 1] * 3;
          final c = geometry.indices[t + 2] * 3;

          final ux = vertices[b] - vertices[a];
          final uy = vertices[b + 1] - vertices[a + 1];
          final uz = vertices[b + 2] - vertices[a + 2];
          final vx = vertices[c] - vertices[a];
          final vy = vertices[c + 1] - vertices[a + 1];
          final vz = vertices[c + 2] - vertices[a + 2];

          final nx = uy * vz - uz * vy;
          final ny = uz * vx - ux * vz;
          final nz = ux * vy - uy * vx;

          final dot =
              nx * normals[a] + ny * normals[a + 1] + nz * normals[a + 2];

          expect(
            dot,
            greaterThan(0),
            reason: 'triangle at index $t is wound against its own normal',
          );
        }
      }
    });

    test('normals are unit length', () {
      final geometry = DepthMesh.buildSide(surface.asks, layout)!;

      for (var i = 0; i < geometry.normals.length; i += 3) {
        final n = geometry.normals;
        final length2 =
            n[i] * n[i] + n[i + 1] * n[i + 1] + n[i + 2] * n[i + 2];
        expect(length2, closeTo(1.0, 1e-6));
      }
    });

    test('extrudes across the full layout depth and rests on the ground', () {
      final geometry = DepthMesh.buildSide(surface.asks, layout)!;
      final vertices = geometry.vertices.toList();

      final depth = _extent(vertices, 2);
      expect(depth.min, closeTo(-layout.sideDepth / 2, 1e-6));
      expect(depth.max, closeTo(layout.sideDepth / 2, 1e-6));

      // The ribbon is a solid standing on the ground plane, not a floating
      // curve: nothing dips below y = 0 and the base touches it.
      final height = _extent(vertices, 1);
      expect(height.min, closeTo(0.0, 1e-9));
      expect(height.max, closeTo(surface.asks.last.height, 1e-6));
    });

    test('spans exactly the price range its samples cover', () {
      final geometry = DepthMesh.buildSide(surface.bids, layout)!;
      final width = _extent(geometry.vertices.toList(), 0);

      expect(width.max, closeTo(surface.bids.first.position.x, 1e-6));
      expect(width.min, closeTo(surface.bids.last.position.x, 1e-6));
    });

    test('keeps the two sides on opposite sides of the mid price', () {
      final bids = _extent(DepthMesh.buildSide(surface.bids, layout)!
          .vertices
          .toList(), 0);
      final asks = _extent(DepthMesh.buildSide(surface.asks, layout)!
          .vertices
          .toList(), 0);

      expect(bids.max, lessThan(0));
      expect(asks.min, greaterThan(0));
    });

    test('survives a book with no resting quantity', () {
      // Every sample sits at y = 0, so the z faces and end caps are all
      // degenerate. What is left is a flat ribbon on the ground, not a crash
      // and not a buffer full of NaN normals from normalising a zero vector.
      final flat = adapter.buildSurface(orderBook(
        bids: [
          [99.0, 0.0],
          [98.0, 0.0],
        ],
        asks: [
          [101.0, 0.0],
          [102.0, 0.0],
        ],
      ));

      final geometry = DepthMesh.buildSide(flat.bids, layout)!;

      expect(geometry.indices, isNotEmpty);
      expect(geometry.normals.every((n) => !n.isNaN), isTrue);
      expect(_extent(geometry.vertices.toList(), 1).max, 0.0);
    });
  });
}
