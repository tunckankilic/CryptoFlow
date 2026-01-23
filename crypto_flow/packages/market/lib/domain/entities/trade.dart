import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents a single trade execution
@immutable
class Trade extends Equatable {
  /// Unique trade ID
  final int id;

  /// Trading pair symbol
  final String symbol;

  /// Trade price
  final double price;

  /// Trade quantity
  final double quantity;

  /// Trade timestamp
  final DateTime time;

  /// Whether the buyer was the maker
  final bool isBuyerMaker;

  /// Whether this was the best price match
  final bool isBestMatch;

  const Trade({
    required this.id,
    required this.symbol,
    required this.price,
    required this.quantity,
    required this.time,
    required this.isBuyerMaker,
    this.isBestMatch = true,
  });

  /// Returns the total value of this trade
  double get total => price * quantity;

  /// Returns true if this was a buy (taker was buyer)
  bool get isBuy => !isBuyerMaker;

  /// Returns true if this was a sell (taker was seller)
  bool get isSell => isBuyerMaker;

  /// Creates a copy of this Trade with the given fields replaced
  Trade copyWith({
    int? id,
    String? symbol,
    double? price,
    double? quantity,
    DateTime? time,
    bool? isBuyerMaker,
    bool? isBestMatch,
  }) {
    return Trade(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      time: time ?? this.time,
      isBuyerMaker: isBuyerMaker ?? this.isBuyerMaker,
      isBestMatch: isBestMatch ?? this.isBestMatch,
    );
  }

  @override
  List<Object?> get props => [
        id,
        symbol,
        price,
        quantity,
        time,
        isBuyerMaker,
        isBestMatch,
      ];
}
