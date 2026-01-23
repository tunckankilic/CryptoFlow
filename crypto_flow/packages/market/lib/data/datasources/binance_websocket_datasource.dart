import 'dart:async';
import 'package:core/network/websocket_client.dart';
import 'package:core/constants/api_endpoints.dart';
import '../models/ticker_model.dart';
import '../models/candle_model.dart';
import '../models/order_book_model.dart';
import '../models/ws_message_model.dart';

/// Binance WebSocket data source for real-time market data
class BinanceWebSocketDataSource {
  final WebSocketClient _wsClient;
  final Map<String, BinanceWebSocketClient> _clients = {};

  BinanceWebSocketDataSource({required WebSocketClient wsClient})
      : _wsClient = wsClient;

  /// Connect to single ticker stream
  Stream<TickerModel> connectToTicker(String symbol) {
    final clientKey = '${symbol.toLowerCase()}_ticker';
    final client = _getOrCreateClient(clientKey);

    return client
        .connect(BinanceEndpoints.tickerStream(symbol))
        .where((data) => data is Map<String, dynamic>)
        .map((data) => TickerModel.fromWsJson(data as Map<String, dynamic>));
  }

  /// Connect to all tickers stream
  Stream<List<TickerModel>> connectToAllTickers() {
    const clientKey = 'all_tickers';
    final client = _getOrCreateClient(clientKey);

    return client
        .connect(BinanceEndpoints.allTickersStream)
        .where((data) => data is List)
        .map((data) {
      final list = data as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((t) => TickerModel.fromWsJson(t))
          .toList();
    });
  }

  /// Connect to all mini tickers stream (lightweight)
  Stream<List<TickerModel>> connectToAllMiniTickers() {
    const clientKey = 'all_mini_tickers';
    final client = _getOrCreateClient(clientKey);

    return client
        .connect(BinanceEndpoints.allMiniTickersStream)
        .where((data) => data is List)
        .map((data) {
      final list = data as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((t) => TickerModel.fromMiniTicker(t))
          .toList();
    });
  }

  /// Connect to candlestick/kline stream
  Stream<CandleModel> connectToCandles(String symbol, String interval) {
    final clientKey = '${symbol.toLowerCase()}_kline_$interval';
    final client = _getOrCreateClient(clientKey);

    return client
        .connect(BinanceEndpoints.klineStream(symbol, interval))
        .where((data) => data is Map<String, dynamic>)
        .map((data) => CandleModel.fromWsJson(data as Map<String, dynamic>));
  }

  /// Connect to order book depth stream
  Stream<OrderBookModel> connectToOrderBook(String symbol, {int depth = 20}) {
    final clientKey = '${symbol.toLowerCase()}_depth$depth';
    final client = _getOrCreateClient(clientKey);

    return client
        .connect(BinanceEndpoints.depthStream(symbol, depth))
        .where((data) => data is Map<String, dynamic>)
        .map((data) {
      final json = data as Map<String, dynamic>;
      // Add symbol to the response (not included in depth stream)
      json['s'] = symbol.toUpperCase();
      return OrderBookModel.fromWsJson(json);
    });
  }

  /// Connect to trade stream
  Stream<TradeModel> connectToTrade(String symbol) {
    final clientKey = '${symbol.toLowerCase()}_trade';
    final client = _getOrCreateClient(clientKey);

    return client
        .connect(BinanceEndpoints.tradeStream(symbol))
        .where((data) => data is Map<String, dynamic>)
        .map((data) => TradeModel.fromWsJson(data as Map<String, dynamic>));
  }

  /// Connect to multiple tickers using combined stream
  Stream<Map<String, TickerModel>> connectToMultipleTickers(
      List<String> symbols) {
    final clientKey = 'multi_tickers_${symbols.join('_')}';
    final client = _getOrCreateClient(clientKey);

    final streams = symbols.map((s) => '${s.toLowerCase()}@ticker').toList();

    return client
        .connect(BinanceEndpoints.combinedStream(streams))
        .where((data) => data is Map<String, dynamic>)
        .map((data) {
      final json = data as Map<String, dynamic>;
      final tickerData = json['data'] as Map<String, dynamic>;
      final ticker = TickerModel.fromWsJson(tickerData);
      return {ticker.symbol: ticker};
    });
  }

  /// Get or create a client for a specific stream
  BinanceWebSocketClient _getOrCreateClient(String key) {
    if (!_clients.containsKey(key)) {
      _clients[key] = BinanceWebSocketClient();
    }
    return _clients[key]!;
  }

  /// Disconnect a specific stream
  void disconnectStream(String key) {
    _clients[key]?.disconnect();
    _clients.remove(key);
  }

  /// Disconnect all streams
  void disconnectAll() {
    for (final client in _clients.values) {
      client.disconnect();
    }
    _clients.clear();
  }

  /// Get connection status for a stream
  bool isConnected(String key) {
    return _clients[key]?.isConnected ?? false;
  }

  /// Get status stream for a specific connection
  Stream<WebSocketStatus>? getStatusStream(String key) {
    return _clients[key]?.statusStream;
  }

  /// Dispose all resources
  void dispose() {
    for (final client in _clients.values) {
      client.dispose();
    }
    _clients.clear();
  }
}
