import 'dart:async';

import 'package:thermion_flutter/thermion_flutter.dart';

import '../../domain/hit_test/scene_hit_tester.dart';
import '../../domain/hit_test/scene_projector.dart';
import '../../domain/models/camera_command.dart';
import '../../domain/models/candle_block.dart';
import '../../domain/models/depth_surface.dart';
import '../../domain/models/market_scene.dart';
import '../../domain/models/orbit_camera_state.dart';
import '../../domain/models/scene_color.dart';
import '../../domain/models/scene_tap.dart';
import '../../domain/models/vec3.dart';
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

  /// Assets for the currently rendered city, in block-index order.
  ///
  /// Tracked so [setScene] can tear down the previous city before building
  /// the next one — a full rebuild, per the renderer contract's docs on
  /// [setScene], not the per-tick in-place update session 6 adds.
  final List<ThermionAsset> _cityAssets = [];

  /// The scene last handed to [setScene], used by [applyCamera] to frame the
  /// city without needing the scene passed again. [updateLiveBlock] keeps this
  /// in sync too, so a later [applyCamera] call sees live growth.
  MarketScene _scene = MarketScene.empty();

  /// The x offset baked into every asset currently in [_cityAssets].
  ///
  /// Frozen at the value [setScene] computed for the block count at that
  /// time. [updateLiveBlock] reuses it rather than recomputing
  /// [MarketScene.seriesCenterOffsetX] from the growing scene: per
  /// [MarketScene]'s own contract, appending a candle must never move blocks
  /// already on screen, so a newly opened candle is placed with the same
  /// frozen offset and the city recentres only on the next full [setScene].
  double _seriesOffsetX = 0;

  /// Index of the highlighted block, or `null` when nothing is selected.
  int? _selectedIndex;

  /// Resolves taps to blocks. Stateless and cheap, kept as a field only so a
  /// caller could hand in a different touch slop without touching this class.
  final SceneHitTester _hitTester = const SceneHitTester();

  /// The camera's current orbit state, established by the last
  /// [_frameScene] call. `null` until the first one runs, which `setScene`
  /// always triggers before any gesture can reach [applyCamera] — see
  /// [_orbit]/[_zoom]'s null guard for the race that protects against
  /// anyway (a gesture landing in the gap before the first frame).
  OrbitCameraState? _cameraState;

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
  ///
  /// [offsetX] shifts the placement along x without touching the mesh — it is
  /// how [setScene] applies [MarketScene.seriesCenterOffsetX] to centre the
  /// whole city while keeping each block's vertices in series-local space.
  ///
  /// [color] overrides the block's own body colour, which is how a selected
  /// candle is highlighted: the block itself never changes, only the material
  /// it is drawn with.
  Future<ThermionAsset> addCandle(
    CandleBlock block, {
    double offsetX = 0,
    SceneColor? color,
  }) async {
    final material = await _createMaterial(color ?? block.bodyColor);
    final geometry = CandleMesh.build(block);

    try {
      final asset = await _viewer.createGeometry(
        geometry,
        materialInstances: [material.materialInstance],
      );
      await asset.setTransform(
        Matrix4.translation(
          CandleMesh.originOf(block) + Vector3(offsetX, 0, 0),
        ),
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

  /// Replaces the city: destroys every existing candle asset, adds one per
  /// [MarketScene.blocks], then frames the camera on the result.
  ///
  /// Whole-city rebuild, same cost profile the S3 stress test measured
  /// (~1ms per candle) — fine for a load or a rescale, not for a per-tick
  /// live update (session 6 mutates the live block's transform instead).
  @override
  Future<void> setScene(MarketScene scene) async {
    for (final asset in _cityAssets) {
      await _viewer.destroyAsset(asset);
    }
    _cityAssets.clear();

    _seriesOffsetX = scene.seriesCenterOffsetX;

    // A rescale rebuilds the city under a selection the user hasn't dismissed,
    // so the highlight is reapplied here rather than being silently dropped.
    // A shorter series (never happens today, but the scene contract allows it)
    // clears a selection that no longer exists.
    final selected = _selectedIndex;
    if (selected != null && selected >= scene.blocks.length) {
      _selectedIndex = null;
    }

    for (final block in scene.blocks) {
      _cityAssets.add(
        await addCandle(
          block,
          offsetX: _seriesOffsetX,
          color: _colorFor(block, scene),
        ),
      );
    }

    _scene = scene;
    await applyCamera(const FrameScene());
  }

  /// Mutates a single candle's geometry without touching the rest of the
  /// city: `block.index` inside [_cityAssets] replaces that asset (the
  /// steady-state tick — OHLC and colour move but the series doesn't grow),
  /// `block.index == _cityAssets.length` appends the newly opened candle.
  ///
  /// Thermion has no API to rewrite an existing asset's vertex buffer in
  /// place, and a live candle's body/wick height genuinely changes every
  /// tick, not just its transform — so "mutate in place" here means destroy
  /// and recreate the one asset at this index, the same per-candle
  /// build+destroy [addCandle]/[removeAsset] already cost ~1ms each (S3). The
  /// new asset is created before the old one is destroyed so there is no
  /// frame where the live candle is briefly missing.
  @override
  Future<void> updateLiveBlock(CandleBlock block) async {
    if (block.index < 0 || block.index > _cityAssets.length) {
      throw RangeError.index(block.index, _cityAssets, 'block.index');
    }

    final asset = await addCandle(
      block,
      offsetX: _seriesOffsetX,
      color: _colorFor(block, _scene),
    );

    if (block.index == _cityAssets.length) {
      _cityAssets.add(asset);
    } else {
      final previous = _cityAssets[block.index];
      _cityAssets[block.index] = asset;
      await _viewer.destroyAsset(previous);
    }

    _scene = _scene.withBlock(block);
  }

  /// Highlights the block at [index] by redrawing it in the palette's
  /// selection colour, and restores whichever block was highlighted before.
  ///
  /// An out-of-range index clears the selection instead of throwing: a tap
  /// resolved against a scene the engine has since replaced is a stale
  /// request, not a programming error.
  @override
  Future<void> setSelectedBlock(int? index) async {
    final requested =
        (index != null && index >= 0 && index < _cityAssets.length)
            ? index
            : null;
    if (requested == _selectedIndex) return;

    final previous = _selectedIndex;
    _selectedIndex = requested;

    if (previous != null) await _redrawBlock(previous);
    if (requested != null) await _redrawBlock(requested);
  }

  /// Rebuilds the asset at [index] with whatever colour its current selection
  /// status calls for, create-before-destroy so the candle never blinks out.
  Future<void> _redrawBlock(int index) async {
    final block = _scene.blockAt(index);
    if (block == null || index >= _cityAssets.length) return;

    final asset = await addCandle(
      block,
      offsetX: _seriesOffsetX,
      color: _colorFor(block, _scene),
    );
    final previous = _cityAssets[index];
    _cityAssets[index] = asset;
    await _viewer.destroyAsset(previous);
  }

  /// The colour [block] should currently be drawn in: the selection highlight
  /// when it is the selected block, its own body colour otherwise.
  SceneColor? _colorFor(CandleBlock block, MarketScene scene) =>
      block.index == _selectedIndex ? scene.layout.palette.selection : null;

  /// Resolves a tap at viewport position ([x], [y]) and publishes the result
  /// on [taps], including misses so the UI can dismiss its overlay.
  ///
  /// The camera's live view and projection matrices are read straight from the
  /// engine, so the hit test uses exactly the transform the frame was drawn
  /// with — no assumption about field of view or aspect ratio survives in
  /// [SceneProjector], which is what lets the projection maths live in the
  /// engine-agnostic domain layer.
  Future<void> handleTap({
    required double x,
    required double y,
    required double viewportWidth,
    required double viewportHeight,
  }) async {
    if (_taps.isClosed) return;
    if (_scene.isEmpty || viewportWidth <= 0 || viewportHeight <= 0) {
      _taps.add(const SceneTap.miss());
      return;
    }

    final camera = await _viewer.getActiveCamera();
    final view = await camera.getViewMatrix();
    final projection = await camera.getProjectionMatrix();

    final tap = _hitTester.hitTest(
      scene: _scene,
      projector: SceneProjector(
        viewProjection: projection.multiplied(view),
        viewportWidth: viewportWidth,
        viewportHeight: viewportHeight,
        seriesOffsetX: _seriesOffsetX,
      ),
      tapX: x,
      tapY: y,
    );

    if (!_taps.isClosed) _taps.add(tap);
  }

  @override
  Future<void> setDepthSurface(DepthSurface surface) {
    throw UnimplementedError(
      'setDepthSurface lands in session 10 (depth terrain)',
    );
  }

  @override
  Future<void> clearDepthSurface() {
    throw UnimplementedError(
      'clearDepthSurface lands in session 10 (depth terrain)',
    );
  }

  /// Dispatches every [CameraCommand] except [SetAutoOrbit] (the slow demo
  /// auto-orbit, session 12's job). [FrameScene] and [ResetCamera] both go
  /// through [_frameScene] — a reset is exactly the establishing shot,
  /// recomputed for whatever the city looks like now. [OrbitBy] and
  /// [ZoomBy] mutate the [OrbitCameraState] [_frameScene] last established.
  @override
  Future<void> applyCamera(CameraCommand command) async {
    switch (command) {
      case FrameScene():
        await _frameScene(command);
      case ResetCamera():
        await _frameScene(const FrameScene());
      case OrbitBy():
        await _orbit(command);
      case ZoomBy():
        await _zoom(command);
      case SetAutoOrbit():
        throw UnimplementedError(
          'applyCamera($command) lands in session 12 (demo mode auto-orbit)',
        );
    }
  }

  /// Positions the camera on a diagonal high enough to read city depth and
  /// far enough back that neither the widest row nor the tallest wick is
  /// clipped, looking at the vertical mid-point of the price range.
  ///
  /// Approximate on purpose — this is a fixed establishing shot, not a tight
  /// bounding-box fit. The zoom bounds handed to [OrbitCameraState] scale
  /// with [distance] rather than being fixed, so [_zoom]'s clamp stays
  /// sensible whether the city is 36 units wide or 85 — see
  /// [OrbitCameraState]'s doc comment for why thermion's own orbit
  /// manipulator can't do this through `ViewerWidget`'s public API.
  Future<void> _frameScene(FrameScene command) async {
    final width = _scene.isEmpty ? 1.0 : _scene.width;
    final height = _scene.isEmpty ? _scene.layout.sceneHeight : _scene.topExtent;
    final span = (width > height ? width : height) * (1 + command.paddingRatio);
    final distance = span * 0.9 + 4.0;

    final focus = Vec3(0, height / 2, 0);
    final position = Vec3(
      distance * 0.5,
      height * 0.55 + distance * 0.28,
      distance * 0.85,
    );

    await _applyOrbitState(
      OrbitCameraState.fromPosition(
        position: position,
        focus: focus,
        minRadius: distance * 0.3,
        maxRadius: distance * 3.0,
      ),
    );
  }

  /// Rotates the camera by [command]'s deltas around the last framed focus
  /// point. A no-op if no [_frameScene] has run yet (nothing to orbit
  /// around) — can't happen in practice since [setScene] always frames the
  /// city before the viewport becomes interactive, but a gesture racing that
  /// first frame is cheap to guard against.
  Future<void> _orbit(OrbitBy command) async {
    final state = _cameraState;
    if (state == null) return;
    await _applyOrbitState(
      state.orbitBy(yawDelta: command.yawDelta, pitchDelta: command.pitchDelta),
    );
  }

  /// Scales the camera's distance from the focus point by [ZoomBy.factor].
  Future<void> _zoom(ZoomBy command) async {
    final state = _cameraState;
    if (state == null) return;
    await _applyOrbitState(state.zoomBy(command.factor));
  }

  /// Applies [state] to the engine camera and records it as [_cameraState]
  /// so the next gesture starts from here.
  Future<void> _applyOrbitState(OrbitCameraState state) async {
    final camera = await _viewer.getActiveCamera();
    await camera.lookAt(
      Vector3(state.position.x, state.position.y, state.position.z),
      focus: Vector3(state.focus.x, state.focus.y, state.focus.z),
    );
    _cameraState = state;
  }

  @override
  Future<void> dispose() async {
    for (final asset in _cityAssets) {
      await _viewer.destroyAsset(asset);
    }
    _cityAssets.clear();
    await _taps.close();
    _isInitialized = false;
  }
}
