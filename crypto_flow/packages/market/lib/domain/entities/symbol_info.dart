import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents information about a trading symbol/pair
@immutable
class SymbolInfo extends Equatable {
  /// Symbol name (e.g., "BTCUSDT")
  final String symbol;

  /// Base asset (e.g., "BTC")
  final String baseAsset;

  /// Quote asset (e.g., "USDT")
  final String quoteAsset;

  /// Trading status
  final SymbolStatus status;

  /// Base asset precision (decimal places)
  final int baseAssetPrecision;

  /// Quote asset precision (decimal places)
  final int quoteAssetPrecision;

  /// Minimum quantity allowed
  final double? minQty;

  /// Maximum quantity allowed
  final double? maxQty;

  /// Quantity step size
  final double? stepSize;

  /// Minimum notional value (price * quantity)
  final double? minNotional;

  /// Tick size for price
  final double? tickSize;

  const SymbolInfo({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.status,
    required this.baseAssetPrecision,
    required this.quoteAssetPrecision,
    this.minQty,
    this.maxQty,
    this.stepSize,
    this.minNotional,
    this.tickSize,
  });

  /// Returns true if trading is enabled for this symbol
  bool get isTradable => status == SymbolStatus.trading;

  /// Returns the full display name (e.g., "BTC/USDT")
  String get displayName => '$baseAsset/$quoteAsset';

  /// Creates a copy of this SymbolInfo with the given fields replaced
  SymbolInfo copyWith({
    String? symbol,
    String? baseAsset,
    String? quoteAsset,
    SymbolStatus? status,
    int? baseAssetPrecision,
    int? quoteAssetPrecision,
    double? minQty,
    double? maxQty,
    double? stepSize,
    double? minNotional,
    double? tickSize,
  }) {
    return SymbolInfo(
      symbol: symbol ?? this.symbol,
      baseAsset: baseAsset ?? this.baseAsset,
      quoteAsset: quoteAsset ?? this.quoteAsset,
      status: status ?? this.status,
      baseAssetPrecision: baseAssetPrecision ?? this.baseAssetPrecision,
      quoteAssetPrecision: quoteAssetPrecision ?? this.quoteAssetPrecision,
      minQty: minQty ?? this.minQty,
      maxQty: maxQty ?? this.maxQty,
      stepSize: stepSize ?? this.stepSize,
      minNotional: minNotional ?? this.minNotional,
      tickSize: tickSize ?? this.tickSize,
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        baseAsset,
        quoteAsset,
        status,
        baseAssetPrecision,
        quoteAssetPrecision,
        minQty,
        maxQty,
        stepSize,
        minNotional,
        tickSize,
      ];
}

/// Symbol trading status
enum SymbolStatus {
  /// Symbol is actively trading
  trading,

  /// Symbol is in pre-trading phase
  preTrading,

  /// Symbol is in post-trading phase
  postTrading,

  /// Symbol is in end-of-day phase
  endOfDay,

  /// Trading is halted
  halt,

  /// Trading is on auction
  auctionMatch,

  /// Symbol is in break phase
  breakPhase,
}
