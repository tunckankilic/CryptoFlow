import 'package:equatable/equatable.dart';
import 'package:core/network/websocket_client.dart';
import '../../../domain/entities/ticker.dart';
import 'ticker_list_event.dart';

/// States for TickerListBloc
abstract class TickerListState extends Equatable {
  const TickerListState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class TickerListInitial extends TickerListState {
  const TickerListInitial();
}

/// Loading state while fetching tickers
class TickerListLoading extends TickerListState {
  const TickerListLoading();
}

/// Loaded state with ticker data
class TickerListLoaded extends TickerListState {
  /// All tickers (unfiltered)
  final List<Ticker> tickers;

  /// Filtered and sorted tickers for display
  final List<Ticker> filteredTickers;

  /// Currently active quote asset filter (null = all)
  final String? activeFilter;

  /// Current sort criteria
  final TickerSortBy sortBy;

  /// Sort direction
  final bool ascending;

  /// WebSocket connection status
  final WebSocketStatus connectionStatus;

  /// Search query if active
  final String? searchQuery;

  const TickerListLoaded({
    required this.tickers,
    required this.filteredTickers,
    this.activeFilter,
    this.sortBy = TickerSortBy.volume,
    this.ascending = false,
    this.connectionStatus = WebSocketStatus.disconnected,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
        tickers,
        filteredTickers,
        activeFilter,
        sortBy,
        ascending,
        connectionStatus,
        searchQuery,
      ];

  /// Create a copy with some fields replaced
  TickerListLoaded copyWith({
    List<Ticker>? tickers,
    List<Ticker>? filteredTickers,
    String? activeFilter,
    bool clearFilter = false,
    TickerSortBy? sortBy,
    bool? ascending,
    WebSocketStatus? connectionStatus,
    String? searchQuery,
    bool clearSearch = false,
  }) {
    return TickerListLoaded(
      tickers: tickers ?? this.tickers,
      filteredTickers: filteredTickers ?? this.filteredTickers,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
    );
  }
}

/// Error state
class TickerListError extends TickerListState {
  final String message;

  /// Cached tickers to show while in error state
  final List<Ticker>? cachedTickers;

  const TickerListError({
    required this.message,
    this.cachedTickers,
  });

  @override
  List<Object?> get props => [message, cachedTickers];
}
