import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:market_3d/market_3d.dart';

void main() {
  group('OrbitCameraState.fromPosition', () {
    test('round-trips a typical framing position through .position', () {
      const focus = Vec3(0, 5, 0);
      const position = Vec3(20, 16.2, 34);

      final state = OrbitCameraState.fromPosition(
        position: position,
        focus: focus,
        minRadius: 1,
        maxRadius: 1000,
      );

      expect(state.position.x, closeTo(position.x, 1e-9));
      expect(state.position.y, closeTo(position.y, 1e-9));
      expect(state.position.z, closeTo(position.z, 1e-9));
    });

    test('does not throw when position equals focus', () {
      const focus = Vec3(0, 5, 0);

      final state = OrbitCameraState.fromPosition(
        position: focus,
        focus: focus,
        minRadius: 2,
        maxRadius: 10,
      );

      expect(state.radius, 2);
      expect(
          state.elevation, greaterThanOrEqualTo(OrbitCameraState.minElevation));
      expect(state.elevation, lessThanOrEqualTo(OrbitCameraState.maxElevation));
    });

    test('clamps an out-of-range radius into bounds', () {
      const focus = Vec3.zero;
      const position = Vec3(0, 500, 0);

      final state = OrbitCameraState.fromPosition(
        position: position,
        focus: focus,
        minRadius: 10,
        maxRadius: 100,
      );

      expect(state.radius, 100);
    });
  });

  group('OrbitCameraState.orbitBy', () {
    final base = OrbitCameraState.fromPosition(
      position: const Vec3(20, 16.2, 34),
      focus: const Vec3(0, 5, 0),
      minRadius: 5,
      maxRadius: 200,
    );

    test('accumulates yaw without clamping (wraps freely)', () {
      final orbited = base.orbitBy(yawDelta: math.pi * 3, pitchDelta: 0);

      expect(orbited.azimuth, closeTo(base.azimuth + math.pi * 3, 1e-9));
    });

    test('clamps elevation so the camera cannot cross a pole', () {
      final overRotated = base.orbitBy(yawDelta: 0, pitchDelta: 100);

      expect(overRotated.elevation, OrbitCameraState.maxElevation);

      final underRotated = base.orbitBy(yawDelta: 0, pitchDelta: -100);

      expect(underRotated.elevation, OrbitCameraState.minElevation);
    });

    test('leaves radius and focus untouched', () {
      final orbited = base.orbitBy(yawDelta: 0.3, pitchDelta: -0.1);

      expect(orbited.radius, base.radius);
      expect(orbited.focus, base.focus);
    });
  });

  group('OrbitCameraState.zoomBy', () {
    final base = OrbitCameraState.fromPosition(
      position: const Vec3(20, 16.2, 34),
      focus: const Vec3(0, 5, 0),
      minRadius: 10,
      maxRadius: 120,
    );

    test('a factor greater than 1 zooms in (shrinks radius)', () {
      final zoomed = base.zoomBy(2.0);

      expect(zoomed.radius, closeTo(base.radius / 2.0, 1e-9));
    });

    test('a factor less than 1 zooms out (grows radius)', () {
      final zoomed = base.zoomBy(0.5);

      expect(zoomed.radius, closeTo(base.radius * 2.0, 1e-9));
    });

    test('clamps to minRadius so the camera cannot clip through the city', () {
      final zoomed = base.zoomBy(1000);

      expect(zoomed.radius, base.minRadius);
    });

    test('clamps to maxRadius so the city cannot shrink to a speck', () {
      final zoomed = base.zoomBy(0.001);

      expect(zoomed.radius, base.maxRadius);
    });
  });
}
