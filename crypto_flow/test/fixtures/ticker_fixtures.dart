import 'package:market/domain/entities/ticker.dart';

/// Test fixtures for ticker-related tests
class TickerFixtures {
  TickerFixtures._();

  // ==================== REST API Response ====================

  /// Binance REST API 24hr ticker response format
  static const Map<String, dynamic> restApiTickerJson = {
    'symbol': 'BTCUSDT',
    'priceChange': '1000.00000000',
    'priceChangePercent': '1.500',
    'weightedAvgPrice': '69500.00000000',
    'prevClosePrice': '68000.00000000',
    'lastPrice': '69000.00000000',
    'lastQty': '0.10000000',
    'bidPrice': '68999.00000000',
    'bidQty': '1.00000000',
    'askPrice': '69001.00000000',
    'askQty': '1.00000000',
    'openPrice': '68000.00000000',
    'highPrice': '70000.00000000',
    'lowPrice': '67500.00000000',
    'volume': '15000.00000000',
    'quoteVolume': '1035000000.00000000',
    'openTime': 1704067200000,
    'closeTime': 1704153599999,
    'firstId': 1000000,
    'lastId': 1100000,
    'count': 100000,
  };

  // ==================== WebSocket Response ====================

  /// Binance WebSocket 24hr ticker stream format
  static const Map<String, dynamic> wsTickerJson = {
    'e': '24hrTicker',
    'E': 1704153600000,
    's': 'BTCUSDT',
    'p': '1000.00000000',
    'P': '1.500',
    'w': '69500.00000000',
    'x': '68000.00000000',
    'c': '69000.00000000',
    'Q': '0.10000000',
    'b': '68999.00000000',
    'B': '1.00000000',
    'a': '69001.00000000',
    'A': '1.00000000',
    'o': '68000.00000000',
    'h': '70000.00000000',
    'l': '67500.00000000',
    'v': '15000.00000000',
    'q': '1035000000.00000000',
    'O': 1704067200000,
    'C': 1704153599999,
    'F': 1000000,
    'L': 1100000,
    'n': 100000,
  };

  /// Binance WebSocket mini ticker stream format
  static const Map<String, dynamic> miniTickerJson = {
    'e': '24hrMiniTicker',
    'E': 1704153600000,
    's': 'ETHUSDT',
    'c': '2500.00000000',
    'o': '2400.00000000',
    'h': '2550.00000000',
    'l': '2350.00000000',
    'v': '50000.00000000',
    'q': '125000000.00000000',
  };

  // ==================== Cached Data ====================

  /// Cached ticker JSON format (includes base/quote asset)
  static const Map<String, dynamic> cachedTickerJson = {
    'symbol': 'BTCUSDT',
    'baseAsset': 'BTC',
    'quoteAsset': 'USDT',
    'lastPrice': '69000.00',
    'priceChange': '1000.00',
    'priceChangePercent': '1.50',
    'highPrice': '70000.00',
    'lowPrice': '67500.00',
    'volume': '15000.00',
    'quoteVolume': '1035000000.00',
    'count': 100000,
    'lastUpdate': 1704153600000,
  };

  // ==================== Entity Fixtures ====================

  /// Sample Ticker entity for testing
  static const Ticker mockTicker = Ticker(
    symbol: 'BTCUSDT',
    baseAsset: 'BTC',
    quoteAsset: 'USDT',
    price: 69000.0,
    priceChange: 1000.0,
    priceChangePercent: 1.5,
    high24h: 70000.0,
    low24h: 67500.0,
    volume: 15000.0,
    quoteVolume: 1035000000.0,
    trades: 100000,
  );

  /// Sample ETH ticker for list testing
  static const Ticker mockEthTicker = Ticker(
    symbol: 'ETHUSDT',
    baseAsset: 'ETH',
    quoteAsset: 'USDT',
    price: 2500.0,
    priceChange: 100.0,
    priceChangePercent: 4.17,
    high24h: 2550.0,
    low24h: 2350.0,
    volume: 50000.0,
    quoteVolume: 125000000.0,
    trades: 50000,
  );

  /// Sample BTC pair ticker (different quote)
  static const Ticker mockBtcPairTicker = Ticker(
    symbol: 'ETHBTC',
    baseAsset: 'ETH',
    quoteAsset: 'BTC',
    price: 0.0362,
    priceChange: 0.0002,
    priceChangePercent: 0.56,
    high24h: 0.0365,
    low24h: 0.0358,
    volume: 10000.0,
    quoteVolume: 362.0,
    trades: 10000,
  );

  /// Negative change ticker for color testing
  static const Ticker mockNegativeTicker = Ticker(
    symbol: 'SOLSUST',
    baseAsset: 'SOL',
    quoteAsset: 'USDT',
    price: 95.0,
    priceChange: -5.0,
    priceChangePercent: -5.0,
    high24h: 105.0,
    low24h: 90.0,
    volume: 100000.0,
    quoteVolume: 9500000.0,
    trades: 20000,
  );

  /// List of mock tickers for list testing
  static const List<Ticker> mockTickerList = [
    mockTicker,
    mockEthTicker,
    mockBtcPairTicker,
    mockNegativeTicker,
  ];

  // ==================== Edge Cases ====================

  /// JSON with null values
  static const Map<String, dynamic> nullValuesJson = {
    'symbol': 'BTCUSDT',
    'lastPrice': null,
    'priceChange': null,
    'priceChangePercent': null,
    'highPrice': null,
    'lowPrice': null,
    'volume': null,
    'quoteVolume': null,
    'count': null,
  };

  /// JSON with string numbers (common in Binance API)
  static const Map<String, dynamic> stringNumbersJson = {
    'symbol': 'BTCUSDT',
    'lastPrice': '69000.12345678',
    'priceChange': '-500.50',
    'priceChangePercent': '-0.72',
    'highPrice': '70000',
    'lowPrice': '68000',
    'volume': '15000.5',
    'quoteVolume': '1035000000',
    'count': 100000,
  };
}
