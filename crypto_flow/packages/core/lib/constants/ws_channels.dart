/// WebSocket channel identifiers and helpers
class WsChannels {
  WsChannels._();

  // Channel Types
  static const String ticker = 'ticker';
  static const String miniTicker = 'miniTicker';
  static const String kline = 'kline';
  static const String depth = 'depth';
  static const String trade = 'trade';
  static const String aggTrade = 'aggTrade';

  /// Build a channel identifier for a symbol and type
  /// Example: buildChannel('btcusdt', 'ticker') => 'btcusdt@ticker'
  static String buildChannel(String symbol, String channelType) =>
      '${symbol.toLowerCase()}@$channelType';

  /// Build a kline channel with interval
  /// Example: buildKlineChannel('btcusdt', '1m') => 'btcusdt@kline_1m'
  static String buildKlineChannel(String symbol, String interval) =>
      '${symbol.toLowerCase()}@kline_$interval';

  /// Build a depth channel with levels
  /// Example: buildDepthChannel('btcusdt', 20) => 'btcusdt@depth20'
  static String buildDepthChannel(String symbol, [int levels = 20]) =>
      '${symbol.toLowerCase()}@depth$levels';

  /// Parse channel identifier to extract symbol and type
  /// Example: parseChannel('btcusdt@ticker') => {'symbol': 'btcusdt', 'type': 'ticker'}
  static Map<String, String> parseChannel(String channel) {
    final parts = channel.split('@');
    if (parts.length != 2) {
      return {'symbol': '', 'type': ''};
    }
    return {
      'symbol': parts[0],
      'type': parts[1].split('_')[0], // Remove interval if present
    };
  }

  /// Extract symbol from channel identifier
  /// Example: getSymbol('btcusdt@ticker') => 'btcusdt'
  static String getSymbol(String channel) {
    return channel.split('@')[0];
  }

  /// Extract channel type from channel identifier
  /// Example: getType('btcusdt@ticker') => 'ticker'
  static String getType(String channel) {
    final parts = channel.split('@');
    if (parts.length < 2) return '';
    return parts[1].split('_')[0];
  }
}
