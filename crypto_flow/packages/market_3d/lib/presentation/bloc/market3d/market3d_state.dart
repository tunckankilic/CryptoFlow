import 'package:equatable/equatable.dart';
import 'package:market/market.dart';

import '../../../domain/models/candle_block.dart';
import '../../../domain/models/depth_surface.dart';
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

  /// Whether the live stream is currently connected.
  ///
  /// Mirrors `CandleLoaded.isLive`: true once `SubscribeToMarket3DStream` has
  /// been handled, false again on a stream error, so a reconnect drop is
  /// visible without tearing down the rendered city.
  final bool isLive;

  /// Index of the candle the user tapped, or `null` when nothing is selected.
  ///
  /// Indices are shared by [candles] and `scene.blocks` — the bloc keeps the
  /// two lists in lockstep — so one index addresses both the geometry to
  /// highlight and the OHLC data to show.
  final int? selectedBlockIndex;

  /// Order book depth terrain, or `null` before the first snapshot lands.
  ///
  /// Independent of [scene]: the terrain comes from a different endpoint on
  /// its own schedule, and a failed order book fetch must leave the city
  /// standing rather than take the whole tab down with it.
  final DepthSurface? depthSurface;

  const Market3DLoaded({
    required this.symbol,
    required this.interval,
    required this.candles,
    required this.scene,
    this.isLive = false,
    this.selectedBlockIndex,
    this.depthSurface,
  });

  /// The candle behind the current selection, or `null` when nothing is
  /// selected (or the index no longer addresses a loaded candle).
  Candle? get selectedCandle {
    final index = selectedBlockIndex;
    if (index == null || index < 0 || index >= candles.length) return null;
    return candles[index];
  }

  /// Creates a copy with the given fields replaced.
  ///
  /// [clearSelection] exists because `null` is a meaningful selection value:
  /// passing `selectedBlockIndex: null` means "leave it alone" like every
  /// other field here, so dismissing needs its own flag.
  Market3DLoaded copyWith({
    List<Candle>? candles,
    MarketScene? scene,
    bool? isLive,
    int? selectedBlockIndex,
    bool clearSelection = false,
    DepthSurface? depthSurface,
  }) {
    return Market3DLoaded(
      symbol: symbol,
      interval: interval,
      candles: candles ?? this.candles,
      scene: scene ?? this.scene,
      isLive: isLive ?? this.isLive,
      selectedBlockIndex:
          clearSelection ? null : selectedBlockIndex ?? this.selectedBlockIndex,
      depthSurface: depthSurface ?? this.depthSurface,
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        interval,
        candles,
        scene,
        isLive,
        selectedBlockIndex,
        depthSurface,
      ];
}

/// History fetch failed.
class Market3DError extends Market3DState {
  final String message;

  const Market3DError(this.message);

  @override
  List<Object?> get props => [message];
}
