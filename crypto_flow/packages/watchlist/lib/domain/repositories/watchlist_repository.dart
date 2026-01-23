import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/watchlist_item.dart';

/// Abstract repository interface for watchlist operations
abstract class WatchlistRepository {
  /// Get all watchlist items
  Future<Either<Failure, List<WatchlistItem>>> getWatchlist();

  /// Add a symbol to watchlist
  Future<Either<Failure, void>> addToWatchlist(String symbol);

  /// Remove a symbol from watchlist
  Future<Either<Failure, void>> removeFromWatchlist(String symbol);

  /// Check if symbol is in watchlist
  Future<Either<Failure, bool>> isInWatchlist(String symbol);

  /// Reorder watchlist items
  Future<Either<Failure, void>> reorderWatchlist(List<WatchlistItem> items);

  /// Watch watchlist for real-time updates
  Stream<List<WatchlistItem>> watchWatchlist();
}
