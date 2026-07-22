import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/widgets/market3d_viewport.dart';
import '../bloc/market3d/market3d_bloc.dart';
import '../bloc/market3d/market3d_event.dart';
import '../bloc/market3d/market3d_state.dart';
import '../widgets/candle_inspect_panel.dart';

/// The "3D Market" tab.
///
/// Dispatches [LoadMarket3DCandles], [SubscribeToMarket3DStream],
/// [LoadMarket3DDepth] and [SubscribeToMarket3DDepthStream] on mount, shows a
/// loading/error placeholder until history arrives, then hands the loaded
/// scene to [Market3DViewport] — which stays mounted and picks up every live
/// tick as `state.scene` changes underneath it. The depth terrain arrives on
/// its own schedule and simply appears once the order book snapshot lands,
/// then keeps re-meshing as the live stream ticks. An `AppBar` action toggles
/// [Market3DLoaded.depthTerrainVisible] without touching the subscription —
/// hiding the terrain just stops passing it to the viewport.
class Market3DPage extends StatefulWidget {
  const Market3DPage({super.key});

  @override
  State<Market3DPage> createState() => _Market3DPageState();
}

class _Market3DPageState extends State<Market3DPage> {
  static const _symbol = 'BTCUSDT';
  static const _interval = '1m';

  @override
  void initState() {
    super.initState();
    context
        .read<Market3DBloc>()
        .add(const LoadMarket3DCandles(symbol: _symbol, interval: _interval));
    context.read<Market3DBloc>().add(
          const SubscribeToMarket3DStream(symbol: _symbol, interval: _interval),
        );
    context.read<Market3DBloc>().add(const LoadMarket3DDepth(symbol: _symbol));
    context.read<Market3DBloc>().add(
          const SubscribeToMarket3DDepthStream(symbol: _symbol),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Market'),
        actions: [
          BlocBuilder<Market3DBloc, Market3DState>(
            builder: (context, state) {
              if (state is! Market3DLoaded) return const SizedBox.shrink();
              final visible = state.depthTerrainVisible;
              return IconButton(
                icon: Icon(visible ? Icons.terrain : Icons.terrain_outlined),
                tooltip: visible ? 'Hide depth terrain' : 'Show depth terrain',
                onPressed: () => context
                    .read<Market3DBloc>()
                    .add(const ToggleMarket3DDepthTerrain()),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0B0D12),
      body: BlocBuilder<Market3DBloc, Market3DState>(
        builder: (context, state) {
          if (state is Market3DLoaded && !state.scene.isEmpty) {
            final selected = state.selectedCandle;
            return Stack(
              children: [
                Positioned.fill(
                  child: Market3DViewport(
                    scene: state.scene,
                    depthSurface:
                        state.depthTerrainVisible ? state.depthSurface : null,
                    selectedBlockIndex: state.selectedBlockIndex,
                    onBlockTapped: (index) => context
                        .read<Market3DBloc>()
                        .add(Market3DBlockSelected(index)),
                  ),
                ),
                if (selected != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 44,
                    child: CandleInspectPanel(
                      symbol: state.symbol,
                      interval: state.interval,
                      candle: selected,
                      // The newest candle is the one still taking ticks, and
                      // only while the stream is actually connected.
                      isLive: state.isLive &&
                          state.selectedBlockIndex == state.candles.length - 1,
                      onDismiss: () => context
                          .read<Market3DBloc>()
                          .add(const Market3DBlockSelected(null)),
                    ),
                  ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Badge('${state.blockCount} blocks loaded'),
                      const SizedBox(height: 6),
                      _Badge(
                        state.isLive ? 'live' : 'reconnecting…',
                        color: state.isLive
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return Center(
            child: state is Market3DError
                ? Text(
                    'load failed: ${state.message}',
                    style: const TextStyle(color: Colors.redAccent),
                  )
                : const CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, {this.color = Colors.white});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ),
    );
  }
}
