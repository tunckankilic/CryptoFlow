import 'package:market/market.dart';

/// Base time for fixture candles, so open times are stable across tests.
final DateTime fixtureEpoch = DateTime.utc(2026, 1, 1);

/// Builds a one-minute candle at series position [index].
Candle candleAt(
  int index, {
  required double open,
  required double high,
  required double low,
  required double close,
  double volume = 1,
  int trades = 1,
}) {
  final openTime = fixtureEpoch.add(Duration(minutes: index));
  return Candle(
    openTime: openTime,
    closeTime: openTime.add(const Duration(minutes: 1)),
    open: open,
    high: high,
    low: low,
    close: close,
    volume: volume,
    trades: trades,
  );
}

/// Builds an order book with the given bid and ask `(price, quantity)` pairs.
OrderBook orderBook({
  required List<List<double>> bids,
  required List<List<double>> asks,
  String symbol = 'BTCUSDT',
}) {
  return OrderBook(
    symbol: symbol,
    bids: bids
        .map((e) => OrderBookEntry(price: e[0], quantity: e[1]))
        .toList(growable: false),
    asks: asks
        .map((e) => OrderBookEntry(price: e[0], quantity: e[1]))
        .toList(growable: false),
    lastUpdateId: 1,
  );
}
