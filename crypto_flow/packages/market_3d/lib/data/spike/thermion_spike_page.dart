import 'package:flutter/material.dart';
import 'package:thermion_flutter/thermion_flutter.dart';

import '../../domain/models/candle_block.dart';
import '../../domain/models/scene_color.dart';
import '../../domain/models/vec3.dart';
import '../renderers/thermion_market_scene_renderer.dart';

/// Debug-only page proving the engine builds and renders on real hardware.
///
/// Session 2 proved the engine comes up at all: a lit ground plane and one
/// procedurally generated cube, orbitable, on simulator and device.
///
/// Session 3 replaces the cubes with the real thing — candles built from raw
/// vertex data, body and wick merged into one mesh — and adds the rebuild
/// stress test, because the city will tear down and rebuild its geometry on
/// every rescale and a leak there is invisible at this scale but fatal at the
/// city's.
///
/// Reachable only from the `/dev/3d-spike` debug route; not part of the tab bar.
class ThermionSpikePage extends StatefulWidget {
  const ThermionSpikePage({super.key});

  @override
  State<ThermionSpikePage> createState() => _ThermionSpikePageState();
}

class _ThermionSpikePageState extends State<ThermionSpikePage> {
  /// How many build/destroy cycles the stress test runs.
  ///
  /// High enough that a per-candle leak of either the Dart-side vertex buffer
  /// or the engine-side asset shows up as a memory climb or a crash.
  static const int _stressIterations = 100;

  ThermionMarketSceneRenderer? _renderer;
  String _status = 'initialising engine…';
  Object? _error;
  bool _isStressing = false;

  Future<void> _onViewerAvailable(ThermionViewer viewer) async {
    try {
      final renderer = ThermionMarketSceneRenderer(viewer);
      await renderer.initialize();

      for (final block in _spikeBlocks()) {
        await renderer.addCandle(block);
      }

      if (!mounted) return;
      setState(() {
        _renderer = renderer;
        _status = 'rendering';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _status = 'failed';
      });
    }
  }

  /// Builds and destroys a candle [_stressIterations] times.
  ///
  /// Runs against the same viewer that is actively rendering, so it also
  /// exercises the case the city cares about: geometry churning underneath a
  /// live render loop rather than in a paused scene.
  Future<void> _runStressTest() async {
    final renderer = _renderer;
    if (renderer == null || _isStressing) return;

    setState(() {
      _isStressing = true;
      _status = 'rebuilding ×$_stressIterations…';
    });

    final stopwatch = Stopwatch()..start();
    try {
      final block = _spikeBlocks().first;
      for (var i = 0; i < _stressIterations; i++) {
        final asset = await renderer.addCandle(block);
        await renderer.removeAsset(asset);
      }
      stopwatch.stop();

      if (!mounted) return;
      setState(() {
        _isStressing = false;
        _status =
            'rebuilt ×$_stressIterations in ${stopwatch.elapsedMilliseconds}ms '
            '(${(stopwatch.elapsedMicroseconds / _stressIterations / 1000).toStringAsFixed(2)}ms each)';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isStressing = false;
        _error = e;
        _status = 'stress test failed';
      });
    }
  }

  /// One bullish and one bearish candle, sized like real ones.
  ///
  /// The bearish candle deliberately has a long lower wick and a short body:
  /// wick and body are separate boxes in one mesh, and that only shows if the
  /// two differ enough to tell apart.
  List<CandleBlock> _spikeBlocks() {
    final openTime = DateTime.utc(2026, 1, 1);
    return [
      CandleBlock(
        index: 0,
        openTime: openTime,
        bodyCenter: const Vec3(-0.7, 1.4, 0),
        bodySize: const Vec3(0.8, 2.2, 0.8),
        wickCenter: const Vec3(-0.7, 1.6, 0),
        wickSize: const Vec3(0.12, 3.2, 0.12),
        bodyColor: const SceneColor(0.15, 0.78, 0.47),
        wickColor: const SceneColor(0.15, 0.78, 0.47),
        isBullish: true,
        isLive: false,
      ),
      CandleBlock(
        index: 1,
        openTime: openTime.add(const Duration(minutes: 1)),
        bodyCenter: const Vec3(0.7, 2.1, 0),
        bodySize: const Vec3(0.8, 0.9, 0.8),
        wickCenter: const Vec3(0.7, 1.5, 0),
        wickSize: const Vec3(0.12, 3.0, 0.12),
        bodyColor: const SceneColor(0.93, 0.29, 0.35),
        wickColor: const SceneColor(0.93, 0.29, 0.35),
        isBullish: false,
        isLive: false,
      ),
    ];
  }

  @override
  void dispose() {
    _renderer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D spike')),
      floatingActionButton: _renderer == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _isStressing ? null : _runStressTest,
              icon: const Icon(Icons.refresh),
              label: Text('rebuild ×$_stressIterations'),
            ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ViewerWidget(
              // Three-quarter view: a head-on camera hides the side faces,
              // which are exactly what the lighting has to prove it reaches.
              initialCameraPosition: Vector3(6, 4, 7),
              background: const Color(0xFF0B0D12),
              onViewerAvailable: _onViewerAvailable,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(
                  _error == null ? _status : '$_status: $_error',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
