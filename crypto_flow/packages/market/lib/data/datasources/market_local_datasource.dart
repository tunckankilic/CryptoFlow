import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/ticker_model.dart';
import '../models/candle_model.dart';

/// Local data source for caching market data
abstract class MarketLocalDataSource {
  /// Cache tickers
  Future<void> cacheTickers(List<TickerModel> tickers);

  /// Get cached tickers
  Future<List<TickerModel>?> getCachedTickers();

  /// Cache single ticker
  Future<void> cacheTicker(TickerModel ticker);

  /// Get cached ticker by symbol
  Future<TickerModel?> getCachedTicker(String symbol);

  /// Cache candles for a symbol and interval
  Future<void> cacheCandles(
    String symbol,
    String interval,
    List<CandleModel> candles,
  );

  /// Get cached candles
  Future<List<CandleModel>?> getCachedCandles(String symbol, String interval);

  /// Clear all cache
  Future<void> clearCache();

  /// Get last cache update time
  Future<DateTime?> getLastUpdateTime(String key);
}

/// Implementation using Hive for local caching
class MarketLocalDataSourceImpl implements MarketLocalDataSource {
  static const String _tickersBoxName = 'tickers';
  static const String _candlesBoxName = 'candles';
  static const String _metadataBoxName = 'market_metadata';

  Box<String>? _tickersBox;
  Box<String>? _candlesBox;
  Box<int>? _metadataBox;

  /// Initialize Hive boxes
  Future<void> init() async {
    _tickersBox = await Hive.openBox<String>(_tickersBoxName);
    _candlesBox = await Hive.openBox<String>(_candlesBoxName);
    _metadataBox = await Hive.openBox<int>(_metadataBoxName);
  }

  /// Ensure boxes are initialized
  Future<void> _ensureInitialized() async {
    if (_tickersBox == null || !_tickersBox!.isOpen) {
      _tickersBox = await Hive.openBox<String>(_tickersBoxName);
    }
    if (_candlesBox == null || !_candlesBox!.isOpen) {
      _candlesBox = await Hive.openBox<String>(_candlesBoxName);
    }
    if (_metadataBox == null || !_metadataBox!.isOpen) {
      _metadataBox = await Hive.openBox<int>(_metadataBoxName);
    }
  }

  @override
  Future<void> cacheTickers(List<TickerModel> tickers) async {
    await _ensureInitialized();

    final tickersJson = tickers.map((t) => t.toJson()).toList();
    await _tickersBox!.put('all_tickers', jsonEncode(tickersJson));
    await _metadataBox!.put(
      'tickers_updated',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<TickerModel>?> getCachedTickers() async {
    await _ensureInitialized();

    final jsonString = _tickersBox!.get('all_tickers');
    if (jsonString == null) return null;

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .whereType<Map<String, dynamic>>()
          .map((json) => TickerModel.fromCacheJson(json))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheTicker(TickerModel ticker) async {
    await _ensureInitialized();

    await _tickersBox!.put(
      'ticker_${ticker.symbol}',
      jsonEncode(ticker.toJson()),
    );
    await _metadataBox!.put(
      'ticker_${ticker.symbol}_updated',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<TickerModel?> getCachedTicker(String symbol) async {
    await _ensureInitialized();

    final jsonString = _tickersBox!.get('ticker_$symbol');
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return TickerModel.fromCacheJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheCandles(
    String symbol,
    String interval,
    List<CandleModel> candles,
  ) async {
    await _ensureInitialized();

    final key = 'candles_${symbol}_$interval';
    final candlesJson = candles.map((c) => c.toJson()).toList();
    await _candlesBox!.put(key, jsonEncode(candlesJson));
    await _metadataBox!.put(
      '${key}_updated',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<CandleModel>?> getCachedCandles(
    String symbol,
    String interval,
  ) async {
    await _ensureInitialized();

    final key = 'candles_${symbol}_$interval';
    final jsonString = _candlesBox!.get(key);
    if (jsonString == null) return null;

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .whereType<Map<String, dynamic>>()
          .map((json) => CandleModel.fromCacheJson(json))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    await _ensureInitialized();

    await _tickersBox!.clear();
    await _candlesBox!.clear();
    await _metadataBox!.clear();
  }

  @override
  Future<DateTime?> getLastUpdateTime(String key) async {
    await _ensureInitialized();

    final timestamp = _metadataBox!.get('${key}_updated');
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Check if cache is stale (older than duration)
  Future<bool> isCacheStale(String key, Duration maxAge) async {
    final lastUpdate = await getLastUpdateTime(key);
    if (lastUpdate == null) return true;

    return DateTime.now().difference(lastUpdate) > maxAge;
  }

  /// Close all boxes
  Future<void> close() async {
    await _tickersBox?.close();
    await _candlesBox?.close();
    await _metadataBox?.close();
  }
}
