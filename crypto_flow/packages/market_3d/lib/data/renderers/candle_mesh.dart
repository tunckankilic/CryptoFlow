import 'package:thermion_flutter/thermion_flutter.dart';

import '../../domain/models/candle_block.dart';
import '../../domain/models/vec3.dart';

/// Builds candle geometry as raw vertex data, one mesh per candle.
///
/// A candle is two axis-aligned boxes — a body and a thin wick — merged into a
/// single vertex buffer so the whole candle is one renderable entity with one
/// material instead of two. At city scale that halves the entity count and the
/// per-frame draw calls.
///
/// Boxes are emitted with their true extents baked into the vertices rather
/// than being scaled by a transform. [GeometryUtils.cube] spans `-1..1` on
/// every axis, so scaling it by `s` yields a box of `2s` per side — an easy
/// factor-of-two error at every call site. Sizes here are the full extent, as
/// [CandleBlock.bodySize] and [CandleBlock.wickSize] already report them.
///
/// Vertices are emitted relative to [originOf] — the candle's slot on the
/// ground plane — not in absolute scene coordinates. Each candle therefore owns
/// an identical local frame and is placed by a translation, which is what lets
/// a single block be updated or replaced without touching its neighbours.
abstract final class CandleMesh {
  /// Corners per box face, then faces per box: 4 × 6.
  static const int _verticesPerBox = 24;

  /// Two triangles per face, three indices each, six faces: 6 × 2 × 3.
  static const int _indicesPerBox = 36;

  /// The ground-plane origin [build] emits vertices relative to.
  ///
  /// The candle's own x/z slot at ground level, so the mesh carries only the
  /// candle's shape and the transform carries only its place in the series.
  static Vector3 originOf(CandleBlock block) =>
      Vector3(block.bodyCenter.x, 0, block.bodyCenter.z);

  /// Builds the merged body + wick mesh for [block].
  ///
  /// The caller owns the result and must call `dispose()` on it once the
  /// geometry has been handed to the engine.
  static Geometry build(CandleBlock block) {
    final origin = originOf(block);

    const boxes = 2;
    final vertices = Float32List(boxes * _verticesPerBox * 3);
    final normals = Float32List(boxes * _verticesPerBox * 3);
    final indices = List<int>.filled(boxes * _indicesPerBox, 0);

    var cursor = 0;
    cursor = _writeBox(
      vertices: vertices,
      normals: normals,
      indices: indices,
      box: cursor,
      center: block.bodyCenter,
      size: block.bodySize,
      origin: origin,
    );
    _writeBox(
      vertices: vertices,
      normals: normals,
      indices: indices,
      box: cursor,
      center: block.wickCenter,
      size: block.wickSize,
      origin: origin,
    );

    return Geometry(vertices, indices, normals: normals);
  }

  /// Writes one box into the buffers at slot [box], returning the next slot.
  ///
  /// Every face gets its own four vertices so each can carry the face's own
  /// normal; sharing corners between faces would average the normals and round
  /// off the edges, which is wrong for a candlestick.
  static int _writeBox({
    required Float32List vertices,
    required Float32List normals,
    required List<int> indices,
    required int box,
    required Vec3 center,
    required Vec3 size,
    required Vector3 origin,
  }) {
    final cx = center.x - origin.x;
    final cy = center.y - origin.y;
    final cz = center.z - origin.z;

    final hx = size.x / 2;
    final hy = size.y / 2;
    final hz = size.z / 2;

    // Each face lists its four corners counter-clockwise as seen from outside
    // the box, so a uniform 0,1,2 / 0,2,3 triangulation front-faces every one.
    final faces = <_Face>[
      _Face(
        normal: const [0.0, 0.0, 1.0],
        corners: [
          [cx - hx, cy - hy, cz + hz],
          [cx + hx, cy - hy, cz + hz],
          [cx + hx, cy + hy, cz + hz],
          [cx - hx, cy + hy, cz + hz],
        ],
      ),
      _Face(
        normal: const [0.0, 0.0, -1.0],
        corners: [
          [cx + hx, cy - hy, cz - hz],
          [cx - hx, cy - hy, cz - hz],
          [cx - hx, cy + hy, cz - hz],
          [cx + hx, cy + hy, cz - hz],
        ],
      ),
      _Face(
        normal: const [1.0, 0.0, 0.0],
        corners: [
          [cx + hx, cy - hy, cz + hz],
          [cx + hx, cy - hy, cz - hz],
          [cx + hx, cy + hy, cz - hz],
          [cx + hx, cy + hy, cz + hz],
        ],
      ),
      _Face(
        normal: const [-1.0, 0.0, 0.0],
        corners: [
          [cx - hx, cy - hy, cz - hz],
          [cx - hx, cy - hy, cz + hz],
          [cx - hx, cy + hy, cz + hz],
          [cx - hx, cy + hy, cz - hz],
        ],
      ),
      _Face(
        normal: const [0.0, 1.0, 0.0],
        corners: [
          [cx - hx, cy + hy, cz + hz],
          [cx + hx, cy + hy, cz + hz],
          [cx + hx, cy + hy, cz - hz],
          [cx - hx, cy + hy, cz - hz],
        ],
      ),
      _Face(
        normal: const [0.0, -1.0, 0.0],
        corners: [
          [cx - hx, cy - hy, cz - hz],
          [cx + hx, cy - hy, cz - hz],
          [cx + hx, cy - hy, cz + hz],
          [cx - hx, cy - hy, cz + hz],
        ],
      ),
    ];

    final firstVertex = box * _verticesPerBox;
    var vertex = firstVertex;
    var index = box * _indicesPerBox;

    for (final face in faces) {
      final faceFirstVertex = vertex;

      for (final corner in face.corners) {
        final offset = vertex * 3;
        vertices[offset] = corner[0];
        vertices[offset + 1] = corner[1];
        vertices[offset + 2] = corner[2];
        normals[offset] = face.normal[0];
        normals[offset + 1] = face.normal[1];
        normals[offset + 2] = face.normal[2];
        vertex++;
      }

      indices[index++] = faceFirstVertex;
      indices[index++] = faceFirstVertex + 1;
      indices[index++] = faceFirstVertex + 2;
      indices[index++] = faceFirstVertex;
      indices[index++] = faceFirstVertex + 2;
      indices[index++] = faceFirstVertex + 3;
    }

    return box + 1;
  }
}

/// One box face: the outward normal shared by its four corners.
class _Face {
  const _Face({required this.normal, required this.corners});

  final List<double> normal;
  final List<List<double>> corners;
}
