import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents a cryptocurrency ticker with 24h statistics
@immutable
class Ticker extends Equatable {
  /// Trading pair symbol (e.g., "BTCUSDT")
  final String symbol;

  /// Base asset (e.g., "BTC")
  final String baseAsset;

  /// Quote asset (e.g., "USDT")
  final String quoteAsset;

  /// Current price
  final double price;

  /// Absolute price change in 24h
  final double priceChange;

  /// Percentage price change in 24h
  final double priceChangePercent;

  /// Highest price in 24h
  final double high24h;

  /// Lowest price in 24h
  final double low24h;

  /// Trading volume in base asset
  final double volume;

  /// Trading volume in quote asset
  final double quoteVolume;

  /// Number of trades in 24h
  final int trades;

  /// Last update timestamp
  final DateTime? lastUpdate;

  const Ticker({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.price,
    required this.priceChange,
    required this.priceChangePercent,
    required this.high24h,
    required this.low24h,
    required this.volume,
    required this.quoteVolume,
    required this.trades,
    this.lastUpdate,
  });

  /// Returns true if price change is positive or zero
  bool get isUp => priceChangePercent >= 0;

  /// Returns true if price change is negative
  bool get isDown => priceChangePercent < 0;

  /// Returns the 24h price range
  double get priceRange => high24h - low24h;

  /// Returns the average price over 24h (simple approximation)
  double get avgPrice => (high24h + low24h) / 2;

  /// Creates a copy of this Ticker with the given fields replaced
  Ticker copyWith({
    String? symbol,
    String? baseAsset,
    String? quoteAsset,
    double? price,
    double? priceChange,
    double? priceChangePercent,
    double? high24h,
    double? low24h,
    double? volume,
    double? quoteVolume,
    int? trades,
    DateTime? lastUpdate,
  }) {
    return Ticker(
      symbol: symbol ?? this.symbol,
      baseAsset: baseAsset ?? this.baseAsset,
      quoteAsset: quoteAsset ?? this.quoteAsset,
      price: price ?? this.price,
      priceChange: priceChange ?? this.priceChange,
      priceChangePercent: priceChangePercent ?? this.priceChangePercent,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      volume: volume ?? this.volume,
      quoteVolume: quoteVolume ?? this.quoteVolume,
      trades: trades ?? this.trades,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        baseAsset,
        quoteAsset,
        price,
        priceChange,
        priceChangePercent,
        high24h,
        low24h,
        volume,
        quoteVolume,
        trades,
        lastUpdate,
      ];
}
