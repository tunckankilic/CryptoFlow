import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// A point or size in scene space.
///
/// Deliberately engine-agnostic: scene models never expose a rendering
/// engine's own vector type, so a renderer implementation can be swapped
/// without touching the data or presentation layers.
///
/// Scene space convention used across this package:
/// - `x` runs left to right along the candle series (oldest to newest)
/// - `y` is up, with `0` at the ground plane
/// - `z` is depth, `0` for the candle series plane
@immutable
class Vec3 extends Equatable {
  /// Horizontal axis, along the candle series.
  final double x;

  /// Vertical axis, up from the ground plane.
  final double y;

  /// Depth axis, towards the viewer.
  final double z;

  const Vec3(this.x, this.y, this.z);

  /// The scene origin.
  static const Vec3 zero = Vec3(0, 0, 0);

  /// Creates a copy of this vector with the given fields replaced.
  Vec3 copyWith({double? x, double? y, double? z}) {
    return Vec3(x ?? this.x, y ?? this.y, z ?? this.z);
  }

  Vec3 operator +(Vec3 other) => Vec3(x + other.x, y + other.y, z + other.z);

  Vec3 operator -(Vec3 other) => Vec3(x - other.x, y - other.y, z - other.z);

  Vec3 operator *(double scalar) => Vec3(x * scalar, y * scalar, z * scalar);

  @override
  List<Object?> get props => [x, y, z];

  @override
  String toString() => 'Vec3($x, $y, $z)';
}
