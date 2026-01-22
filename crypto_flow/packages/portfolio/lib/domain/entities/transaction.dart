import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Types of portfolio transactions
enum TransactionType {
  buy,
  sell,
  transferIn,
  transferOut,
}

/// Extension for TransactionType display and serialization
extension TransactionTypeX on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.buy:
        return 'Buy';
      case TransactionType.sell:
        return 'Sell';
      case TransactionType.transferIn:
        return 'Transfer In';
      case TransactionType.transferOut:
        return 'Transfer Out';
    }
  }

  String toJson() {
    switch (this) {
      case TransactionType.buy:
        return 'buy';
      case TransactionType.sell:
        return 'sell';
      case TransactionType.transferIn:
        return 'transfer_in';
      case TransactionType.transferOut:
        return 'transfer_out';
    }
  }

  static TransactionType fromJson(String json) {
    switch (json) {
      case 'buy':
        return TransactionType.buy;
      case 'sell':
        return TransactionType.sell;
      case 'transfer_in':
        return TransactionType.transferIn;
      case 'transfer_out':
        return TransactionType.transferOut;
      default:
        throw ArgumentError('Unknown transaction type: $json');
    }
  }

  /// Check if transaction increases holdings
  bool get isIncoming =>
      this == TransactionType.buy || this == TransactionType.transferIn;

  /// Check if transaction decreases holdings
  bool get isOutgoing =>
      this == TransactionType.sell || this == TransactionType.transferOut;
}

/// Represents a portfolio transaction (buy, sell, transfer)
@immutable
class Transaction extends Equatable {
  /// Unique transaction identifier
  final String id;

  /// Trading symbol (e.g., "BTCUSDT")
  final String symbol;

  /// Transaction type
  final TransactionType type;

  /// Quantity of asset
  final double quantity;

  /// Price per unit at transaction time
  final double price;

  /// Optional transaction fee
  final double? fee;

  /// Asset used for fee payment (e.g., "BNB", same as trading asset)
  final String? feeAsset;

  /// Transaction timestamp
  final DateTime timestamp;

  /// Optional note/description
  final String? note;

  const Transaction({
    required this.id,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.price,
    this.fee,
    this.feeAsset,
    required this.timestamp,
    this.note,
  });

  /// Calculate total cost including fees (for buys)
  double get totalCost {
    final baseCost = quantity * price;
    if (fee != null && feeAsset == null) {
      // Fee is in the same asset being traded
      return baseCost + fee!;
    }
    return baseCost;
  }

  /// Calculate total received after fees (for sells)
  double get totalReceived {
    final baseReceived = quantity * price;
    if (fee != null && feeAsset == null) {
      // Fee is in the same asset being traded
      return baseReceived - fee!;
    }
    return baseReceived;
  }

  /// Creates a copy of this Transaction with the given fields replaced
  Transaction copyWith({
    String? id,
    String? symbol,
    TransactionType? type,
    double? quantity,
    double? price,
    double? fee,
    String? feeAsset,
    DateTime? timestamp,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      fee: fee ?? this.fee,
      feeAsset: feeAsset ?? this.feeAsset,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [
        id,
        symbol,
        type,
        quantity,
        price,
        fee,
        feeAsset,
        timestamp,
        note,
      ];
}
