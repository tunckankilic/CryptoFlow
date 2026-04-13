/// Utility for parsing crypto trading pair symbols (e.g., "BTCUSDT" → "BTC" + "USDT").
///
/// Shared across market, portfolio, and alert packages to avoid duplicating
/// the extraction logic that was previously broken in the portfolio module.
class SymbolUtils {
  SymbolUtils._();

  /// Well-known quote assets, ordered longest-first so "FDUSD" matches
  /// before "USD" would (if it were in the list).
  static const quoteAssets = [
    'FDUSD',
    'USDT',
    'BUSD',
    'USDC',
    'TUSD',
    'BTC',
    'ETH',
    'BNB',
    'EUR',
    'GBP',
    'TRY',
    'DAI',
  ];

  /// Extract the base asset from a trading pair symbol.
  ///
  /// ```dart
  /// SymbolUtils.extractBaseAsset('BTCUSDT')  // → 'BTC'
  /// SymbolUtils.extractBaseAsset('ETHBTC')   // → 'ETH'
  /// SymbolUtils.extractBaseAsset('BNBETH')   // → 'BNB'
  /// ```
  static String extractBaseAsset(String symbol) {
    for (final quote in quoteAssets) {
      if (symbol.endsWith(quote) && symbol.length > quote.length) {
        return symbol.substring(0, symbol.length - quote.length);
      }
    }
    // Fallback: take first 3-4 characters
    return symbol.length > 4
        ? symbol.substring(0, symbol.length - 4)
        : symbol;
  }

  /// Extract the quote asset from a trading pair symbol.
  ///
  /// ```dart
  /// SymbolUtils.extractQuoteAsset('BTCUSDT')  // → 'USDT'
  /// SymbolUtils.extractQuoteAsset('ETHBTC')   // → 'BTC'
  /// ```
  static String extractQuoteAsset(String symbol) {
    for (final quote in quoteAssets) {
      if (symbol.endsWith(quote) && symbol.length > quote.length) {
        return quote;
      }
    }
    // Fallback: take last 4 characters
    return symbol.length > 4 ? symbol.substring(symbol.length - 4) : '';
  }
}
