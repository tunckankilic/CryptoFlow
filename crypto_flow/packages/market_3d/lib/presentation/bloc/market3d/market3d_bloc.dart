import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market/market.dart';

import '../../../domain/adapters/candle_scene_adapter.dart';
import 'market3d_event.dart';
import 'market3d_state.dart';

/// BLoC for the "3D Market" tab.
///
/// Mirrors `CandleBloc`'s load + live-update pattern: fetch history via a use
/// case, emit loading/loaded/error, then subscribe to the same kline stream
/// `CandleBloc` uses and merge each tick into the loaded scene.
class Market3DBloc extends Bloc<Market3DEvent, Market3DState> {
  final GetCandlesUseCase _getCandlesUseCase;
  final GetCandleStreamUseCase _getCandleStreamUseCase;
  final CandleSceneAdapter _adapter;

  StreamSubscription? _candleSubscription;

  /// Whether the kline stream is currently subscribed.
  ///
  /// Tracked outside `Market3DState` because `Market3DPage` dispatches
  /// `LoadMarket3DCandles` and `SubscribeToMarket3DStream` together in
  /// `initState`, and the load's REST call means `SubscribeToMarket3DStream`
  /// routinely gets handled *before* the loaded state exists — `_onSubscribe`
  /// would otherwise have no `Market3DLoaded` state to mark live and the
  /// stream would connect while the UI stayed stuck on "reconnecting…"
  /// forever. `_onLoadCandles` reads this when it builds the first loaded
  /// state instead of hard-coding `isLive: false`.
  bool _isLive = false;

  Market3DBloc({
    required GetCandlesUseCase getCandlesUseCase,
    required GetCandleStreamUseCase getCandleStreamUseCase,
    CandleSceneAdapter? adapter,
  })  : _getCandlesUseCase = getCandlesUseCase,
        _getCandleStreamUseCase = getCandleStreamUseCase,
        _adapter = adapter ?? CandleSceneAdapter(),
        super(const Market3DInitial()) {
    on<LoadMarket3DCandles>(_onLoadCandles);
    on<SubscribeToMarket3DStream>(_onSubscribe);
    on<Market3DCandleReceived>(_onCandleReceived);
    on<Market3DStreamError>(_onStreamError);
  }

  Future<void> _onLoadCandles(
    LoadMarket3DCandles event,
    Emitter<Market3DState> emit,
  ) async {
    emit(const Market3DLoading());

    final result = await _getCandlesUseCase(
      CandlesParams(
        symbol: event.symbol,
        interval: event.interval,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(Market3DError(failure.message)),
      (candles) {
        final scene = _adapter.buildScene(
          symbol: event.symbol,
          interval: event.interval,
          candles: candles,
        );
        emit(Market3DLoaded(
          symbol: event.symbol,
          interval: event.interval,
          candles: candles,
          scene: scene,
          isLive: _isLive,
        ));
      },
    );
  }

  /// Subscribes to live candle updates for the loaded series.
  Future<void> _onSubscribe(
    SubscribeToMarket3DStream event,
    Emitter<Market3DState> emit,
  ) async {
    await _candleSubscription?.cancel();

    _candleSubscription = _getCandleStreamUseCase(
      CandleStreamParams(symbol: event.symbol, interval: event.interval),
    ).listen((either) => either.fold(
          (failure) {
            log('Market3DBloc: WebSocket stream error: ${failure.message}');
            if (!isClosed) add(Market3DStreamError(failure.message));
          },
          (candle) {
            if (!isClosed) add(Market3DCandleReceived(candle));
          },
        ));

    _isLive = true;
    if (state is Market3DLoaded) {
      emit((state as Market3DLoaded).copyWith(isLive: true));
    }
  }

  /// Merges a live candle into the current scene.
  ///
  /// Reuses the existing [PriceScale] via [CandleSceneAdapter.applyLiveCandle]
  /// whenever the candle is still inside it (the common, cheap case); rebuilds
  /// the whole scene only when [MarketScene.needsRescaleFor] reports the
  /// candle has escaped the range. The raw candle list is kept in lockstep
  /// with `scene.blocks` (same length, same order) rather than capped like
  /// `CandleBloc`'s 500-candle window — the block-index-based scene has no
  /// primitive for evicting the oldest block, so trimming one list without the
  /// other would desync them.
  void _onCandleReceived(
    Market3DCandleReceived event,
    Emitter<Market3DState> emit,
  ) {
    if (state is! Market3DLoaded) return;

    final loaded = state as Market3DLoaded;
    final candle = event.candle;

    final candles = List<Candle>.from(loaded.candles);
    final index = candles.indexWhere((c) => c.openTime == candle.openTime);
    if (index >= 0) {
      candles[index] = candle;
    } else {
      candles.add(candle);
    }

    final scene = loaded.scene.needsRescaleFor(candle)
        ? _adapter.buildScene(
            symbol: loaded.symbol,
            interval: loaded.interval,
            candles: candles,
          )
        : _adapter.applyLiveCandle(loaded.scene, candle);

    emit(loaded.copyWith(candles: candles, scene: scene));
  }

  /// Handle WebSocket stream errors — keep the rendered city visible.
  void _onStreamError(
    Market3DStreamError event,
    Emitter<Market3DState> emit,
  ) {
    _isLive = false;
    if (state is Market3DLoaded) {
      emit((state as Market3DLoaded).copyWith(isLive: false));
    } else {
      emit(Market3DError('Stream error: ${event.message}'));
    }
  }

  @override
  Future<void> close() {
    _candleSubscription?.cancel();
    return super.close();
  }
}
