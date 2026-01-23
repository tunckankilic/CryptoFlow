import 'package:dartz/dartz.dart';
import 'package:core/error/failures.dart';
import 'package:core/error/exceptions.dart';
import '../../domain/entities/ticker.dart';
import '../../domain/entities/candle.dart';
import '../../domain/entities/order_book.dart';
import '../../domain/entities/symbol_info.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/market_remote_datasource.dart';
import '../datasources/market_local_datasource.dart';

/// Implementation of MarketRepository
class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDataSource _remoteDataSource;
  final MarketLocalDataSource _localDataSource;

  /// Cache validity duration
  static const _tickersCacheDuration = Duration(minutes: 1);
  static const _candlesCacheDuration = Duration(minutes: 5);

  MarketRepositoryImpl({
    required MarketRemoteDataSource remoteDataSource,
    required MarketLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<Ticker>>> getAllTickers() async {
    try {
      // Try to get from remote
      final tickers = await _remoteDataSource.getAllTickers();

      // Cache the result
      await _localDataSource.cacheTickers(tickers);

      return Right(tickers.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      // Try to get from cache on server error
      final cached = await _localDataSource.getCachedTickers();
      if (cached != null && cached.isNotEmpty) {
        return Right(cached.map((m) => m.toEntity()).toList());
      }
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      // Try to get from cache on network error
      final cached = await _localDataSource.getCachedTickers();
      if (cached != null && cached.isNotEmpty) {
        return Right(cached.map((m) => m.toEntity()).toList());
      }
      return Left(NetworkFailure(message: e.message));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfterSeconds: e.retryAfterSeconds,
      ));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Ticker>> getTicker(String symbol) async {
    try {
      final ticker = await _remoteDataSource.getTicker(symbol);

      // Cache the result
      await _localDataSource.cacheTicker(ticker);

      return Right(ticker.toEntity());
    } on ServerException catch (e) {
      // Try cache on error
      final cached = await _localDataSource.getCachedTicker(symbol);
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      final cached = await _localDataSource.getCachedTicker(symbol);
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return Left(NetworkFailure(message: e.message));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfterSeconds: e.retryAfterSeconds,
      ));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Candle>>> getCandles(
    String symbol,
    String interval, {
    int limit = 500,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final candles = await _remoteDataSource.getCandles(
        symbol,
        interval,
        limit: limit,
        startTime: startTime?.millisecondsSinceEpoch,
        endTime: endTime?.millisecondsSinceEpoch,
      );

      // Cache if no time range specified (standard fetch)
      if (startTime == null && endTime == null) {
        await _localDataSource.cacheCandles(symbol, interval, candles);
      }

      return Right(candles.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      // Try cache on error
      final cached = await _localDataSource.getCachedCandles(symbol, interval);
      if (cached != null && cached.isNotEmpty) {
        return Right(cached.map((m) => m.toEntity()).toList());
      }
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      final cached = await _localDataSource.getCachedCandles(symbol, interval);
      if (cached != null && cached.isNotEmpty) {
        return Right(cached.map((m) => m.toEntity()).toList());
      }
      return Left(NetworkFailure(message: e.message));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfterSeconds: e.retryAfterSeconds,
      ));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderBook>> getOrderBook(
    String symbol, {
    int limit = 20,
  }) async {
    try {
      final orderBook =
          await _remoteDataSource.getOrderBook(symbol, limit: limit);
      return Right(orderBook.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfterSeconds: e.retryAfterSeconds,
      ));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SymbolInfo>>> getExchangeInfo() async {
    try {
      final symbols = await _remoteDataSource.getExchangeInfo();

      return Right(symbols
          .map((s) => SymbolInfo(
                symbol: s.symbol,
                baseAsset: s.baseAsset,
                quoteAsset: s.quoteAsset,
                status: s.isTradable ? SymbolStatus.trading : SymbolStatus.halt,
                baseAssetPrecision: s.baseAssetPrecision,
                quoteAssetPrecision: s.quoteAssetPrecision,
              ))
          .toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfterSeconds: e.retryAfterSeconds,
      ));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Ticker>>> searchSymbols(String query) async {
    try {
      // Get all tickers and filter locally
      final result = await getAllTickers();

      return result.fold(
        (failure) => Left(failure),
        (tickers) {
          final normalizedQuery = query.toUpperCase();
          final filtered = tickers
              .where((t) =>
                  t.symbol.contains(normalizedQuery) ||
                  t.baseAsset.contains(normalizedQuery) ||
                  t.quoteAsset.contains(normalizedQuery))
              .toList();

          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DateTime>> getServerTime() async {
    try {
      final serverTime = await _remoteDataSource.getServerTime();
      return Right(serverTime);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
