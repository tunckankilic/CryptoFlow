/// Local storage keys for Hive and Drift databases
class StorageKeys {
  StorageKeys._();

  // Hive Box Names
  static const String settingsBox = 'settings';
  static const String watchlistBox = 'watchlist';
  static const String alertsBox = 'alerts';
  static const String cacheBox = 'cache';

  // Settings Keys
  static const String themeMode = 'theme_mode';
  static const String isDarkMode = 'is_dark_mode';
  static const String isAmoledMode = 'is_amoled_mode';
  static const String baseCurrency = 'base_currency';
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String soundEnabled = 'sound_enabled';
  static const String defaultInterval = 'default_interval';

  // User Preferences
  static const String showVolume = 'show_volume';
  static const String showMA = 'show_ma';
  static const String chartType = 'chart_type';
  static const String orderBookDepth = 'order_book_depth';

  // Cache Keys
  static const String marketDataPrefix = 'market_data_';
  static const String tickerPrefix = 'ticker_';
  static const String candlePrefix = 'candle_';
  static const String exchangeInfo = 'exchange_info';
  static const String symbolsListPrefix = 'symbols_list';

  // Portfolio Keys (Drift database tables will use these)
  static const String holdingsTable = 'holdings';
  static const String transactionsTable = 'transactions';
  static const String portfolioSummaryTable = 'portfolio_summary';

  /// Build a cache key for ticker data
  static String tickerCacheKey(String symbol) => '$tickerPrefix$symbol';

  /// Build a cache key for candle data
  static String candleCacheKey(String symbol, String interval) =>
      '$candlePrefix${symbol}_$interval';

  /// Build a cache key for market data
  static String marketDataCacheKey(String key) => '$marketDataPrefix$key';
}
