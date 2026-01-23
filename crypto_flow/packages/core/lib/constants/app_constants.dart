/// Application-wide constants
class AppConstants {
  AppConstants._();

  // API Configuration
  /// Binance API rate limit: 1200 requests per minute
  static const int rateLimitPerMinute = 1200;

  /// Request timeout for REST API calls (in seconds)
  static const int requestTimeoutSeconds = 30;

  /// Connection timeout (in seconds)
  static const int connectionTimeoutSeconds = 10;

  // WebSocket Configuration
  /// WebSocket ping interval to keep connection alive (in minutes)
  static const int wsPingIntervalMinutes = 3;

  /// WebSocket reconnection delay base (in seconds)
  static const int wsReconnectDelayBase = 1;

  /// Maximum WebSocket reconnection delay (in seconds)
  static const int wsReconnectDelayMax = 30;

  /// Maximum number of reconnection attempts
  static const int wsMaxReconnectAttempts = 10;

  // Cache Configuration
  /// Cache duration for market data (in minutes)
  static const int marketDataCacheDuration = 1;

  /// Cache duration for exchange info (in hours)
  static const int exchangeInfoCacheDuration = 24;

  /// Cache duration for historical data (in hours)
  static const int historicalDataCacheDuration = 6;

  // UI Configuration
  /// Default number of decimal places for price display
  static const int defaultPriceDecimals = 2;

  /// Number of items to show in order book
  static const int orderBookDepth = 20;

  /// Default page size for pagination
  static const int defaultPageSize = 20;

  /// Debounce duration for search (in milliseconds)
  static const int searchDebounceDuration = 500;

  // Data Limits
  /// Maximum number of candles to fetch at once
  static const int maxCandlesPerRequest = 1000;

  /// Maximum number of symbols in watchlist
  static const int maxWatchlistSize = 50;

  /// Maximum number of active alerts
  static const int maxActiveAlerts = 100;

  // App Info
  static const String appName = 'CryptoFlow';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@cryptoflow.app';
}
