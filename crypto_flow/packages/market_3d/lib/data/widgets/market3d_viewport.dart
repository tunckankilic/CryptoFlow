import 'package:flutter/material.dart';
import 'package:thermion_flutter/thermion_flutter.dart';

import '../../domain/models/market_scene.dart';
import '../renderers/thermion_market_scene_renderer.dart';

/// Hosts the thermion viewport for the "3D Market" tab.
///
/// Renders [scene] as a candlestick city on mount, replacing the S3/S4
/// spike's fixed two-candle test scene now that real history drives it. This
/// is the only place in `presentation/`'s sibling tree allowed to import
/// thermion, per the engine-agnostic renderer rule.
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
  /// rather than awaiting it, since a build method can't be async.
  Future<void> _engineQueue = Future.value();

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
      ],
    );
  }
}
