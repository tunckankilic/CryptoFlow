import 'package:flutter_test/flutter_test.dart';
import 'package:market_3d/market_3d.dart';

import '../helpers/candle_fixtures.dart';

void main() {
  final adapter = DepthSceneAdapter();
  final layout = adapter.layout;

  final book = orderBook(
    bids: [
      [99.0, 2.0],
      [98.0, 3.0],
      [97.0, 5.0],
    ],
    asks: [
      [101.0, 1.0],
      [102.0, 2.0],
      [103.0, 4.0],
    ],
  );

  group('buildSurface', () {
    test('accumulates quantity outward from the mid price', () {
      final surface = adapter.buildSurface(book);

      expect(surface.bids.map((s) => s.cumulativeQuantity), [2.0, 5.0, 10.0]);
      expect(surface.asks.map((s) => s.cumulativeQuantity), [1.0, 3.0, 7.0]);
      expect(surface.maxCumulativeQuantity, 10.0);
    });

    test('normalises the deepest side to the layout height', () {
      final surface = adapter.buildSurface(book);

      expect(surface.bids.last.height, closeTo(layout.maxHeight, 1e-9));
      expect(surface.asks.last.height, lessThan(layout.maxHeight));
      for (final sample in [...surface.bids, ...surface.asks]) {
        expect(sample.height, inInclusiveRange(0, layout.maxHeight));
      }
    });

    test('puts bids left of the mid price and asks right', () {
      final surface = adapter.buildSurface(book);

      expect(surface.bids.every((s) => s.position.x < 0), isTrue);
      expect(surface.asks.every((s) => s.position.x > 0), isTrue);
    });

    test('keeps the spread gap clear around the mid price', () {
      final surface = adapter.buildSurface(book);

      for (final sample in [...surface.bids, ...surface.asks]) {
        expect(sample.position.x.abs(),
            greaterThanOrEqualTo(layout.spreadGap / 2));
      }
    });

    test('spaces levels by price distance, not by index', () {
      final wideBook = orderBook(
        bids: [
          [99.0, 1.0],
          [50.0, 1.0],
        ],
        asks: [
          [101.0, 1.0],
        ],
      );

      final surface = adapter.buildSurface(wideBook);
      final near = surface.bids[0].position.x.abs();
      final far = surface.bids[1].position.x.abs();

      expect(far, greaterThan(near * 5));
    });

    test('sorts entries that arrive out of order', () {
      final shuffled = orderBook(
        bids: [
          [97.0, 5.0],
          [99.0, 2.0],
          [98.0, 3.0],
        ],
        asks: [
          [103.0, 4.0],
          [101.0, 1.0],
          [102.0, 2.0],
        ],
      );

      final surface = adapter.buildSurface(shuffled);

      expect(surface.bids.map((s) => s.price), [99.0, 98.0, 97.0]);
      expect(surface.asks.map((s) => s.price), [101.0, 102.0, 103.0]);
    });

    test('limits each side to the requested number of levels', () {
      final surface = adapter.buildSurface(book, levels: 2);

      expect(surface.bids, hasLength(2));
      expect(surface.asks, hasLength(2));
    });

    test('returns an empty surface for an empty book', () {
      final surface = adapter.buildSurface(orderBook(bids: [], asks: []));

      expect(surface.isEmpty, isTrue);
      expect(surface.maxCumulativeQuantity, 0);
    });

    test('survives a book with no resting quantity', () {
      final flat = orderBook(
        bids: [
          [99.0, 0.0],
        ],
        asks: [
          [101.0, 0.0],
        ],
      );

      final surface = adapter.buildSurface(flat);

      expect(surface.bids.single.height, 0);
      expect(surface.asks.single.height, 0);
    });
  });
}
