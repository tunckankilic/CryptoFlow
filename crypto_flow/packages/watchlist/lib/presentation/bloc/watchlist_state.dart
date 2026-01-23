import 'package:equatable/equatable.dart';
import '../../domain/entities/watchlist_item.dart';

/// Base class for all watchlist states
abstract class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class WatchlistInitial extends WatchlistState {
  const WatchlistInitial();
}

/// Loading watchlist
class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();
}

/// Watchlist loaded
class WatchlistLoaded extends WatchlistState {
  final List<WatchlistItem> items;
  final Map<String, bool> inWatchlistCache;

  const WatchlistLoaded({
    required this.items,
    this.inWatchlistCache = const {},
  });

  WatchlistLoaded copyWith({
    List<WatchlistItem>? items,
    Map<String, bool>? inWatchlistCache,
  }) {
    return WatchlistLoaded(
      items: items ?? this.items,
      inWatchlistCache: inWatchlistCache ?? this.inWatchlistCache,
    );
  }

  @override
  List<Object?> get props => [items, inWatchlistCache];
}

/// Error loading watchlist
class WatchlistError extends WatchlistState {
  final String message;

  const WatchlistError({required this.message});

  @override
  List<Object?> get props => [message];
}
