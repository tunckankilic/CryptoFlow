/// Supported exchange sources for market data
enum ExchangeSource {
  binance('Binance', true),
  coinbase('Coinbase', false),
  kraken('Kraken', false);

  final String displayName;
  final bool isImplemented;

  const ExchangeSource(this.displayName, this.isImplemented);
}
