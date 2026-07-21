import 'package:market/market.dart';

import '../models/depth_surface.dart';
import '../models/vec3.dart';

/// Turns an order book snapshot into depth terrain geometry.
///
/// Heights are cumulative volume outward from the mid price — the same shape
/// as a 2D depth chart, lifted into a surface. Positions are price-proportional
/// rather than evenly spaced, so a thin book with a wide spread looks wide.
class DepthSceneAdapter {
  /// Geometry parameters applied to every surface this adapter builds.
  final DepthLayout layout;

  DepthSceneAdapter({DepthLayout? layout})
      : layout = layout ?? DepthLayout.standard();

  /// Builds a depth surface from [book], using at most [levels] per side.
  DepthSurface buildSurface(OrderBook book, {int levels = 20}) {
    // The entity documents bids as descending and asks as ascending, but the
    // surface is only correct if that actually holds, so sort defensively.
    final bids = List<OrderBookEntry>.of(book.bids)
      ..sort((a, b) => b.price.compareTo(a.price));
    final asks = List<OrderBookEntry>.of(book.asks)
      ..sort((a, b) => a.price.compareTo(b.price));

    final nearBids = bids.take(levels).toList();
    final nearAsks = asks.take(levels).toList();

    if (nearBids.isEmpty && nearAsks.isEmpty) {
      return DepthSurface.empty(symbol: book.symbol, layout: layout);
    }

    final mid = book.midPrice > 0
        ? book.midPrice
        : (nearBids.isNotEmpty ? nearBids.first.price : nearAsks.first.price);

    final maxCumulative = _cumulativeTotal(nearBids) > _cumulativeTotal(nearAsks)
        ? _cumulativeTotal(nearBids)
        : _cumulativeTotal(nearAsks);

    final maxOffset = _maxOffset(nearBids, nearAsks, mid);

    return DepthSurface(
      symbol: book.symbol,
      midPrice: mid,
      bids: _samples(nearBids, mid, maxCumulative, maxOffset, isBid: true),
      asks: _samples(nearAsks, mid, maxCumulative, maxOffset, isBid: false),
      maxCumulativeQuantity: maxCumulative,
      layout: layout,
    );
  }

  List<DepthSample> _samples(
    List<OrderBookEntry> entries,
    double mid,
    double maxCumulative,
    double maxOffset, {
    required bool isBid,
  }) {
    final samples = <DepthSample>[];
    var cumulative = 0.0;

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      cumulative += entry.quantity;

      final priceOffset = (entry.price - mid).abs();
      // Fall back to even spacing when every level sits at the same price,
      // which happens on degenerate or single-level books.
      final normalizedOffset = maxOffset > 0
          ? priceOffset / maxOffset
          : (entries.length > 1 ? i / (entries.length - 1) : 0.0);

      final distance =
          layout.spreadGap / 2 + normalizedOffset * layout.sideWidth;
      final height = maxCumulative > 0
          ? (cumulative / maxCumulative) * layout.maxHeight
          : 0.0;

      samples.add(
        DepthSample(
          price: entry.price,
          quantity: entry.quantity,
          cumulativeQuantity: cumulative,
          position: Vec3(isBid ? -distance : distance, height, 0),
        ),
      );
    }

    return samples;
  }

  double _cumulativeTotal(List<OrderBookEntry> entries) {
    return entries.fold(0.0, (sum, entry) => sum + entry.quantity);
  }

  double _maxOffset(
    List<OrderBookEntry> bids,
    List<OrderBookEntry> asks,
    double mid,
  ) {
    var maxOffset = 0.0;
    for (final entry in [...bids, ...asks]) {
      final offset = (entry.price - mid).abs();
      if (offset > maxOffset) maxOffset = offset;
    }
    return maxOffset;
  }
}
