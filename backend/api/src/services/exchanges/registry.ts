import type { ExchangeAdapter, ExchangeName } from './exchange.interface';
import { BinanceAdapter } from './binance.adapter';
import { CoinbaseAdapter } from './coinbase.adapter';
import { KrakenAdapter } from './kraken.adapter';

const adapters = new Map<ExchangeName, ExchangeAdapter>();

// Register all adapters
adapters.set('binance', new BinanceAdapter());
adapters.set('coinbase', new CoinbaseAdapter());
adapters.set('kraken', new KrakenAdapter());

/**
 * Get an exchange adapter by name.
 * Defaults to Binance if name is not provided.
 */
export function getExchangeAdapter(name?: ExchangeName): ExchangeAdapter {
  const adapter = adapters.get(name ?? 'binance');
  if (!adapter) throw new Error(`Unknown exchange: ${name}`);
  return adapter;
}

/**
 * List all registered exchange adapters.
 */
export function listExchanges(): Array<{ name: ExchangeName; displayName: string; isImplemented: boolean }> {
  return Array.from(adapters.values()).map((a) => ({
    name: a.name,
    displayName: a.displayName,
    isImplemented: a.isImplemented,
  }));
}
