import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents a cryptocurrency holding in the portfolio
@immutable
class Holding extends Equatable {
  /// Trading symbol (e.g., "BTCUSDT")
  final String symbol;

  /// Base asset (e.g., "BTC")
  final String baseAsset;

  /// Total quantity held
  final double quantity;

  /// Average buy price (cost basis)
  final double avgBuyPrice;

  /// Date of first purchase
  final DateTime firstBuyDate;

  const Holding({
    required this.symbol,
    required this.baseAsset,
    required this.quantity,
    required this.avgBuyPrice,
    required this.firstBuyDate,
  });

  /// Calculate current value based on market price
  double currentValue(double currentPrice) => quantity * currentPrice;

  /// Calculate profit/loss in absolute terms
  double pnl(double currentPrice) =>
      currentValue(currentPrice) - (quantity * avgBuyPrice);

  /// Calculate profit/loss as a percentage
  double pnlPercent(double currentPrice) =>
      ((currentPrice - avgBuyPrice) / avgBuyPrice) * 100;

  /// Check if position is profitable
  bool isProfit(double currentPrice) => pnl(currentPrice) >= 0;

  /// Total cost basis (amount invested)
  double get totalCost => quantity * avgBuyPrice;

  /// Creates a copy of this Holding with the given fields replaced
  Holding copyWith({
    String? symbol,
    String? baseAsset,
    double? quantity,
    double? avgBuyPrice,
    DateTime? firstBuyDate,
  }) {
    return Holding(
      symbol: symbol ?? this.symbol,
      baseAsset: baseAsset ?? this.baseAsset,
      quantity: quantity ?? this.quantity,
      avgBuyPrice: avgBuyPrice ?? this.avgBuyPrice,
      firstBuyDate: firstBuyDate ?? this.firstBuyDate,
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        baseAsset,
        quantity,
        avgBuyPrice,
        firstBuyDate,
      ];
}
