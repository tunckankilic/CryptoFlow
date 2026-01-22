import 'package:equatable/equatable.dart';
import '../../domain/entities/watchlist_item.dart';

/// Base class for all watchlist events
abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

/// Load watchlist
class LoadWatchlist extends WatchlistEvent {
  const LoadWatchlist();
}

/// Add symbol to watchlist
class AddToWatchlistEvent extends WatchlistEvent {
  final String symbol;

  const AddToWatchlistEvent(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

/// Remove symbol from watchlist
class RemoveFromWatchlistEvent extends WatchlistEvent {
  final String symbol;

  const RemoveFromWatchlistEvent(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

/// Reorder watchlist
class ReorderWatchlistEvent extends WatchlistEvent {
  final List<WatchlistItem> items;

  const ReorderWatchlistEvent(this.items);

  @override
  List<Object?> get props => [items];
}

/// Watchlist updated from storage
class WatchlistUpdated extends WatchlistEvent {
  const WatchlistUpdated();
}
