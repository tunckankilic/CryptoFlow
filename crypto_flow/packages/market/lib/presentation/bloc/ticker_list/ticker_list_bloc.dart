import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/network/websocket_client.dart';
import '../../../domain/entities/ticker.dart';
import '../../../domain/repositories/market_repository.dart';
import '../../../domain/repositories/websocket_repository.dart';
import 'ticker_list_event.dart';
import 'ticker_list_state.dart';

/// BLoC for managing the ticker list with real-time updates
class TickerListBloc extends Bloc<TickerListEvent, TickerListState> {
  final MarketRepository _marketRepository;
  final WebSocketRepository _wsRepository;

  StreamSubscription? _tickerSubscription;
  StreamSubscription? _statusSubscription;
  List<Ticker> _allTickers = [];
  String? _currentFilter;
  TickerSortBy _currentSortBy = TickerSortBy.volume;
  bool _ascending = false;
  String? _searchQuery;

  TickerListBloc({
    required MarketRepository marketRepository,
    required WebSocketRepository wsRepository,
  })  : _marketRepository = marketRepository,
        _wsRepository = wsRepository,
        super(const TickerListInitial()) {
    on<LoadTickers>(_onLoadTickers);
    on<SubscribeToTickers>(_onSubscribe);
    on<UnsubscribeFromTickers>(_onUnsubscribe);
    on<TickersUpdated>(_onTickersUpdated);
    on<TickerConnectionError>(_onConnectionError);
    on<FilterTickers>(_onFilterTickers);
    on<SearchTickers>(_onSearchTickers);
    on<ClearSearch>(_onClearSearch);
  }

  /// Load initial tickers from REST API
  Future<void> _onLoadTickers(
    LoadTickers event,
    Emitter<TickerListState> emit,
  ) async {
    emit(const TickerListLoading());

    final result = await _marketRepository.getAllTickers();

    result.fold(
      (failure) => emit(TickerListError(message: failure.message)),
      (tickers) {
        _allTickers = tickers;
        emit(_buildLoadedState());
      },
    );
  }

  /// Subscribe to real-time ticker updates
  Future<void> _onSubscribe(
    SubscribeToTickers event,
    Emitter<TickerListState> emit,
  ) async {
    await _tickerSubscription?.cancel();

    // Subscribe to WebSocket status
    _statusSubscription?.cancel();
    _statusSubscription = _wsRepository.statusStream.listen((status) {
      if (state is TickerListLoaded) {
        emit((state as TickerListLoaded).copyWith(connectionStatus: status));
      }
    });

    // Subscribe to ticker updates
    final stream = event.symbols != null && event.symbols!.isNotEmpty
        ? _wsRepository.getMultipleTickersStream(event.symbols!)
        : _wsRepository.getAllMiniTickersStream();

    _tickerSubscription = stream.listen(
      (either) => either.fold(
        (failure) => add(TickerConnectionError(failure.message)),
        (tickers) => add(TickersUpdated(tickers)),
      ),
    );
  }

  /// Unsubscribe from ticker updates
  Future<void> _onUnsubscribe(
    UnsubscribeFromTickers event,
    Emitter<TickerListState> emit,
  ) async {
    await _tickerSubscription?.cancel();
    _tickerSubscription = null;

    if (state is TickerListLoaded) {
      emit((state as TickerListLoaded).copyWith(
        connectionStatus: WebSocketStatus.disconnected,
      ));
    }
  }

  /// Handle incoming ticker updates
  void _onTickersUpdated(
    TickersUpdated event,
    Emitter<TickerListState> emit,
  ) {
    // Merge updates with existing tickers
    final updatedMap = {for (var t in event.tickers) t.symbol: t};

    if (_allTickers.isEmpty) {
      // First load from WebSocket
      _allTickers = event.tickers;
    } else {
      // Merge updates
      _allTickers = _allTickers.map((t) => updatedMap[t.symbol] ?? t).toList();

      // Add any new tickers
      for (final ticker in event.tickers) {
        if (!_allTickers.any((t) => t.symbol == ticker.symbol)) {
          _allTickers.add(ticker);
        }
      }
    }

    emit(_buildLoadedState());
  }

  /// Handle connection errors
  void _onConnectionError(
    TickerConnectionError event,
    Emitter<TickerListState> emit,
  ) {
    if (state is TickerListLoaded) {
      // Keep showing cached data but indicate error
      final loaded = state as TickerListLoaded;
      emit(loaded.copyWith(connectionStatus: WebSocketStatus.error));
    } else {
      emit(TickerListError(
        message: event.message,
        cachedTickers: _allTickers.isNotEmpty ? _allTickers : null,
      ));
    }
  }

  /// Apply filters and sorting
  void _onFilterTickers(
    FilterTickers event,
    Emitter<TickerListState> emit,
  ) {
    _currentFilter = event.quoteAsset;
    _currentSortBy = event.sortBy;
    _ascending = event.ascending;

    if (_allTickers.isNotEmpty) {
      emit(_buildLoadedState());
    }
  }

  /// Handle search
  void _onSearchTickers(
    SearchTickers event,
    Emitter<TickerListState> emit,
  ) {
    _searchQuery = event.query.isEmpty ? null : event.query;

    if (_allTickers.isNotEmpty) {
      emit(_buildLoadedState());
    }
  }

  /// Clear search
  void _onClearSearch(
    ClearSearch event,
    Emitter<TickerListState> emit,
  ) {
    _searchQuery = null;

    if (_allTickers.isNotEmpty) {
      emit(_buildLoadedState());
    }
  }

  /// Build loaded state with current filters and sorting
  TickerListLoaded _buildLoadedState() {
    var filtered = List<Ticker>.from(_allTickers);

    // Apply quote asset filter
    if (_currentFilter != null && _currentFilter!.isNotEmpty) {
      filtered = filtered.where((t) => t.quoteAsset == _currentFilter).toList();
    }

    // Apply search
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toUpperCase();
      filtered = filtered
          .where((t) => t.symbol.contains(query) || t.baseAsset.contains(query))
          .toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison;
      switch (_currentSortBy) {
        case TickerSortBy.symbol:
          comparison = a.symbol.compareTo(b.symbol);
          break;
        case TickerSortBy.price:
          comparison = a.price.compareTo(b.price);
          break;
        case TickerSortBy.change:
          comparison = a.priceChangePercent.compareTo(b.priceChangePercent);
          break;
        case TickerSortBy.volume:
          comparison = a.quoteVolume.compareTo(b.quoteVolume);
          break;
      }
      return _ascending ? comparison : -comparison;
    });

    final currentStatus = state is TickerListLoaded
        ? (state as TickerListLoaded).connectionStatus
        : WebSocketStatus.disconnected;

    return TickerListLoaded(
      tickers: _allTickers,
      filteredTickers: filtered,
      activeFilter: _currentFilter,
      sortBy: _currentSortBy,
      ascending: _ascending,
      connectionStatus: currentStatus,
      searchQuery: _searchQuery,
    );
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    _statusSubscription?.cancel();
    return super.close();
  }
}
