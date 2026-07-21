import 'dart:async';

import 'package:thermion_flutter/thermion_flutter.dart';

import '../../domain/models/camera_command.dart';
import '../../domain/models/candle_block.dart';
import '../../domain/models/depth_surface.dart';
import '../../domain/models/market_scene.dart';
import '../../domain/models/scene_color.dart';
import '../../domain/models/scene_tap.dart';
import '../../domain/renderer/market_scene_renderer.dart';

/// Thermion (Filament) implementation of [MarketSceneRenderer].
///
/// This is the only class in the package allowed to import an engine. It is
/// constructed with a [ThermionViewer] that the hosting widget obtained from
/// `ViewerWidget.onViewerAvailable`, so the renderer never owns the Flutter
/// surface — only what is drawn on it.
///
/// Session 2 scope is the build spike: [initialize] brings up lighting and a
/// ground plane and nothing else. The scene methods are declared so the
/// contract compiles and land their implementations in later sessions.
class ThermionMarketSceneRenderer implements MarketSceneRenderer {
  ThermionMarketSceneRenderer(this._viewer);

  final ThermionViewer _viewer;

  final StreamController<SceneTap> _taps =
      StreamController<SceneTap>.broadcast();

  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Stream<SceneTap> get taps => _taps.stream;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _addLightRig();

    await _createBox(
      const SceneColor(0.10, 0.11, 0.14),
      position: Vector3(0, -0.025, 0),
      size: Vector3(40, 0.05, 40),
    );

    await _viewer.setShadowsEnabled(true);

    // Continuous rendering rather than manual `renderSingleFrame` pumps: a live
    // market scene redraws constantly anyway, and interleaving manual frames
    // with the viewer's own render loop trips a beginFrame/endFrame precondition
    // inside Filament (an intermittent SIGABRT in `FRenderer::endFrame`).
    await _viewer.setRendering(true);

    _isInitialized = true;
  }

  /// Adds the scene's directional light rig.
  ///
  /// Filament applies no ambient term: a surface lit by no direct light and no
  /// image-based light renders pure black. The city is orbited freely, so every
  /// vertical face of a candle must catch something or it goes black as the
  /// camera swings past it.
  ///
  /// An IBL would be the physically correct answer but costs a KTX asset, so
  /// the cheap equivalent is used instead: a key and a fill aimed from opposing
  /// hemispheres. `direction` is the direction light *travels*, so a light
  /// travelling `(-x, -y, -z)` arrives from `(+x, +y, +z)`. Between them the
  /// two cover all four lateral faces plus the top; the key stays dominant so
  /// blocks still read as solid rather than flat.
  Future<void> _addLightRig() async {
    // Key: arrives from the upper front-right, casts the shadows.
    await _viewer.addDirectLight(
      DirectLight.sun(
        intensity: 75000,
        direction: Vector3(-0.4, -1.0, -0.5)..normalize(),
        castShadows: true,
      ),
    );

    // Fill: arrives from the opposing upper back-left. Strong enough to keep
    // the faces the key misses legible, weak enough to preserve modelling.
    await _viewer.addDirectLight(
      DirectLight.sun(
        intensity: 35000,
        direction: Vector3(0.6, -0.5, 0.55)..normalize(),
        castShadows: false,
      ),
    );
  }

  /// Creates an axis-aligned box centred on [position] whose full extent is
  /// [size] — i.e. `size.y` is the box's total height, not its half-height.
  ///
  /// [GeometryUtils.cube] spans `-1..1` on every axis, so it is 2 units wide,
  /// not 1. The scale is therefore half of [size]; getting this wrong silently
  /// doubles every candle in the city, so it is corrected here once rather
  /// than at each call site.
  Future<ThermionAsset> _createBox(
    SceneColor color, {
    required Vector3 position,
    required Vector3 size,
  }) async {
    final material = await FilamentApp.instance!.createUbershaderMaterial();
    await material.setBaseColorFactor(color.r, color.g, color.b, color.a);
    await material.setMetallicFactor(0.0);
    await material.setRoughnessFactor(0.65);

    final asset = await _viewer.createGeometry(
      GeometryUtils.cube(),
      materialInstances: [material.materialInstance],
    );
    await asset.setTransform(
      Matrix4.translation(position)..scaleByVector3(size / 2.0),
    );
    return asset;
  }

  /// Adds a single lit test cube to the scene.
  ///
  /// Spike-only helper that exists to prove the engine renders on device;
  /// [setScene] replaces it with the candlestick city in session 3.
  Future<ThermionAsset> addSpikeCube({
    required Vector3 position,
    required double size,
    required SceneColor color,
  }) {
    return _createBox(
      color,
      position: position,
      size: Vector3(size, size, size),
    );
  }

  @override
  Future<void> setScene(MarketScene scene) {
    throw UnimplementedError('setScene lands in session 3 (candlestick city)');
  }

  @override
  Future<void> updateLiveBlock(CandleBlock block) {
    throw UnimplementedError(
      'updateLiveBlock lands in session 6 (live updates)',
    );
  }

  @override
  Future<void> setSelectedBlock(int? index) {
    throw UnimplementedError(
      'setSelectedBlock lands in session 5 (tap to inspect)',
    );
  }

  @override
  Future<void> setDepthSurface(DepthSurface surface) {
    throw UnimplementedError(
      'setDepthSurface lands in session 9 (depth terrain)',
    );
  }

  @override
  Future<void> clearDepthSurface() {
    throw UnimplementedError(
      'clearDepthSurface lands in session 9 (depth terrain)',
    );
  }

  @override
  Future<void> applyCamera(CameraCommand command) {
    throw UnimplementedError('applyCamera lands in session 4 (camera control)');
  }

  @override
  Future<void> dispose() async {
    await _taps.close();
    _isInitialized = false;
  }
}
