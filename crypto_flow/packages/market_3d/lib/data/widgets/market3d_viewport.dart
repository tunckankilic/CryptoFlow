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

  /// The city to render. [Market3DPage] only mounts this widget once
  /// [Market3DBloc] has a non-empty loaded scene, so this is static for the
  /// widget's lifetime — live updates (session 6) will need to make it
  /// reactive to a changing scene instead of a one-shot build.
  final MarketScene scene;

  @override
  State<Market3DViewport> createState() => _Market3DViewportState();
}

class _Market3DViewportState extends State<Market3DViewport> {
  ThermionMarketSceneRenderer? _renderer;
  String _status = 'initialising engine…';
  Object? _error;

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
