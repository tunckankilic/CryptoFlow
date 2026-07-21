import 'dart:async';

import 'package:thermion_flutter/thermion_flutter.dart';

import '../../domain/models/camera_command.dart';
import '../../domain/models/candle_block.dart';
import '../../domain/models/depth_surface.dart';
import '../../domain/models/market_scene.dart';
import '../../domain/models/scene_color.dart';
import '../../domain/models/scene_tap.dart';
import '../../domain/renderer/market_scene_renderer.dart';
import 'candle_mesh.dart';

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

  /// Fraction of a surface's own colour emitted regardless of incident light.
  ///
  /// Low enough that the key light still models the geometry, high enough that
  /// a completely unlit face stays readable. Tuned by eye on device.
  static const double _emissiveFloor = 0.22;

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

  /// Adds the scene's directional light.
  ///
  /// **Filament supports exactly one directional light per scene** — see the
  /// warning on `LightManager.h:89`: "If several directional lights are added to
  /// the scene, the dominant one will be used." A second light added here as a
  /// fill is therefore silently discarded, which is what left every face the key
  /// misses (`-x` and `-z`) rendering pure black while orbiting. Adding more
  /// directions cannot fix that; the missing ambient term is supplied per
  /// material instead, see [_emissiveFloor].
  ///
  /// `direction` is the direction light *travels*, so a light travelling
  /// `(-x, -y, -z)` arrives from `(+x, +y, +z)` — here, the upper front-right.
  Future<void> _addLightRig() async {
    await _viewer.addDirectLight(
      DirectLight.sun(
        intensity: 75000,
        direction: Vector3(-0.4, -1.0, -0.5)..normalize(),
        castShadows: true,
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
    final material = await _createMaterial(color);

    final asset = await _viewer.createGeometry(
      GeometryUtils.cube(),
      materialInstances: [material.materialInstance],
    );
    await asset.setTransform(
      Matrix4.translation(position)..scaleByVector3(size / 2.0),
    );
    return asset;
  }

  /// Creates the standard surface material for [color].
  Future<UbershaderMaterialInstance> _createMaterial(SceneColor color) async {
    final material = await FilamentApp.instance!.createUbershaderMaterial();
    await material.setBaseColorFactor(color.r, color.g, color.b, color.a);
    await material.setMetallicFactor(0.0);
    await material.setRoughnessFactor(0.65);

    // Stands in for the ambient term Filament will not provide (no IBL loaded,
    // and only one directional light is honoured — see [_addLightRig]). Tinting
    // the emissive with the surface's own colour rather than grey means an
    // unlit face reads as a dark green or dark red instead of black, so a
    // candle keeps its direction at every orbit angle.
    await material.setEmissiveFactor(
      color.r * _emissiveFloor,
      color.g * _emissiveFloor,
      color.b * _emissiveFloor,
      1.0,
    );

    return material;
  }

  /// Adds [block] to the scene as one merged body + wick mesh.
  ///
  /// The mesh carries the candle's true dimensions in its vertices (see
  /// [CandleMesh]); the transform only moves it to its slot in the series, so
  /// no scale factor is ever applied to the geometry.
  ///
  /// Both boxes share one material, so the wick takes the body's colour. That
  /// is deliberate: a per-box material would need a second material instance
  /// and a second primitive, doubling the cost of the thing this proves cheap.
  Future<ThermionAsset> addCandle(CandleBlock block) async {
    final material = await _createMaterial(block.bodyColor);
    final geometry = CandleMesh.build(block);

    try {
      final asset = await _viewer.createGeometry(
        geometry,
        materialInstances: [material.materialInstance],
      );
      await asset.setTransform(
        Matrix4.translation(CandleMesh.originOf(block)),
      );
      return asset;
    } finally {
      // The engine copies the buffers, so the Dart-side allocation is dead the
      // moment `createGeometry` returns. Leaking it once per candle would be
      // invisible in the spike and fatal in a city rebuilt on every tick.
      geometry.dispose();
    }
  }

  /// Removes [asset] from the scene and destroys it.
  Future<void> removeAsset(ThermionAsset asset) => _viewer.destroyAsset(asset);

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
