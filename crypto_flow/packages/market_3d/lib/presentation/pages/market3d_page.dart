import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/widgets/market3d_viewport.dart';
import '../bloc/market3d/market3d_bloc.dart';
import '../bloc/market3d/market3d_event.dart';
import '../bloc/market3d/market3d_state.dart';

/// The "3D Market" tab.
///
/// Dispatches [LoadMarket3DCandles] on mount, shows a loading/error
/// placeholder until history arrives, then hands the loaded scene to
/// [Market3DViewport] for the static candlestick-city render. Live updates
/// are session 6.
class Market3DPage extends StatefulWidget {
  const Market3DPage({super.key});

  @override
  State<Market3DPage> createState() => _Market3DPageState();
}

class _Market3DPageState extends State<Market3DPage> {
  @override
  void initState() {
    super.initState();
    context.read<Market3DBloc>().add(
          const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D Market')),
      backgroundColor: const Color(0xFF0B0D12),
      body: BlocBuilder<Market3DBloc, Market3DState>(
        builder: (context, state) {
          if (state is Market3DLoaded && !state.scene.isEmpty) {
            return Stack(
              children: [
                Positioned.fill(child: Market3DViewport(scene: state.scene)),
                Positioned(
                  right: 12,
                  top: 12,
                  child: _Badge('${state.blockCount} blocks loaded'),
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
  const _Badge(this.text);

  final String text;

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
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
