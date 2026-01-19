import 'package:core/network/api_client.dart';
import 'package:core/constants/api_endpoints.dart';
import 'package:core/error/exceptions.dart';
import '../models/ticker_model.dart';
import '../models/candle_model.dart';
import '../models/order_book_model.dart';
import '../models/ws_message_model.dart';

/// Remote data source for Binance REST API
abstract class MarketRemoteDataSource {
  /// Fetch all 24hr tickers
  Future<List<TickerModel>> getAllTickers();

  /// Fetch single ticker by symbol
  Future<TickerModel> getTicker(String symbol);

  /// Fetch historical candles/klines
  Future<List<CandleModel>> getCandles(
    String symbol,
    String interval, {
    int limit = 500,
    int? startTime,
    int? endTime,
  });

  /// Fetch order book depth
  Future<OrderBookModel> getOrderBook(String symbol, {int limit = 20});

  /// Fetch exchange info (trading pairs)
  Future<List<SymbolInfoModel>> getExchangeInfo();

  /// Fetch server time for sync
  Future<DateTime> getServerTime();
}

/// Implementation of MarketRemoteDataSource using Binance API
class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  final BinanceApiClient _apiClient;

  MarketRemoteDataSourceImpl({required BinanceApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<TickerModel>> getAllTickers() async {
    try {
      final response = await _apiClient.get(BinanceEndpoints.ticker24h);

      if (response.data is List) {
        final list = response.data as List;
        return list
            .whereType<Map<String, dynamic>>()
            .map((json) => TickerModel.fromJson(json))
            .toList();
      }

      throw ServerException(
        message: 'Invalid response format for tickers',
        code: response.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch tickers: $e');
    }
  }

  @override
  Future<TickerModel> getTicker(String symbol) async {
    try {
      final response = await _apiClient.get(
        BinanceEndpoints.ticker24h,
        queryParameters: {'symbol': symbol.toUpperCase()},
      );

      if (response.data is Map<String, dynamic>) {
        return TickerModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(
        message: 'Invalid response format for ticker',
        code: response.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch ticker for $symbol: $e');
    }
  }

  @override
  Future<List<CandleModel>> getCandles(
    String symbol,
    String interval, {
    int limit = 500,
    int? startTime,
    int? endTime,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'symbol': symbol.toUpperCase(),
        'interval': interval,
        'limit': limit,
      };

      if (startTime != null) {
        queryParams['startTime'] = startTime;
      }
      if (endTime != null) {
        queryParams['endTime'] = endTime;
      }

      final response = await _apiClient.get(
        BinanceEndpoints.klines,
        queryParameters: queryParams,
      );

      if (response.data is List) {
        final list = response.data as List;
        return list
            .whereType<List>()
            .map((json) => CandleModel.fromJson(json))
            .toList();
      }

      throw ServerException(
        message: 'Invalid response format for candles',
        code: response.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch candles for $symbol: $e');
    }
  }

  @override
  Future<OrderBookModel> getOrderBook(String symbol, {int limit = 20}) async {
    try {
      final response = await _apiClient.get(
        BinanceEndpoints.depth,
        queryParameters: {
          'symbol': symbol.toUpperCase(),
          'limit': limit,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return OrderBookModel.fromJson(
          response.data as Map<String, dynamic>,
          symbol: symbol.toUpperCase(),
        );
      }

      throw ServerException(
        message: 'Invalid response format for order book',
        code: response.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Failed to fetch order book for $symbol: $e');
    }
  }

  @override
  Future<List<SymbolInfoModel>> getExchangeInfo() async {
    try {
      final response = await _apiClient.get(BinanceEndpoints.exchangeInfo);

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final symbols = data['symbols'] as List?;

        if (symbols != null) {
          return symbols
              .whereType<Map<String, dynamic>>()
              .map((json) => SymbolInfoModel.fromJson(json))
              .toList();
        }
      }

      throw ServerException(
        message: 'Invalid response format for exchange info',
        code: response.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch exchange info: $e');
    }
  }

  @override
  Future<DateTime> getServerTime() async {
    try {
      final response = await _apiClient.get('/api/v3/time');

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final serverTime = data['serverTime'] as int?;

        if (serverTime != null) {
          return DateTime.fromMillisecondsSinceEpoch(serverTime);
        }
      }

      throw ServerException(
        message: 'Invalid response format for server time',
        code: response.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch server time: $e');
    }
  }
}
