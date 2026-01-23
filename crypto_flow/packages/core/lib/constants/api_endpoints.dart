/// Binance API endpoints for REST and WebSocket connections
class BinanceEndpoints {
  BinanceEndpoints._();

  // Base URLs
  static const baseUrl = 'https://api.binance.com';
  static const wsBaseUrl = 'wss://stream.binance.com:9443';

  // REST API Endpoints
  static const ticker24h = '/api/v3/ticker/24hr';
  static const klines = '/api/v3/klines';
  static const exchangeInfo = '/api/v3/exchangeInfo';
  static const depth = '/api/v3/depth';
  static const trades = '/api/v3/trades';
  static const aggTrades = '/api/v3/aggTrades';
  static const avgPrice = '/api/v3/avgPrice';

  // WebSocket Stream Endpoints
  /// Individual ticker stream for a symbol
  /// Example: tickerStream('btcusdt') => '/ws/btcusdt@ticker'
  static String tickerStream(String symbol) =>
      '/ws/${symbol.toLowerCase()}@ticker';

  /// Candlestick/Kline stream for a symbol and interval
  /// Example: klineStream('btcusdt', '1m') => '/ws/btcusdt@kline_1m'
  static String klineStream(String symbol, String interval) =>
      '/ws/${symbol.toLowerCase()}@kline_$interval';

  /// Order book depth stream for a symbol
  /// Example: depthStream('btcusdt', 20) => '/ws/btcusdt@depth20'
  static String depthStream(String symbol, [int levels = 20]) =>
      '/ws/${symbol.toLowerCase()}@depth$levels';

  /// Trade stream for a symbol
  static String tradeStream(String symbol) =>
      '/ws/${symbol.toLowerCase()}@trade';

  /// Aggregate trade stream for a symbol
  static String aggTradeStream(String symbol) =>
      '/ws/${symbol.toLowerCase()}@aggTrade';

  /// Mini ticker stream for a symbol (lightweight ticker)
  static String miniTickerStream(String symbol) =>
      '/ws/${symbol.toLowerCase()}@miniTicker';

  // All Tickers Streams
  /// All market tickers stream (full data)
  static const allTickersStream = '/ws/!ticker@arr';

  /// All market mini tickers stream (lightweight)
  static const allMiniTickersStream = '/ws/!miniTicker@arr';

  // Combined Streams
  /// Combine multiple streams into one connection
  /// Example: combinedStream(['btcusdt@ticker', 'ethusdt@ticker'])
  static String combinedStream(List<String> streams) =>
      '/stream?streams=${streams.join('/')}';

  // Kline/Candlestick Intervals
  static const String interval1m = '1m';
  static const String interval3m = '3m';
  static const String interval5m = '5m';
  static const String interval15m = '15m';
  static const String interval30m = '30m';
  static const String interval1h = '1h';
  static const String interval2h = '2h';
  static const String interval4h = '4h';
  static const String interval6h = '6h';
  static const String interval8h = '8h';
  static const String interval12h = '12h';
  static const String interval1d = '1d';
  static const String interval3d = '3d';
  static const String interval1w = '1w';
  static const String interval1M = '1M';
}
