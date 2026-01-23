import 'package:dartz/dartz.dart';
import 'package:core/error/failures.dart';
import 'package:core/network/websocket_client.dart';
import '../entities/ticker.dart';
import '../entities/candle.dart';
import '../entities/order_book.dart';
import '../entities/trade.dart';

/// Repository interface for real-time WebSocket data streams
abstract class WebSocketRepository {
  // ==================== Single Symbol Streams ====================

  /// Subscribes to real-time ticker updates for a single symbol
  Stream<Either<Failure, Ticker>> getTickerStream(String symbol);

  /// Subscribes to real-time candlestick updates
  ///
  /// [symbol] - Trading pair (e.g., "BTCUSDT")
  /// [interval] - Candlestick interval (e.g., "1m", "5m", "1h")
  Stream<Either<Failure, Candle>> getCandleStream(
    String symbol,
    String interval,
  );

  /// Subscribes to real-time order book updates
  ///
  /// [symbol] - Trading pair
  /// [depth] - Number of levels (5, 10, or 20)
  Stream<Either<Failure, OrderBook>> getOrderBookStream(
    String symbol, {
    int depth = 20,
  });

  /// Subscribes to real-time trade updates
  Stream<Either<Failure, Trade>> getTradeStream(String symbol);

  // ==================== Bulk Streams ====================

  /// Subscribes to ticker updates for all symbols
  Stream<Either<Failure, List<Ticker>>> getAllTickersStream();

  /// Subscribes to ticker updates for multiple specific symbols
  Stream<Either<Failure, List<Ticker>>> getMultipleTickersStream(
    List<String> symbols,
  );

  /// Subscribes to mini ticker updates for all symbols (lighter payload)
  Stream<Either<Failure, List<Ticker>>> getAllMiniTickersStream();

  // ==================== Connection Management ====================

  /// Initiates WebSocket connection
  void connect();

  /// Disconnects all WebSocket connections
  void disconnect();

  /// Disconnects a specific stream
  void disconnectStream(String streamId);

  /// Returns the current connection status
  bool get isConnected;

  /// Stream of connection status changes
  Stream<WebSocketStatus> get statusStream;

  /// Reconnects with exponential backoff
  Future<void> reconnect();
}
