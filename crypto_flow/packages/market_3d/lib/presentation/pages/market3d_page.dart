import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/widgets/market3d_viewport.dart';
import '../bloc/market3d/market3d_bloc.dart';
import '../bloc/market3d/market3d_event.dart';
import '../bloc/market3d/market3d_state.dart';

/// The "3D Market" tab.
///
/// Hosts [Market3DViewport] (the S2/S3 test scene; engine-specific code stays
/// confined to `data/`) plus a debug overlay showing how many candles
/// [Market3DBloc] has loaded from real BTCUSDT history. The viewport still
/// renders the fixed test candles — driving the city from loaded data is
/// session 5.
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
      body: Stack(
        children: [
          const Positioned.fill(child: Market3DViewport()),
          Positioned(
            right: 12,
            top: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: BlocBuilder<Market3DBloc, Market3DState>(
                  builder: (context, state) => Text(
                    _debugText(state),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _debugText(Market3DState state) {
    if (state is Market3DLoading) return 'loading history…';
    if (state is Market3DLoaded) return '${state.blockCount} blocks loaded';
    if (state is Market3DError) return 'load failed: ${state.message}';
    return 'idle';
  }
}
