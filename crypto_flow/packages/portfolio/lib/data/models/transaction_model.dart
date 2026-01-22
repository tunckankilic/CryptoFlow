import '../../domain/entities/transaction.dart';

/// Data model for Transaction entity
class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.symbol,
    required super.type,
    required super.quantity,
    required super.price,
    super.fee,
    super.feeAsset,
    required super.timestamp,
    super.note,
  });

  /// Create from JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      type: TransactionTypeX.fromJson(json['type'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      fee: json['fee'] != null ? (json['fee'] as num).toDouble() : null,
      feeAsset: json['feeAsset'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'type': type.toJson(),
      'quantity': quantity,
      'price': price,
      'fee': fee,
      'feeAsset': feeAsset,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  /// Convert to domain entity
  Transaction toEntity() {
    return Transaction(
      id: id,
      symbol: symbol,
      type: type,
      quantity: quantity,
      price: price,
      fee: fee,
      feeAsset: feeAsset,
      timestamp: timestamp,
      note: note,
    );
  }

  /// Create from domain entity
  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      symbol: transaction.symbol,
      type: transaction.type,
      quantity: transaction.quantity,
      price: transaction.price,
      fee: transaction.fee,
      feeAsset: transaction.feeAsset,
      timestamp: transaction.timestamp,
      note: transaction.note,
    );
  }
}
