import 'package:flutter/material.dart';
import 'package:thermion_flutter/thermion_flutter.dart';

import '../../domain/models/candle_block.dart';
import '../../domain/models/scene_color.dart';
import '../../domain/models/vec3.dart';
import '../renderers/thermion_market_scene_renderer.dart';

/// Hosts the thermion viewport for the "3D Market" tab.
///
/// Carries the S2/S3 spike's fixed test scene (one bullish, one bearish
/// candle) and its rebuild stress test over verbatim now that
/// `/dev/3d-spike` is gone — this is the only place in `presentation/` that
/// is allowed to touch it, per the engine-agnostic renderer rule. Rendering
/// the real candlestick city from loaded data is session 5.
class Market3DViewport extends StatefulWidget {
  const Market3DViewport({super.key});

  @override
  State<Market3DViewport> createState() => _Market3DViewportState();
}

class _Market3DViewportState extends State<Market3DViewport> {
  /// How many build/destroy cycles the stress test runs (see session 3).
  static const int _stressIterations = 100;

  ThermionMarketSceneRenderer? _renderer;
  String _status = 'initialising engine…';
  Object? _error;
  bool _isStressing = false;

  Future<void> _onViewerAvailable(ThermionViewer viewer) async {
    try {
      final renderer = ThermionMarketSceneRenderer(viewer);
      await renderer.initialize();

      for (final block in _testBlocks()) {
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

  Future<void> _runStressTest() async {
    final renderer = _renderer;
    if (renderer == null || _isStressing) return;

    setState(() {
      _isStressing = true;
      _status = 'rebuilding ×$_stressIterations…';
    });

    final stopwatch = Stopwatch()..start();
    try {
      final block = _testBlocks().first;
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
  List<CandleBlock> _testBlocks() {
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
    return Stack(
      children: [
        Positioned.fill(
          child: ViewerWidget(
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                _error == null ? _status : '$_status: $_error',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
        if (_renderer != null)
          Positioned(
            right: 12,
            bottom: 12,
            child: FloatingActionButton.extended(
              heroTag: 'market3d-stress-test',
              onPressed: _isStressing ? null : _runStressTest,
              icon: const Icon(Icons.refresh),
              label: Text('rebuild ×$_stressIterations'),
            ),
          ),
      ],
    );
  }
}
