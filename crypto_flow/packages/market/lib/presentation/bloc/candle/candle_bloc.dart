import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/candle.dart';
import '../../../domain/entities/indicator_type.dart';
import '../../../domain/entities/macd_result.dart';
import '../../../domain/repositories/market_repository.dart';
import '../../../domain/repositories/websocket_repository.dart';
import '../../../domain/services/technical_indicators.dart';
import 'candle_event.dart';
import 'candle_state.dart';

/// BLoC for managing candlestick data with live updates and technical indicators
class CandleBloc extends Bloc<CandleEvent, CandleState> {
  final MarketRepository _marketRepository;
  final WebSocketRepository _wsRepository;

  StreamSubscription? _candleSubscription;
  String? _currentSymbol;
  String _currentInterval = '1h';

  CandleBloc({
    required MarketRepository marketRepository,
    required WebSocketRepository wsRepository,
  })  : _marketRepository = marketRepository,
        _wsRepository = wsRepository,
        super(const CandleInitial()) {
    on<LoadCandles>(_onLoadCandles);
    on<SubscribeToCandleStream>(_onSubscribe);
    on<UnsubscribeFromCandleStream>(_onUnsubscribe);
    on<ChangeCandleInterval>(_onChangeInterval);
    on<CandleReceived>(_onCandleReceived);
    on<ToggleIndicator>(_onToggleIndicator);
  }

  /// Load historical candles
  Future<void> _onLoadCandles(
    LoadCandles event,
    Emitter<CandleState> emit,
  ) async {
    emit(const CandleLoading());

    _currentSymbol = event.symbol;
    _currentInterval = event.interval;

    final result = await _marketRepository.getCandles(
      event.symbol,
      event.interval,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(CandleError(failure.message)),
      (candles) {
        final loadedState = CandleLoaded(
          symbol: event.symbol,
          candles: candles,
          interval: event.interval,
        );
        emit(loadedState);
      },
    );
  }

  /// Subscribe to live candle updates
  Future<void> _onSubscribe(
    SubscribeToCandleStream event,
    Emitter<CandleState> emit,
  ) async {
    await _candleSubscription?.cancel();

    _currentSymbol = event.symbol;
    _currentInterval = event.interval;

    _candleSubscription = _wsRepository
        .getCandleStream(event.symbol, event.interval)
        .listen((either) => either.fold(
              (failure) {},
              (candle) => add(CandleReceived(candle)),
            ));

    if (state is CandleLoaded) {
      emit((state as CandleLoaded).copyWith(isLive: true));
    }
  }

  /// Unsubscribe from candle stream
  Future<void> _onUnsubscribe(
    UnsubscribeFromCandleStream event,
    Emitter<CandleState> emit,
  ) async {
    await _candleSubscription?.cancel();
    _candleSubscription = null;

    if (state is CandleLoaded) {
      emit((state as CandleLoaded).copyWith(isLive: false));
    }
  }

  /// Change interval and reload
  Future<void> _onChangeInterval(
    ChangeCandleInterval event,
    Emitter<CandleState> emit,
  ) async {
    if (_currentSymbol == null) return;

    _currentInterval = event.interval;

    // Reload candles with new interval
    add(LoadCandles(
      symbol: _currentSymbol!,
      interval: event.interval,
    ));

    // Resubscribe to stream with new interval
    await _candleSubscription?.cancel();
    _candleSubscription = _wsRepository
        .getCandleStream(_currentSymbol!, event.interval)
        .listen((either) => either.fold(
              (failure) {},
              (candle) => add(CandleReceived(candle)),
            ));
  }

  /// Handle incoming candle update
  void _onCandleReceived(
    CandleReceived event,
    Emitter<CandleState> emit,
  ) {
    if (state is CandleLoaded && event.candle is Candle) {
      final loaded = state as CandleLoaded;
      final candle = event.candle as Candle;

      final candles = List<Candle>.from(loaded.candles);

      // Find and update existing candle or add new one
      final index = candles.indexWhere(
        (c) => c.openTime == candle.openTime,
      );

      if (index >= 0) {
        candles[index] = candle;
      } else {
        candles.add(candle);
        // Keep reasonable limit
        if (candles.length > 500) {
          candles.removeAt(0);
        }
      }

      // Recalculate indicators if any are active
      final newState = loaded.copyWith(candles: candles);
      emit(_recalculateIndicators(newState));
    }
  }

  /// Toggle a technical indicator on/off
  void _onToggleIndicator(
    ToggleIndicator event,
    Emitter<CandleState> emit,
  ) {
    if (state is! CandleLoaded) return;

    final loaded = state as CandleLoaded;
    final activeIndicators = Set<IndicatorType>.from(loaded.activeIndicators);

    if (activeIndicators.contains(event.indicator)) {
      activeIndicators.remove(event.indicator);
    } else {
      activeIndicators.add(event.indicator);
    }

    final newState = loaded.copyWith(activeIndicators: activeIndicators);
    emit(_recalculateIndicators(newState));
  }

  /// Recalculate all active indicators
  CandleLoaded _recalculateIndicators(CandleLoaded state) {
    if (state.activeIndicators.isEmpty) {
      return state.copyWith(
        rsiValues: const [],
        emaValues: const {},
        smaValues: const [],
        macdResult: null,
      );
    }

    List<double?> rsiValues = state.rsiValues;
    Map<int, List<double?>> emaValues = Map.from(state.emaValues);
    List<double?> smaValues = state.smaValues;
    MACDResult? macdResult = state.macdResult;

    for (final indicator in state.activeIndicators) {
      switch (indicator) {
        case IndicatorType.rsi:
          rsiValues = TechnicalIndicators.calculateRSI(state.candles);
          break;
        case IndicatorType.ema9:
          emaValues[9] = TechnicalIndicators.calculateEMA(
            state.candles,
            period: 9,
          );
          break;
        case IndicatorType.ema21:
          emaValues[21] = TechnicalIndicators.calculateEMA(
            state.candles,
            period: 21,
          );
          break;
        case IndicatorType.ema50:
          emaValues[50] = TechnicalIndicators.calculateEMA(
            state.candles,
            period: 50,
          );
          break;
        case IndicatorType.sma20:
          smaValues = TechnicalIndicators.calculateSMA(state.candles);
          break;
        case IndicatorType.macd:
          macdResult = TechnicalIndicators.calculateMACD(state.candles);
          break;
      }
    }

    return state.copyWith(
      rsiValues: rsiValues,
      emaValues: emaValues,
      smaValues: smaValues,
      macdResult: macdResult,
    );
  }

  @override
  Future<void> close() {
    _candleSubscription?.cancel();
    return super.close();
  }
}
