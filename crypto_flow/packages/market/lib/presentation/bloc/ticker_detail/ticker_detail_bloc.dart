import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/ticker.dart';
import '../../../domain/entities/candle.dart';
import '../../../domain/entities/order_book.dart';
import '../../../domain/repositories/market_repository.dart';
import '../../../domain/repositories/websocket_repository.dart';
import 'ticker_detail_event.dart';
import 'ticker_detail_state.dart';

/// BLoC for managing ticker detail page with real-time updates
class TickerDetailBloc extends Bloc<TickerDetailEvent, TickerDetailState> {
  final MarketRepository _marketRepository;
  final WebSocketRepository _wsRepository;

  StreamSubscription? _tickerSubscription;
  StreamSubscription? _candleSubscription;
  StreamSubscription? _orderBookSubscription;

  String? _currentSymbol;
  String _currentInterval = '1h';

  TickerDetailBloc({
    required MarketRepository marketRepository,
    required WebSocketRepository wsRepository,
  })  : _marketRepository = marketRepository,
        _wsRepository = wsRepository,
        super(const TickerDetailInitial()) {
    on<LoadTickerDetail>(_onLoadTickerDetail);
    on<SubscribeToTickerUpdates>(_onSubscribeToTicker);
    on<UnsubscribeFromTickerUpdates>(_onUnsubscribe);
    on<ChangeInterval>(_onChangeInterval);
    on<SubscribeToOrderBook>(_onSubscribeToOrderBook);
    on<TickerUpdated>(_onTickerUpdated);
    on<CandleUpdated>(_onCandleUpdated);
    on<OrderBookUpdated>(_onOrderBookUpdated);
  }

  /// Load ticker details initially
  Future<void> _onLoadTickerDetail(
    LoadTickerDetail event,
    Emitter<TickerDetailState> emit,
  ) async {
    emit(const TickerDetailLoading());
    _currentSymbol = event.symbol;

    // Fetch ticker data
    final tickerResult = await _marketRepository.getTicker(event.symbol);

    await tickerResult.fold(
      (failure) async => emit(TickerDetailError(failure.message)),
      (ticker) async {
        // Fetch candles
        final candleResult = await _marketRepository.getCandles(
          event.symbol,
          _currentInterval,
          limit: 100,
        );

        candleResult.fold(
          (failure) => emit(TickerDetailError(failure.message)),
          (candles) => emit(TickerDetailLoaded(
            ticker: ticker,
            candles: candles,
            interval: _currentInterval,
          )),
        );
      },
    );
  }

  /// Subscribe to real-time ticker updates
  Future<void> _onSubscribeToTicker(
    SubscribeToTickerUpdates event,
    Emitter<TickerDetailState> emit,
  ) async {
    await _tickerSubscription?.cancel();
    await _candleSubscription?.cancel();

    _currentSymbol = event.symbol;

    // Subscribe to ticker stream
    _tickerSubscription = _wsRepository.getTickerStream(event.symbol).listen(
          (either) => either.fold(
            (failure) {},
            (ticker) => add(TickerUpdated(ticker)),
          ),
        );

    // Subscribe to candle stream
    _candleSubscription =
        _wsRepository.getCandleStream(event.symbol, _currentInterval).listen(
              (either) => either.fold(
                (failure) {},
                (candle) => add(CandleUpdated(candle)),
              ),
            );

    if (state is TickerDetailLoaded) {
      emit((state as TickerDetailLoaded).copyWith(isLiveUpdating: true));
    }
  }

  /// Unsubscribe from all streams
  Future<void> _onUnsubscribe(
    UnsubscribeFromTickerUpdates event,
    Emitter<TickerDetailState> emit,
  ) async {
    await _tickerSubscription?.cancel();
    await _candleSubscription?.cancel();
    await _orderBookSubscription?.cancel();

    _tickerSubscription = null;
    _candleSubscription = null;
    _orderBookSubscription = null;

    if (state is TickerDetailLoaded) {
      emit((state as TickerDetailLoaded).copyWith(isLiveUpdating: false));
    }
  }

  /// Change chart interval
  Future<void> _onChangeInterval(
    ChangeInterval event,
    Emitter<TickerDetailState> emit,
  ) async {
    if (_currentSymbol == null) return;

    _currentInterval = event.interval;

    // Fetch new candles for interval
    final result = await _marketRepository.getCandles(
      _currentSymbol!,
      event.interval,
      limit: 100,
    );

    result.fold(
      (failure) {},
      (candles) {
        if (state is TickerDetailLoaded) {
          emit((state as TickerDetailLoaded).copyWith(
            candles: candles,
            interval: event.interval,
          ));

          // Resubscribe to candle stream with new interval
          _candleSubscription?.cancel();
          _candleSubscription = _wsRepository
              .getCandleStream(_currentSymbol!, event.interval)
              .listen(
                (either) => either.fold(
                  (failure) {},
                  (candle) => add(CandleUpdated(candle)),
                ),
              );
        }
      },
    );
  }

  /// Subscribe to order book updates
  Future<void> _onSubscribeToOrderBook(
    SubscribeToOrderBook event,
    Emitter<TickerDetailState> emit,
  ) async {
    await _orderBookSubscription?.cancel();

    _orderBookSubscription = _wsRepository
        .getOrderBookStream(event.symbol, depth: event.depth)
        .listen(
          (either) => either.fold(
            (failure) {},
            (orderBook) => add(OrderBookUpdated(orderBook)),
          ),
        );
  }

  /// Handle ticker update
  void _onTickerUpdated(
    TickerUpdated event,
    Emitter<TickerDetailState> emit,
  ) {
    if (state is TickerDetailLoaded && event.ticker is Ticker) {
      emit((state as TickerDetailLoaded).copyWith(ticker: event.ticker));
    }
  }

  /// Handle candle update
  void _onCandleUpdated(
    CandleUpdated event,
    Emitter<TickerDetailState> emit,
  ) {
    if (state is TickerDetailLoaded && event.candle is Candle) {
      final loaded = state as TickerDetailLoaded;
      final candle = event.candle as Candle;

      // Update or add candle
      final candles = List<Candle>.from(loaded.candles);
      final index = candles.indexWhere(
        (c) => c.openTime == candle.openTime,
      );

      if (index >= 0) {
        candles[index] = candle;
      } else {
        candles.add(candle);
        // Keep only last 100 candles
        if (candles.length > 100) {
          candles.removeAt(0);
        }
      }

      emit(loaded.copyWith(candles: candles));
    }
  }

  /// Handle order book update
  void _onOrderBookUpdated(
    OrderBookUpdated event,
    Emitter<TickerDetailState> emit,
  ) {
    if (state is TickerDetailLoaded && event.orderBook is OrderBook) {
      emit((state as TickerDetailLoaded).copyWith(orderBook: event.orderBook));
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    _candleSubscription?.cancel();
    _orderBookSubscription?.cancel();
    return super.close();
  }
}
