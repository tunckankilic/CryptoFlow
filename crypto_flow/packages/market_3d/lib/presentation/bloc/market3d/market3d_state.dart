import 'package:equatable/equatable.dart';
import 'package:market/market.dart';

import '../../../domain/models/candle_block.dart';
import '../../../domain/models/market_scene.dart';

/// States for [Market3DBloc].
abstract class Market3DState extends Equatable {
  const Market3DState();

  @override
  List<Object?> get props => [];
}

/// Initial state, before any load has been requested.
class Market3DInitial extends Market3DState {
  const Market3DInitial();
}

/// History fetch in flight.
class Market3DLoading extends Market3DState {
  const Market3DLoading();
}

/// History loaded and adapted into scene geometry.
class Market3DLoaded extends Market3DState {
  /// Symbol being tracked.
  final String symbol;

  /// Candle interval.
  final String interval;

  /// Raw candles as returned by [GetCandlesUseCase].
  final List<Candle> candles;

  /// The full scene adapted from [candles] by [CandleSceneAdapter] — carries
  /// the [PriceScale] and [SceneLayout] alongside the blocks, which is what
  /// [MarketSceneRenderer.setScene] needs to place and frame the city.
  final MarketScene scene;

  /// The scene's blocks, oldest first.
  List<CandleBlock> get blocks => scene.blocks;

  /// Number of blocks adapted — the debug count shown on the tab.
  int get blockCount => blocks.length;

  const Market3DLoaded({
    required this.symbol,
    required this.interval,
    required this.candles,
    required this.scene,
  });

  @override
  List<Object?> get props => [symbol, interval, candles, scene];
}

/// History fetch failed.
class Market3DError extends Market3DState {
  final String message;

  const Market3DError(this.message);

  @override
  List<Object?> get props => [message];
}
