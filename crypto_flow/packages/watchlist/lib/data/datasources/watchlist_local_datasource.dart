import 'package:core/error/exceptions.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/watchlist_item.dart';
import '../models/watchlist_item_model.dart';

/// Local data source for watchlist using Hive
class WatchlistLocalDataSource {
  static const String _boxName = 'watchlist';
  Box<WatchlistItemModel>? _watchlistBox;

  /// Initialize Hive and open box
  Future<void> init() async {
    if (_watchlistBox == null || !_watchlistBox!.isOpen) {
      _watchlistBox = await Hive.openBox<WatchlistItemModel>(_boxName);
    }
  }

  /// Get all watchlist items sorted by order
  Future<List<WatchlistItem>> getWatchlist() async {
    try {
      await init();
      final items = _watchlistBox!.values.map((m) => m.toEntity()).toList();
      items.sort((a, b) => a.order.compareTo(b.order));
      return items;
    } catch (e) {
      throw CacheException(message: 'Failed to get watchlist: $e');
    }
  }

  /// Add symbol to watchlist
  Future<void> addToWatchlist(String symbol) async {
    try {
      await init();

      // Check if already exists
      final existing = _watchlistBox!.values.firstWhere(
          (item) => item.hiveSymbol == symbol,
          orElse: () => WatchlistItemModel(
              hiveSymbol: '', hiveOrder: -1, hiveAddedAt: 0));

      if (existing.hiveSymbol.isNotEmpty) {
        return; // Already in watchlist
      }

      // Find next order number
      final maxOrder = _watchlistBox!.values.isEmpty
          ? -1
          : _watchlistBox!.values
              .map((item) => item.hiveOrder)
              .reduce((a, b) => a > b ? a : b);

      final model = WatchlistItemModel(
        hiveSymbol: symbol,
        hiveOrder: maxOrder + 1,
        hiveAddedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await _watchlistBox!.put(symbol, model);
    } catch (e) {
      throw CacheException(message: 'Failed to add to watchlist: $e');
    }
  }

  /// Remove symbol from watchlist
  Future<void> removeFromWatchlist(String symbol) async {
    try {
      await init();
      await _watchlistBox!.delete(symbol);
    } catch (e) {
      throw CacheException(message: 'Failed to remove from watchlist: $e');
    }
  }

  /// Check if symbol is in watchlist
  Future<bool> isInWatchlist(String symbol) async {
    try {
      await init();
      return _watchlistBox!.containsKey(symbol);
    } catch (e) {
      throw CacheException(message: 'Failed to check watchlist: $e');
    }
  }

  /// Reorder watchlist items
  Future<void> reorderWatchlist(List<WatchlistItem> items) async {
    try {
      await init();

      // Update each item with new order
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final updated = WatchlistItemModel.fromEntity(
          item.copyWith(order: i),
        );
        await _watchlistBox!.put(item.symbol, updated);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to reorder watchlist: $e');
    }
  }

  /// Watch watchlist for real-time updates
  Stream<List<WatchlistItem>> watchWatchlist() {
    try {
      return _watchlistBox!.watch().map((_) {
        final items = _watchlistBox!.values.map((m) => m.toEntity()).toList();
        items.sort((a, b) => a.order.compareTo(b.order));
        return items;
      });
    } catch (e) {
      throw CacheException(message: 'Failed to watch watchlist: $e');
    }
  }

  /// Close the box
  Future<void> close() async {
    await _watchlistBox?.close();
  }
}
