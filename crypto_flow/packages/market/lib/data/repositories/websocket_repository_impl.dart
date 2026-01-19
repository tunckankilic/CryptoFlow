import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:core/error/failures.dart';
import 'package:core/network/websocket_client.dart';
import '../../domain/entities/ticker.dart';
import '../../domain/entities/candle.dart';
import '../../domain/entities/order_book.dart';
import '../../domain/entities/trade.dart';
import '../../domain/repositories/websocket_repository.dart';
import '../datasources/binance_websocket_datasource.dart';

/// Implementation of WebSocketRepository using Binance WebSocket
class WebSocketRepositoryImpl implements WebSocketRepository {
  final BinanceWebSocketDataSource _wsDataSource;
  final Map<String, StreamSubscription> _subscriptions = {};
  bool _isConnected = false;

  WebSocketRepositoryImpl({required BinanceWebSocketDataSource wsDataSource})
      : _wsDataSource = wsDataSource;

  @override
  Stream<Either<Failure, Ticker>> getTickerStream(String symbol) {
    return _wsDataSource
        .connectToTicker(symbol)
        .map<Either<Failure, Ticker>>((model) => Right(model.toEntity()))
        .handleError((error) => Left(_mapError(error)));
  }

  @override
  Stream<Either<Failure, Candle>> getCandleStream(
    String symbol,
    String interval,
  ) {
    return _wsDataSource
        .connectToCandles(symbol, interval)
        .map<Either<Failure, Candle>>((model) => Right(model.toEntity()))
        .handleError((error) => Left(_mapError(error)));
  }

  @override
  Stream<Either<Failure, OrderBook>> getOrderBookStream(
    String symbol, {
    int depth = 20,
  }) {
    return _wsDataSource
        .connectToOrderBook(symbol, depth: depth)
        .map<Either<Failure, OrderBook>>((model) => Right(model.toEntity()))
        .handleError((error) => Left(_mapError(error)));
  }

  @override
  Stream<Either<Failure, Trade>> getTradeStream(String symbol) {
    return _wsDataSource
        .connectToTrade(symbol)
        .map<Either<Failure, Trade>>((model) => Right(model.toEntity()))
        .handleError((error) => Left(_mapError(error)));
  }

  @override
  Stream<Either<Failure, List<Ticker>>> getAllTickersStream() {
    return _wsDataSource
        .connectToAllTickers()
        .map<Either<Failure, List<Ticker>>>(
          (models) => Right(models.map((m) => m.toEntity()).toList()),
        )
        .handleError((error) => Left(_mapError(error)));
  }

  @override
  Stream<Either<Failure, List<Ticker>>> getMultipleTickersStream(
    List<String> symbols,
  ) {
    // Accumulate updates into a map
    final tickerMap = <String, Ticker>{};

    return _wsDataSource
        .connectToMultipleTickers(symbols)
        .map<Either<Failure, List<Ticker>>>((updates) {
      for (final entry in updates.entries) {
        tickerMap[entry.key] = entry.value.toEntity();
      }
      return Right(tickerMap.values.toList());
    }).handleError((error) => Left(_mapError(error)));
  }

  @override
  Stream<Either<Failure, List<Ticker>>> getAllMiniTickersStream() {
    return _wsDataSource
        .connectToAllMiniTickers()
        .map<Either<Failure, List<Ticker>>>(
          (models) => Right(models.map((m) => m.toEntity()).toList()),
        )
        .handleError((error) => Left(_mapError(error)));
  }

  @override
  void connect() {
    _isConnected = true;
  }

  @override
  void disconnect() {
    _isConnected = false;
    _wsDataSource.disconnectAll();
    _cancelAllSubscriptions();
  }

  @override
  void disconnectStream(String streamId) {
    _wsDataSource.disconnectStream(streamId);
    _subscriptions[streamId]?.cancel();
    _subscriptions.remove(streamId);
  }

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<WebSocketStatus> get statusStream {
    // Return status from main ticker stream as a proxy
    return _wsDataSource.getStatusStream('all_tickers') ??
        Stream.value(WebSocketStatus.disconnected);
  }

  @override
  Future<void> reconnect() async {
    disconnect();
    await Future.delayed(const Duration(seconds: 1));
    connect();
  }

  /// Cancel all subscriptions
  void _cancelAllSubscriptions() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  /// Map error to Failure
  Failure _mapError(dynamic error) {
    if (error is Failure) return error;

    final errorMsg = error?.toString() ?? 'Unknown WebSocket error';

    if (errorMsg.contains('connection') || errorMsg.contains('socket')) {
      return WebSocketFailure(
        type: WebSocketFailureType.connectionLost,
        message: errorMsg,
      );
    }

    if (errorMsg.contains('parse') || errorMsg.contains('format')) {
      return WebSocketFailure(
        type: WebSocketFailureType.parseError,
        message: errorMsg,
      );
    }

    return WebSocketFailure(
      type: WebSocketFailureType.unknown,
      message: errorMsg,
    );
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _wsDataSource.dispose();
  }
}
