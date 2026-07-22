import 'package:flutter/material.dart';
import 'package:thermion_flutter/thermion_flutter.dart';

import '../../domain/models/camera_command.dart';
import '../../domain/models/market_scene.dart';
import '../renderers/thermion_market_scene_renderer.dart';

/// Hosts the thermion viewport for the "3D Market" tab.
///
/// Renders [scene] as a candlestick city on mount, replacing the S3/S4
/// spike's fixed two-candle test scene now that real history drives it. This
/// is the only place in `presentation/`'s sibling tree allowed to import
/// thermion, per the engine-agnostic renderer rule.
///
/// Camera gestures are a plain [GestureDetector], not thermion's own
/// `ManipulatorType.ORBIT`: `ViewerWidget`'s public API bakes that
/// manipulator's zoom bounds in at construction (a hardcoded
/// `maxZoomDistance` of `1000`, a `minZoomDistance` tied to
/// `initialCameraPosition.length`) with no way to tune them per scene, and on
/// mobile its input path claims the gesture arena on the first pointer-down —
/// nothing external, including a double-tap detector, would ever see the
/// touch. Routing gestures through [CameraCommand] instead keeps the actual
/// clamping in [ThermionMarketSceneRenderer], scene-aware and testable.
class Market3DViewport extends StatefulWidget {
  const Market3DViewport({super.key, required this.scene});

  /// The city to render. [Market3DPage] rebuilds this widget with a new
  /// `scene` on every live tick (it's the same `BlocBuilder` that decides
  /// whether to mount it at all); [didUpdateWidget] below is what turns that
  /// into engine calls.
  final MarketScene scene;

  @override
  State<Market3DViewport> createState() => _Market3DViewportState();
}

class _Market3DViewportState extends State<Market3DViewport> {
  ThermionMarketSceneRenderer? _renderer;
  String _status = 'initialising engine…';
  Object? _error;

  /// Serialises calls into the renderer so two live ticks arriving close
  /// together (or a rescale racing a tick) can't interleave `_cityAssets`
  /// mutations — `didUpdateWidget` fires-and-forgets `_applySceneUpdate`
  /// rather than awaiting it, since a build method can't be async. Camera
  /// gestures share this same queue: they and scene updates both ultimately
  /// call into the same single-threaded engine, and a rollover landing
  /// mid-gesture must not interleave with the orbit/zoom it's applying.
  Future<void> _engineQueue = Future.value();

  /// Radians of yaw/pitch per logical pixel of one-finger drag. Tuned by eye
  /// on device, like `_emissiveFloor` in the renderer: a full-width swipe
  /// rotates the city a bit more than halfway around, which reads as a
  /// deliberate orbit rather than a twitchy one.
  static const double _orbitSensitivity = 0.01;

  /// `ScaleUpdateDetails.scale` is cumulative from gesture start, not
  /// per-update. This tracks the last cumulative value seen so each update
  /// can derive the incremental factor `ZoomBy` expects.
  double _gestureScale = 1.0;

  Future<void> _onViewerAvailable(ThermionViewer viewer) async {
    try {
      final renderer = ThermionMarketSceneRenderer(viewer);
      await renderer.initialize();
      await renderer.setScene(widget.scene);

      if (!mounted) return;
      setState(() {
        _renderer = renderer;
        _status = '${widget.scene.blocks.length} candles rendered';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _status = 'failed';
      });
    }
  }

  @override
  void didUpdateWidget(covariant Market3DViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    final renderer = _renderer;
    if (renderer == null || identical(oldWidget.scene, widget.scene)) return;
    final previous = oldWidget.scene;
    final next = widget.scene;
    _engineQueue = _engineQueue.then(
      (_) => _applySceneUpdate(renderer, previous, next),
    );
  }

  /// Applies a scene change to the engine without re-rendering the whole
  /// city on every tick.
  ///
  /// [CandleSceneAdapter.applyLiveCandle] always reuses the previous scene's
  /// [PriceScale] instance; [CandleSceneAdapter.buildScene] always builds a
  /// new one. That difference is a reliable, purely-derived signal for which
  /// path [Market3DBloc] took, so this widget doesn't need a separate flag on
  /// the state to tell a rescale from a single-tick update.
  Future<void> _applySceneUpdate(
    ThermionMarketSceneRenderer renderer,
    MarketScene previous,
    MarketScene next,
  ) async {
    try {
      if (previous.scale != next.scale) {
        await renderer.setScene(next);
        if (!mounted) return;
        setState(() => _status = '${next.blocks.length} candles rendered');
        return;
      }

      // Cheap path: only the live block changed, or a new one just opened —
      // which also freezes the block right before it (see
      // `CandleSceneAdapter.applyLiveCandle`). Both land in this range.
      final start = previous.blocks.isEmpty ? 0 : previous.blocks.length - 1;
      for (var i = start; i < next.blocks.length; i++) {
        final block = next.blockAt(i);
        if (block == null) continue;
        if (i < previous.blocks.length && block == previous.blocks[i]) {
          continue;
        }
        await renderer.updateLiveBlock(block);
      }
      if (!mounted) return;
      setState(() => _status = '${next.blocks.length} candles rendered');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _status = 'live update failed';
      });
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _gestureScale = 1.0;
  }

  /// One [GestureDetector] handles both orbit and pinch-zoom, the same way
  /// thermion's own touch listener does: a single pointer drags yaw/pitch,
  /// two or more scale the camera distance. Mixing the two per update would
  /// make a two-finger drag also spin the city, which isn't how pinch-zoom
  /// reads to a user.
  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount > 1) {
      final incremental = details.scale / _gestureScale;
      _gestureScale = details.scale;
      if (incremental != 1.0) _applyCamera(ZoomBy(incremental));
      return;
    }
    if (details.focalPointDelta == Offset.zero) return;
    _applyCamera(
      OrbitBy(
        yawDelta: -details.focalPointDelta.dx * _orbitSensitivity,
        pitchDelta: -details.focalPointDelta.dy * _orbitSensitivity,
      ),
    );
  }

  void _onDoubleTap() => _applyCamera(const ResetCamera());

  /// Queues a camera command onto [_engineQueue], same serialisation and
  /// same swallow-and-surface error handling as [_applySceneUpdate] — a
  /// failed camera call must not leave [_engineQueue] rejected, or every
  /// scene update and gesture after it would silently stop applying.
  void _applyCamera(CameraCommand command) {
    final renderer = _renderer;
    if (renderer == null) return;
    _engineQueue = _engineQueue.then((_) async {
      try {
        await renderer.applyCamera(command);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = e;
          _status = 'camera update failed';
        });
      }
    });
  }

  @override
  void dispose() {
    _renderer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onDoubleTap: _onDoubleTap,
            child: ViewerWidget(
              initialCameraPosition: Vector3(6, 4, 7),
              background: const Color(0xFF0B0D12),
              manipulatorType: ManipulatorType.NONE,
              onViewerAvailable: _onViewerAvailable,
            ),
          ),
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                _error == null ? _status : '$_status: $_error',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
