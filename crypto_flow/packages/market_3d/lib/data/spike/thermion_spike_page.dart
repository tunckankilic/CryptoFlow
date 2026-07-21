import 'package:flutter/material.dart';
import 'package:thermion_flutter/thermion_flutter.dart';

import '../../domain/models/scene_color.dart';
import '../renderers/thermion_market_scene_renderer.dart';

/// Debug-only page proving the engine builds and renders on real hardware.
///
/// Session 2 gate: a lit ground plane and one procedurally generated cube (no
/// glTF assets), orbitable with the standard gesture manipulator, on both the
/// iOS simulator and a physical device. It is reachable only from the
/// `/dev/3d-spike` debug route and is not part of the shipped tab bar.
class ThermionSpikePage extends StatefulWidget {
  const ThermionSpikePage({super.key});

  @override
  State<ThermionSpikePage> createState() => _ThermionSpikePageState();
}

class _ThermionSpikePageState extends State<ThermionSpikePage> {
  ThermionMarketSceneRenderer? _renderer;
  String _status = 'initialising engine…';
  Object? _error;

  Future<void> _onViewerAvailable(ThermionViewer viewer) async {
    try {
      final renderer = ThermionMarketSceneRenderer(viewer);
      await renderer.initialize();

      // Three cubes at different depths so perspective and the orbit
      // manipulator are both obviously working, not just "something drew".
      await renderer.addSpikeCube(
        position: Vector3(-1.6, 0.5, 0),
        size: 1.0,
        color: const SceneColor(0.15, 0.72, 0.45),
      );
      await renderer.addSpikeCube(
        position: Vector3(0, 0.75, 0),
        size: 1.5,
        color: const SceneColor(0.28, 0.56, 0.95),
      );
      await renderer.addSpikeCube(
        position: Vector3(1.6, 0.4, -0.8),
        size: 0.8,
        color: const SceneColor(0.92, 0.31, 0.36),
      );

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

  @override
  void dispose() {
    _renderer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D spike')),
      body: Stack(
        children: [
          Positioned.fill(
            child: ViewerWidget(
              // Three-quarter view: a head-on camera hides the side faces,
              // which are exactly what the fill light has to prove it reaches.
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
