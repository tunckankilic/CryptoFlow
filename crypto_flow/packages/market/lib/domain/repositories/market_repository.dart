import 'package:dartz/dartz.dart';
import 'package:core/error/failures.dart';
import '../entities/ticker.dart';
import '../entities/candle.dart';
import '../entities/order_book.dart';
import '../entities/symbol_info.dart';

/// Repository interface for market data operations (REST API)
abstract class MarketRepository {
  /// Fetches all available tickers with 24h statistics
  Future<Either<Failure, List<Ticker>>> getAllTickers();

  /// Fetches a single ticker by symbol
  Future<Either<Failure, Ticker>> getTicker(String symbol);

  /// Fetches historical candlestick data
  ///
  /// [symbol] - Trading pair (e.g., "BTCUSDT")
  /// [interval] - Candlestick interval (e.g., "1m", "1h", "1d")
  /// [limit] - Number of candles to fetch (default: 500, max: 1500)
  /// [startTime] - Optional start time
  /// [endTime] - Optional end time
  Future<Either<Failure, List<Candle>>> getCandles(
    String symbol,
    String interval, {
    int limit = 500,
    DateTime? startTime,
    DateTime? endTime,
  });

  /// Fetches the order book for a symbol
  ///
  /// [symbol] - Trading pair
  /// [limit] - Depth limit (5, 10, 20, 50, 100, 500, 1000, 5000)
  Future<Either<Failure, OrderBook>> getOrderBook(
    String symbol, {
    int limit = 20,
  });

  /// Fetches exchange information (all trading pairs and rules)
  Future<Either<Failure, List<SymbolInfo>>> getExchangeInfo();

  /// Searches for symbols matching the query
  Future<Either<Failure, List<Ticker>>> searchSymbols(String query);

  /// Fetches server time (for time sync)
  Future<Either<Failure, DateTime>> getServerTime();
}
