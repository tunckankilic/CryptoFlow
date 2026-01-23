import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents an item in the watchlist
@immutable
class WatchlistItem extends Equatable {
  /// Trading symbol (e.g., "BTCUSDT")
  final String symbol;

  /// Order position for sorting (0 = first, 1 = second, etc.)
  final int order;

  /// When the item was added to watchlist
  final DateTime addedAt;

  const WatchlistItem({
    required this.symbol,
    required this.order,
    required this.addedAt,
  });

  /// Creates a copy of this WatchlistItem with the given fields replaced
  WatchlistItem copyWith({
    String? symbol,
    int? order,
    DateTime? addedAt,
  }) {
    return WatchlistItem(
      symbol: symbol ?? this.symbol,
      order: order ?? this.order,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [symbol, order, addedAt];
}
