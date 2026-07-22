import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'vec3.dart';

/// Spherical camera state around a focus point — the pure-math half of orbit
/// controls, factored out of the renderer so the clamping that keeps the
/// city on screen is unit-testable without a live engine.
///
/// Thermion ships its own orbit manipulator (`OrbitInputHandlerDelegate` in
/// `thermion_dart`), but `ViewerWidget`'s public API gives no way to tune its
/// bounds per scene: `minZoomDistance` is fixed to the widget's
/// `initialCameraPosition.length` and `maxZoomDistance` is hardcoded to
/// `1000.0`, both baked in before a real [MarketScene] exists. A ~40-unit
/// city could be zoomed out to a speck or zoomed in past its own geometry.
/// This type carries bounds computed from the actual framing distance
/// instead, recomputed every time the renderer's `_frameScene` runs.
@immutable
class OrbitCameraState extends Equatable {
  /// Rotation around the focus point's vertical axis, in radians. Wraps
  /// freely — there is no reason to clamp yaw.
  final double azimuth;

  /// Rotation above the horizontal plane through [focus], in radians.
  /// Clamped to [minElevation]/[maxElevation] so the camera can never cross
  /// a pole (which reads as the city flipping) or dip under the ground
  /// plane.
  final double elevation;

  /// Distance from [focus], clamped to [minRadius]/[maxRadius].
  final double radius;

  /// The point the camera looks at and orbits around.
  final Vec3 focus;

  /// Closest the camera may approach [focus].
  final double minRadius;

  /// Farthest the camera may retreat from [focus].
  final double maxRadius;

  /// Lower elevation bound: shallow enough to still read as an aerial city
  /// shot, high enough that the camera never dips below the ground plane.
  static const double minElevation = 0.08;

  /// Upper elevation bound: just short of true top-down, which would look
  /// flat and make further orbiting imperceptible.
  static const double maxElevation = math.pi / 2 - 0.05;

  const OrbitCameraState({
    required this.azimuth,
    required this.elevation,
    required this.radius,
    required this.focus,
    required this.minRadius,
    required this.maxRadius,
  });

  /// Builds the state that reproduces [position] looking at [focus], clamped
  /// into range — seeds orbit state from a fixed framing shot so the first
  /// gesture continues smoothly from wherever framing left the camera.
  factory OrbitCameraState.fromPosition({
    required Vec3 position,
    required Vec3 focus,
    required double minRadius,
    required double maxRadius,
  }) {
    final direction = position - focus;
    final radius = math.sqrt(
      direction.x * direction.x +
          direction.y * direction.y +
          direction.z * direction.z,
    );

    if (radius < 1e-6) {
      return OrbitCameraState(
        azimuth: 0,
        elevation: (math.pi / 4).clamp(minElevation, maxElevation),
        radius: minRadius,
        focus: focus,
        minRadius: minRadius,
        maxRadius: maxRadius,
      );
    }

    return OrbitCameraState(
      azimuth: math.atan2(direction.x, direction.z),
      elevation: math
          .asin((direction.y / radius).clamp(-1.0, 1.0))
          .clamp(minElevation, maxElevation),
      radius: radius.clamp(minRadius, maxRadius),
      focus: focus,
      minRadius: minRadius,
      maxRadius: maxRadius,
    );
  }

  /// The camera position implied by these spherical coordinates, using the
  /// same y-up convention as [Vec3].
  Vec3 get position =>
      focus +
      Vec3(
        radius * math.cos(elevation) * math.sin(azimuth),
        radius * math.sin(elevation),
        radius * math.cos(elevation) * math.cos(azimuth),
      );

  /// Applies an orbit gesture delta.
  OrbitCameraState orbitBy({
    required double yawDelta,
    required double pitchDelta,
  }) {
    return copyWith(
      azimuth: azimuth + yawDelta,
      elevation: (elevation + pitchDelta).clamp(minElevation, maxElevation),
    );
  }

  /// Applies a zoom factor (`> 1` zooms in, `< 1` zooms out), clamped to
  /// [minRadius]/[maxRadius].
  OrbitCameraState zoomBy(double factor) {
    return copyWith(radius: (radius / factor).clamp(minRadius, maxRadius));
  }

  /// Creates a copy of this state with the given fields replaced.
  OrbitCameraState copyWith({
    double? azimuth,
    double? elevation,
    double? radius,
    Vec3? focus,
    double? minRadius,
    double? maxRadius,
  }) {
    return OrbitCameraState(
      azimuth: azimuth ?? this.azimuth,
      elevation: elevation ?? this.elevation,
      radius: radius ?? this.radius,
      focus: focus ?? this.focus,
      minRadius: minRadius ?? this.minRadius,
      maxRadius: maxRadius ?? this.maxRadius,
    );
  }

  @override
  List<Object?> get props => [
        azimuth,
        elevation,
        radius,
        focus,
        minRadius,
        maxRadius,
      ];
}
