import '../../domain/entities/candle.dart';

/// Data model for Candle with JSON parsing capabilities
class CandleModel extends Candle {
  const CandleModel({
    required super.openTime,
    required super.closeTime,
    required super.open,
    required super.high,
    required super.low,
    required super.close,
    required super.volume,
    required super.trades,
  });

  /// Create from REST API klines response
  /// Binance kline format: [openTime, open, high, low, close, volume, closeTime, ...]
  /// [
  ///   1499040000000,      // 0: Open time
  ///   "0.01634000",       // 1: Open
  ///   "0.80000000",       // 2: High
  ///   "0.01575800",       // 3: Low
  ///   "0.01577100",       // 4: Close
  ///   "148976.11427815",  // 5: Volume
  ///   1499644799999,      // 6: Close time
  ///   "2434.19055334",    // 7: Quote asset volume
  ///   308,                // 8: Number of trades
  ///   "1756.87402397",    // 9: Taker buy base asset volume
  ///   "28.46694368",      // 10: Taker buy quote asset volume
  ///   "17928899.62484339" // 11: Ignore
  /// ]
  factory CandleModel.fromJson(List<dynamic> json) {
    return CandleModel(
      openTime: DateTime.fromMillisecondsSinceEpoch(json[0] as int),
      open: _parseDouble(json[1]),
      high: _parseDouble(json[2]),
      low: _parseDouble(json[3]),
      close: _parseDouble(json[4]),
      volume: _parseDouble(json[5]),
      closeTime: DateTime.fromMillisecondsSinceEpoch(json[6] as int),
      trades: json[8] as int? ?? 0,
    );
  }

  /// Create from WebSocket kline stream
  /// Example JSON:
  /// {
  ///   "e": "kline",
  ///   "s": "BTCUSDT",
  ///   "k": {
  ///     "t": 1499040000000,  // Kline start time
  ///     "T": 1499644799999,  // Kline close time
  ///     "s": "BTCUSDT",      // Symbol
  ///     "i": "1m",           // Interval
  ///     "o": "0.01634000",   // Open price
  ///     "c": "0.01577100",   // Close price
  ///     "h": "0.80000000",   // High price
  ///     "l": "0.01575800",   // Low price
  ///     "v": "148976.11427815", // Base asset volume
  ///     "n": 308,            // Number of trades
  ///     "x": false           // Is this kline closed?
  ///   }
  /// }
  factory CandleModel.fromWsJson(Map<String, dynamic> json) {
    final k = json['k'] as Map<String, dynamic>;
    return CandleModel(
      openTime: DateTime.fromMillisecondsSinceEpoch(k['t'] as int),
      closeTime: DateTime.fromMillisecondsSinceEpoch(k['T'] as int),
      open: _parseDouble(k['o']),
      high: _parseDouble(k['h']),
      low: _parseDouble(k['l']),
      close: _parseDouble(k['c']),
      volume: _parseDouble(k['v']),
      trades: k['n'] as int? ?? 0,
    );
  }

  /// Check if kline is closed from WebSocket message
  static bool isKlineClosed(Map<String, dynamic> json) {
    final k = json['k'] as Map<String, dynamic>?;
    return k?['x'] as bool? ?? false;
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'openTime': openTime.millisecondsSinceEpoch,
      'closeTime': closeTime.millisecondsSinceEpoch,
      'open': open.toString(),
      'high': high.toString(),
      'low': low.toString(),
      'close': close.toString(),
      'volume': volume.toString(),
      'trades': trades,
    };
  }

  /// Create from cached JSON
  factory CandleModel.fromCacheJson(Map<String, dynamic> json) {
    return CandleModel(
      openTime: DateTime.fromMillisecondsSinceEpoch(json['openTime'] as int),
      closeTime: DateTime.fromMillisecondsSinceEpoch(json['closeTime'] as int),
      open: _parseDouble(json['open']),
      high: _parseDouble(json['high']),
      low: _parseDouble(json['low']),
      close: _parseDouble(json['close']),
      volume: _parseDouble(json['volume']),
      trades: json['trades'] as int? ?? 0,
    );
  }

  /// Convert model to entity
  Candle toEntity() => Candle(
        openTime: openTime,
        closeTime: closeTime,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
        trades: trades,
      );

  // Helper to safely parse double from String or num
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
