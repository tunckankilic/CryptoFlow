import '../../domain/entities/holding.dart';

/// Data model for Holding entity
class HoldingModel extends Holding {
  const HoldingModel({
    required super.symbol,
    required super.baseAsset,
    required super.quantity,
    required super.avgBuyPrice,
    required super.firstBuyDate,
  });

  /// Create from JSON
  factory HoldingModel.fromJson(Map<String, dynamic> json) {
    return HoldingModel(
      symbol: json['symbol'] as String,
      baseAsset: json['baseAsset'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      avgBuyPrice: (json['avgBuyPrice'] as num).toDouble(),
      firstBuyDate: DateTime.parse(json['firstBuyDate'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'baseAsset': baseAsset,
      'quantity': quantity,
      'avgBuyPrice': avgBuyPrice,
      'firstBuyDate': firstBuyDate.toIso8601String(),
    };
  }

  /// Convert to domain entity
  Holding toEntity() {
    return Holding(
      symbol: symbol,
      baseAsset: baseAsset,
      quantity: quantity,
      avgBuyPrice: avgBuyPrice,
      firstBuyDate: firstBuyDate,
    );
  }

  /// Create from domain entity
  factory HoldingModel.fromEntity(Holding holding) {
    return HoldingModel(
      symbol: holding.symbol,
      baseAsset: holding.baseAsset,
      quantity: holding.quantity,
      avgBuyPrice: holding.avgBuyPrice,
      firstBuyDate: holding.firstBuyDate,
    );
  }
}
