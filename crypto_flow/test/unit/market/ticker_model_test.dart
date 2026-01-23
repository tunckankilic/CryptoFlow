import 'package:flutter_test/flutter_test.dart';
import 'package:market/data/models/ticker_model.dart';

import '../../fixtures/ticker_fixtures.dart';

void main() {
  group('TickerModel', () {
    group('fromJson (REST API)', () {
      test('parses REST response correctly', () {
        final model = TickerModel.fromJson(TickerFixtures.restApiTickerJson);

        expect(model.symbol, 'BTCUSDT');
        expect(model.baseAsset, 'BTC');
        expect(model.quoteAsset, 'USDT');
        expect(model.price, 69000.0);
        expect(model.priceChange, 1000.0);
        expect(model.priceChangePercent, 1.5);
        expect(model.high24h, 70000.0);
        expect(model.low24h, 67500.0);
        expect(model.volume, 15000.0);
        expect(model.quoteVolume, 1035000000.0);
        expect(model.trades, 100000);
      });

      test('handles null values gracefully', () {
        final model = TickerModel.fromJson(TickerFixtures.nullValuesJson);

        expect(model.symbol, 'BTCUSDT');
        expect(model.price, 0.0);
        expect(model.priceChange, 0.0);
        expect(model.priceChangePercent, 0.0);
        expect(model.high24h, 0.0);
        expect(model.low24h, 0.0);
        expect(model.volume, 0.0);
        expect(model.quoteVolume, 0.0);
        expect(model.trades, 0);
      });

      test('parses string numbers correctly', () {
        final model = TickerModel.fromJson(TickerFixtures.stringNumbersJson);

        expect(model.symbol, 'BTCUSDT');
        expect(model.price, closeTo(69000.12, 0.01));
        expect(model.priceChange, closeTo(-500.50, 0.01));
        expect(model.priceChangePercent, closeTo(-0.72, 0.01));
      });
    });

    group('fromWsJson (WebSocket)', () {
      test('parses WebSocket ticker response correctly', () {
        final model = TickerModel.fromWsJson(TickerFixtures.wsTickerJson);

        expect(model.symbol, 'BTCUSDT');
        expect(model.baseAsset, 'BTC');
        expect(model.quoteAsset, 'USDT');
        expect(model.price, 69000.0);
        expect(model.priceChange, 1000.0);
        expect(model.priceChangePercent, 1.5);
        expect(model.high24h, 70000.0);
        expect(model.low24h, 67500.0);
        expect(model.volume, 15000.0);
        expect(model.quoteVolume, 1035000000.0);
        expect(model.trades, 100000);
      });

      test('parses event timestamp correctly', () {
        final model = TickerModel.fromWsJson(TickerFixtures.wsTickerJson);

        expect(model.lastUpdate, isNotNull);
        expect(
          model.lastUpdate!.millisecondsSinceEpoch,
          1704153600000,
        );
      });
    });

    group('fromMiniTicker', () {
      test('parses mini ticker response correctly', () {
        final model = TickerModel.fromMiniTicker(TickerFixtures.miniTickerJson);

        expect(model.symbol, 'ETHUSDT');
        expect(model.baseAsset, 'ETH');
        expect(model.quoteAsset, 'USDT');
        expect(model.price, 2500.0);
        expect(model.high24h, 2550.0);
        expect(model.low24h, 2350.0);
        expect(model.volume, 50000.0);
        expect(model.quoteVolume, 125000000.0);
      });

      test('calculates price change from open price', () {
        final model = TickerModel.fromMiniTicker(TickerFixtures.miniTickerJson);

        // Price: 2500, Open: 2400, Change: 100
        expect(model.priceChange, closeTo(100.0, 0.01));
        // Change percent: (100/2400) * 100 ≈ 4.17%
        expect(model.priceChangePercent, closeTo(4.17, 0.01));
      });

      test('trades count is 0 for mini ticker', () {
        final model = TickerModel.fromMiniTicker(TickerFixtures.miniTickerJson);
        expect(model.trades, 0);
      });
    });

    group('fromCacheJson', () {
      test('parses cached JSON correctly', () {
        final model =
            TickerModel.fromCacheJson(TickerFixtures.cachedTickerJson);

        expect(model.symbol, 'BTCUSDT');
        expect(model.baseAsset, 'BTC');
        expect(model.quoteAsset, 'USDT');
        expect(model.price, 69000.0);
        expect(model.priceChange, 1000.0);
        expect(model.priceChangePercent, 1.5);
        expect(model.trades, 100000);
        expect(model.lastUpdate, isNotNull);
      });
    });

    group('toJson', () {
      test('serializes model to JSON correctly', () {
        final model = TickerModel.fromJson(TickerFixtures.restApiTickerJson);
        final json = model.toJson();

        expect(json['symbol'], 'BTCUSDT');
        expect(json['baseAsset'], 'BTC');
        expect(json['quoteAsset'], 'USDT');
        expect(json['lastPrice'], '69000.0');
        expect(json['priceChange'], '1000.0');
        expect(json['priceChangePercent'], '1.5');
        expect(json['count'], 100000);
      });

      test('roundtrip serialization works', () {
        final original = TickerModel.fromJson(TickerFixtures.restApiTickerJson);
        final json = original.toJson();
        final restored = TickerModel.fromCacheJson(json);

        expect(restored.symbol, original.symbol);
        expect(restored.price, original.price);
        expect(restored.priceChange, original.priceChange);
        expect(restored.priceChangePercent, original.priceChangePercent);
      });
    });

    group('asset extraction', () {
      test('extracts base asset for USDT pairs', () {
        final model = TickerModel.fromJson(
            {'symbol': 'BTCUSDT', ...TickerFixtures.restApiTickerJson});
        expect(model.baseAsset, 'BTC');
        expect(model.quoteAsset, 'USDT');
      });

      test('extracts base asset for BTC pairs', () {
        final json = {...TickerFixtures.restApiTickerJson, 'symbol': 'ETHBTC'};
        final model = TickerModel.fromJson(json);
        expect(model.baseAsset, 'ETH');
        expect(model.quoteAsset, 'BTC');
      });

      test('extracts base asset for BNB pairs', () {
        final json = {...TickerFixtures.restApiTickerJson, 'symbol': 'SOLBNB'};
        final model = TickerModel.fromJson(json);
        expect(model.baseAsset, 'SOL');
        expect(model.quoteAsset, 'BNB');
      });

      test('handles FDUSD pairs', () {
        final json = {
          ...TickerFixtures.restApiTickerJson,
          'symbol': 'BTCFDUSD'
        };
        final model = TickerModel.fromJson(json);
        expect(model.baseAsset, 'BTC');
        expect(model.quoteAsset, 'FDUSD');
      });
    });

    group('toEntity', () {
      test('converts model to entity', () {
        final model = TickerModel.fromJson(TickerFixtures.restApiTickerJson);
        final entity = model.toEntity();

        expect(entity.symbol, model.symbol);
        expect(entity.price, model.price);
        expect(entity.baseAsset, model.baseAsset);
        expect(entity.quoteAsset, model.quoteAsset);
      });
    });
  });
}
