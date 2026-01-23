import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents an order book with bids and asks
@immutable
class OrderBook extends Equatable {
  /// Trading pair symbol
  final String symbol;

  /// List of bid (buy) orders, sorted by price descending
  final List<OrderBookEntry> bids;

  /// List of ask (sell) orders, sorted by price ascending
  final List<OrderBookEntry> asks;

  /// Last update ID from exchange
  final int lastUpdateId;

  const OrderBook({
    required this.symbol,
    required this.bids,
    required this.asks,
    required this.lastUpdateId,
  });

  /// Returns the spread (difference between best ask and best bid)
  double get spread => asks.isNotEmpty && bids.isNotEmpty
      ? asks.first.price - bids.first.price
      : 0;

  /// Returns the spread as a percentage of the best bid
  double get spreadPercent =>
      bids.isNotEmpty && spread > 0 ? (spread / bids.first.price) * 100 : 0;

  /// Returns the mid-market price
  double get midPrice => asks.isNotEmpty && bids.isNotEmpty
      ? (bids.first.price + asks.first.price) / 2
      : 0;

  /// Returns the best bid price
  double get bestBid => bids.isNotEmpty ? bids.first.price : 0;

  /// Returns the best ask price
  double get bestAsk => asks.isNotEmpty ? asks.first.price : 0;

  /// Returns the total bid volume
  double get totalBidVolume =>
      bids.fold(0.0, (sum, entry) => sum + entry.quantity);

  /// Returns the total ask volume
  double get totalAskVolume =>
      asks.fold(0.0, (sum, entry) => sum + entry.quantity);

  /// Returns the bid/ask volume ratio (> 1 means more buyers)
  double get volumeRatio =>
      totalAskVolume > 0 ? totalBidVolume / totalAskVolume : 0;

  /// Creates a copy of this OrderBook with the given fields replaced
  OrderBook copyWith({
    String? symbol,
    List<OrderBookEntry>? bids,
    List<OrderBookEntry>? asks,
    int? lastUpdateId,
  }) {
    return OrderBook(
      symbol: symbol ?? this.symbol,
      bids: bids ?? this.bids,
      asks: asks ?? this.asks,
      lastUpdateId: lastUpdateId ?? this.lastUpdateId,
    );
  }

  @override
  List<Object?> get props => [symbol, bids, asks, lastUpdateId];
}

/// Represents a single entry in the order book (bid or ask)
@immutable
class OrderBookEntry extends Equatable {
  /// Price level
  final double price;

  /// Quantity at this price level
  final double quantity;

  const OrderBookEntry({
    required this.price,
    required this.quantity,
  });

  /// Returns the total value at this price level
  double get total => price * quantity;

  /// Creates a copy of this entry with the given fields replaced
  OrderBookEntry copyWith({
    double? price,
    double? quantity,
  }) {
    return OrderBookEntry(
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [price, quantity];
}
