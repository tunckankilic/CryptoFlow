import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/order_book.dart';
import '../../../domain/repositories/market_repository.dart';
import '../../../domain/repositories/websocket_repository.dart';
import 'order_book_event.dart';
import 'order_book_state.dart';

/// BLoC for managing order book data with live updates
class OrderBookBloc extends Bloc<OrderBookEvent, OrderBookState> {
  final MarketRepository _marketRepository;
  final WebSocketRepository _wsRepository;

  StreamSubscription? _orderBookSubscription;
  String? _currentSymbol;

  OrderBookBloc({
    required MarketRepository marketRepository,
    required WebSocketRepository wsRepository,
  })  : _marketRepository = marketRepository,
        _wsRepository = wsRepository,
        super(const OrderBookInitial()) {
    on<LoadOrderBook>(_onLoadOrderBook);
    on<SubscribeToOrderBook>(_onSubscribe);
    on<UnsubscribeFromOrderBook>(_onUnsubscribe);
    on<OrderBookReceived>(_onOrderBookReceived);
  }

  /// Load order book snapshot
  Future<void> _onLoadOrderBook(
    LoadOrderBook event,
    Emitter<OrderBookState> emit,
  ) async {
    emit(const OrderBookLoading());

    _currentSymbol = event.symbol;

    final result = await _marketRepository.getOrderBook(
      event.symbol,
      limit: event.depth,
    );

    result.fold(
      (failure) => emit(OrderBookError(failure.message)),
      (orderBook) => emit(OrderBookLoaded(orderBook: orderBook)),
    );
  }

  /// Subscribe to order book updates
  Future<void> _onSubscribe(
    SubscribeToOrderBook event,
    Emitter<OrderBookState> emit,
  ) async {
    await _orderBookSubscription?.cancel();

    _currentSymbol = event.symbol;

    _orderBookSubscription = _wsRepository
        .getOrderBookStream(event.symbol, depth: event.depth)
        .listen((either) => either.fold(
              (failure) {},
              (orderBook) => add(OrderBookReceived(orderBook)),
            ));

    if (state is OrderBookLoaded) {
      emit((state as OrderBookLoaded).copyWith(isLive: true));
    }
  }

  /// Unsubscribe from order book
  Future<void> _onUnsubscribe(
    UnsubscribeFromOrderBook event,
    Emitter<OrderBookState> emit,
  ) async {
    await _orderBookSubscription?.cancel();
    _orderBookSubscription = null;

    if (state is OrderBookLoaded) {
      emit((state as OrderBookLoaded).copyWith(isLive: false));
    }
  }

  /// Handle order book update
  void _onOrderBookReceived(
    OrderBookReceived event,
    Emitter<OrderBookState> emit,
  ) {
    if (event.orderBook is OrderBook) {
      final loaded =
          state is OrderBookLoaded ? (state as OrderBookLoaded).isLive : true;

      emit(OrderBookLoaded(
        orderBook: event.orderBook,
        isLive: loaded,
      ));
    }
  }

  @override
  Future<void> close() {
    _orderBookSubscription?.cancel();
    return super.close();
  }
}
