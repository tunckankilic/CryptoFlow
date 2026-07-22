import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// A camera instruction sent to a renderer.
///
/// Commands describe intent, not engine state: the presentation layer says
/// "orbit by this much", the renderer decides how that maps onto its own
/// camera. This keeps gesture handling free of engine types.
@immutable
sealed class CameraCommand extends Equatable {
  const CameraCommand();

  @override
  List<Object?> get props => const [];
}

/// Frames the whole scene, leaving [paddingRatio] of margin around it.
class FrameScene extends CameraCommand {
  /// Extra margin around the scene bounds, as a ratio of the scene size.
  final double paddingRatio;

  const FrameScene({this.paddingRatio = 0.1});

  @override
  List<Object?> get props => [paddingRatio];
}

/// Rotates the camera around the scene by the given deltas, in radians.
class OrbitBy extends CameraCommand {
  /// Horizontal rotation delta, in radians.
  final double yawDelta;

  /// Vertical rotation delta, in radians.
  final double pitchDelta;

  const OrbitBy({required this.yawDelta, required this.pitchDelta});

  @override
  List<Object?> get props => [yawDelta, pitchDelta];
}

/// Scales the camera distance; `> 1` zooms in, `< 1` zooms out.
class ZoomBy extends CameraCommand {
  /// Multiplicative zoom factor.
  final double factor;

  const ZoomBy(this.factor);

  @override
  List<Object?> get props => [factor];
}

/// Returns the camera to the scene's default framing.
class ResetCamera extends CameraCommand {
  const ResetCamera();
}

/// Starts or stops the slow automatic orbit used by demo recording mode.
class SetAutoOrbit extends CameraCommand {
  /// Whether the automatic orbit is running.
  final bool enabled;

  /// Orbit speed, in degrees per second.
  final double degreesPerSecond;

  const SetAutoOrbit({required this.enabled, this.degreesPerSecond = 6.0});

  @override
  List<Object?> get props => [enabled, degreesPerSecond];
}
