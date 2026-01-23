import '../../domain/entities/ticker.dart';

/// Data model for Ticker with JSON parsing capabilities
class TickerModel extends Ticker {
  const TickerModel({
    required super.symbol,
    required super.baseAsset,
    required super.quoteAsset,
    required super.price,
    required super.priceChange,
    required super.priceChangePercent,
    required super.high24h,
    required super.low24h,
    required super.volume,
    required super.quoteVolume,
    required super.trades,
    super.lastUpdate,
  });

  /// Create from REST API 24hr ticker response
  /// Example JSON:
  /// {
  ///   "symbol": "BTCUSDT",
  ///   "priceChange": "-94.99999800",
  ///   "priceChangePercent": "-0.134",
  ///   "lastPrice": "69000.00000000",
  ///   "highPrice": "70000.00000000",
  ///   "lowPrice": "68000.00000000",
  ///   "volume": "100000.00000000",
  ///   "quoteVolume": "6900000000.00000000",
  ///   "count": 500000
  /// }
  factory TickerModel.fromJson(Map<String, dynamic> json) {
    final symbol = json['symbol'] as String;
    return TickerModel(
      symbol: symbol,
      baseAsset: _extractBaseAsset(symbol),
      quoteAsset: _extractQuoteAsset(symbol),
      price: _parseDouble(json['lastPrice']),
      priceChange: _parseDouble(json['priceChange']),
      priceChangePercent: _parseDouble(json['priceChangePercent']),
      high24h: _parseDouble(json['highPrice']),
      low24h: _parseDouble(json['lowPrice']),
      volume: _parseDouble(json['volume']),
      quoteVolume: _parseDouble(json['quoteVolume']),
      trades: json['count'] as int? ?? 0,
      lastUpdate: DateTime.now(),
    );
  }

  /// Create from WebSocket 24hr ticker stream
  /// Example JSON:
  /// {
  ///   "e": "24hrTicker",
  ///   "s": "BTCUSDT",
  ///   "p": "-94.99999800",
  ///   "P": "-0.134",
  ///   "c": "69000.00000000",
  ///   "h": "70000.00000000",
  ///   "l": "68000.00000000",
  ///   "v": "100000.00000000",
  ///   "q": "6900000000.00000000",
  ///   "n": 500000
  /// }
  factory TickerModel.fromWsJson(Map<String, dynamic> json) {
    final symbol = json['s'] as String;
    return TickerModel(
      symbol: symbol,
      baseAsset: _extractBaseAsset(symbol),
      quoteAsset: _extractQuoteAsset(symbol),
      price: _parseDouble(json['c']),
      priceChange: _parseDouble(json['p']),
      priceChangePercent: _parseDouble(json['P']),
      high24h: _parseDouble(json['h']),
      low24h: _parseDouble(json['l']),
      volume: _parseDouble(json['v']),
      quoteVolume: _parseDouble(json['q']),
      trades: json['n'] as int? ?? 0,
      lastUpdate: json['E'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['E'] as int)
          : DateTime.now(),
    );
  }

  /// Create from WebSocket mini ticker stream (lightweight)
  /// Example JSON:
  /// {
  ///   "e": "24hrMiniTicker",
  ///   "s": "BTCUSDT",
  ///   "c": "69000.00000000",
  ///   "o": "69100.00000000",
  ///   "h": "70000.00000000",
  ///   "l": "68000.00000000",
  ///   "v": "100000.00000000",
  ///   "q": "6900000000.00000000"
  /// }
  factory TickerModel.fromMiniTicker(Map<String, dynamic> json) {
    final symbol = json['s'] as String;
    final closePrice = _parseDouble(json['c']);
    final openPrice = _parseDouble(json['o']);
    final priceChange = closePrice - openPrice;
    final priceChangePercent =
        openPrice != 0 ? (priceChange / openPrice) * 100 : 0.0;

    return TickerModel(
      symbol: symbol,
      baseAsset: _extractBaseAsset(symbol),
      quoteAsset: _extractQuoteAsset(symbol),
      price: closePrice,
      priceChange: priceChange,
      priceChangePercent: priceChangePercent,
      high24h: _parseDouble(json['h']),
      low24h: _parseDouble(json['l']),
      volume: _parseDouble(json['v']),
      quoteVolume: _parseDouble(json['q']),
      trades: 0, // Not available in mini ticker
      lastUpdate: json['E'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['E'] as int)
          : DateTime.now(),
    );
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'baseAsset': baseAsset,
      'quoteAsset': quoteAsset,
      'lastPrice': price.toString(),
      'priceChange': priceChange.toString(),
      'priceChangePercent': priceChangePercent.toString(),
      'highPrice': high24h.toString(),
      'lowPrice': low24h.toString(),
      'volume': volume.toString(),
      'quoteVolume': quoteVolume.toString(),
      'count': trades,
      'lastUpdate': lastUpdate?.millisecondsSinceEpoch,
    };
  }

  /// Create from cached JSON (includes base/quote asset)
  factory TickerModel.fromCacheJson(Map<String, dynamic> json) {
    return TickerModel(
      symbol: json['symbol'] as String,
      baseAsset: json['baseAsset'] as String,
      quoteAsset: json['quoteAsset'] as String,
      price: _parseDouble(json['lastPrice']),
      priceChange: _parseDouble(json['priceChange']),
      priceChangePercent: _parseDouble(json['priceChangePercent']),
      high24h: _parseDouble(json['highPrice']),
      low24h: _parseDouble(json['lowPrice']),
      volume: _parseDouble(json['volume']),
      quoteVolume: _parseDouble(json['quoteVolume']),
      trades: json['count'] as int? ?? 0,
      lastUpdate: json['lastUpdate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastUpdate'] as int)
          : null,
    );
  }

  /// Convert model to entity
  Ticker toEntity() => Ticker(
        symbol: symbol,
        baseAsset: baseAsset,
        quoteAsset: quoteAsset,
        price: price,
        priceChange: priceChange,
        priceChangePercent: priceChangePercent,
        high24h: high24h,
        low24h: low24h,
        volume: volume,
        quoteVolume: quoteVolume,
        trades: trades,
        lastUpdate: lastUpdate,
      );

  // Helper to safely parse double from String or num
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Common quote assets for extraction
  static const _quoteAssets = [
    'USDT',
    'BUSD',
    'USDC',
    'BTC',
    'ETH',
    'BNB',
    'EUR',
    'GBP',
    'TRY',
    'TUSD',
    'DAI',
    'FDUSD',
  ];

  // Extract base asset from symbol
  static String _extractBaseAsset(String symbol) {
    for (final quote in _quoteAssets) {
      if (symbol.endsWith(quote)) {
        return symbol.substring(0, symbol.length - quote.length);
      }
    }
    // Default: take first 3-4 characters
    return symbol.length > 4 ? symbol.substring(0, symbol.length - 4) : symbol;
  }

  // Extract quote asset from symbol
  static String _extractQuoteAsset(String symbol) {
    for (final quote in _quoteAssets) {
      if (symbol.endsWith(quote)) {
        return quote;
      }
    }
    // Default: take last 4 characters
    return symbol.length > 4 ? symbol.substring(symbol.length - 4) : '';
  }
}
