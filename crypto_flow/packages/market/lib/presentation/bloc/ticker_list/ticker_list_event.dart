import 'package:equatable/equatable.dart';
import '../../../domain/entities/ticker.dart';

/// Events for TickerListBloc
abstract class TickerListEvent extends Equatable {
  const TickerListEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial tickers from REST API
class LoadTickers extends TickerListEvent {
  const LoadTickers();
}

/// Subscribe to real-time ticker updates via WebSocket
class SubscribeToTickers extends TickerListEvent {
  final List<String>? symbols; // null = all tickers

  const SubscribeToTickers({this.symbols});

  @override
  List<Object?> get props => [symbols];
}

/// Unsubscribe from ticker updates
class UnsubscribeFromTickers extends TickerListEvent {
  const UnsubscribeFromTickers();
}

/// Internal event when tickers are updated from WebSocket
class TickersUpdated extends TickerListEvent {
  final List<Ticker> tickers;

  const TickersUpdated(this.tickers);

  @override
  List<Object?> get props => [tickers];
}

/// Internal event for WebSocket errors
class TickerConnectionError extends TickerListEvent {
  final String message;

  const TickerConnectionError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Filter tickers by quote asset and sort options
class FilterTickers extends TickerListEvent {
  final String? quoteAsset; // USDT, BTC, ETH, etc.
  final TickerSortBy sortBy;
  final bool ascending;

  const FilterTickers({
    this.quoteAsset,
    this.sortBy = TickerSortBy.volume,
    this.ascending = false,
  });

  @override
  List<Object?> get props => [quoteAsset, sortBy, ascending];
}

/// Search tickers by symbol/name
class SearchTickers extends TickerListEvent {
  final String query;

  const SearchTickers(this.query);

  @override
  List<Object?> get props => [query];
}

/// Clear search
class ClearSearch extends TickerListEvent {
  const ClearSearch();
}

/// Internal event to flush batched WebSocket updates
/// @nodoc - For internal use by TickerListBloc only
class FlushBatchedUpdatesEvent extends TickerListEvent {
  const FlushBatchedUpdatesEvent();
}

/// Sorting options for ticker list
enum TickerSortBy {
  symbol,
  price,
  change,
  volume,
}
