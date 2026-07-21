import 'package:flutter_test/flutter_test.dart';
import 'package:market/market.dart';
import 'package:market_3d/market_3d.dart';

import '../helpers/candle_fixtures.dart';

void main() {
  group('PriceScale', () {
    test('maps minPrice to 0 and maxPrice to height', () {
      const scale = PriceScale(minPrice: 100, maxPrice: 200, height: 10);

      expect(scale.yOf(100), 0);
      expect(scale.yOf(200), 10);
      expect(scale.yOf(150), closeTo(5, 1e-9));
    });

    test('priceOf inverts yOf', () {
      const scale = PriceScale(minPrice: 100, maxPrice: 200, height: 10);

      expect(scale.priceOf(scale.yOf(137.5)), closeTo(137.5, 1e-9));
    });

    test('fromCandles covers the full high/low range with padding', () {
      final candles = [
        candleAt(0, open: 100, high: 110, low: 95, close: 105),
        candleAt(1, open: 105, high: 120, low: 90, close: 118),
      ];

      final scale = PriceScale.fromCandles(candles, height: 10);

      expect(scale.minPrice, lessThan(90));
      expect(scale.maxPrice, greaterThan(120));
      for (final candle in candles) {
        expect(scale.coversCandle(candle), isTrue);
      }
    });

    test('flat market does not divide by zero', () {
      final candles = [
        candleAt(0, open: 100, high: 100, low: 100, close: 100),
        candleAt(1, open: 100, high: 100, low: 100, close: 100),
      ];

      final scale = PriceScale.fromCandles(candles, height: 10);

      expect(scale.priceRange, greaterThan(0));
      expect(scale.yOf(100).isFinite, isTrue);
    });

    test('empty candle list produces a usable scale', () {
      final scale = PriceScale.fromCandles(const <Candle>[], height: 10);

      expect(scale.height, 10);
      expect(scale.yOf(0.5).isFinite, isTrue);
    });

    test('covers reports prices outside the built range', () {
      const scale = PriceScale(minPrice: 100, maxPrice: 200, height: 10);

      expect(scale.covers(150), isTrue);
      expect(scale.covers(250), isFalse);
      expect(scale.yOf(250), greaterThan(scale.height));
    });
  });
}
