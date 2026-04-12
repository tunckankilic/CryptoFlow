import type {
  ExchangeAdapter,
  TickerData,
  KlineData,
  OrderBookData,
} from './exchange.interface';

/**
 * Kraken exchange adapter — STUB implementation.
 * All methods throw "not implemented" errors.
 * To be fully implemented when Kraken integration is prioritized.
 */
export class KrakenAdapter implements ExchangeAdapter {
  readonly name = 'kraken' as const;
  readonly displayName = 'Kraken';
  readonly isImplemented = false;

  async getTicker(_symbol: string): Promise<TickerData> {
    throw new Error('Kraken adapter not yet implemented');
  }

  async getAllTickers(): Promise<TickerData[]> {
    throw new Error('Kraken adapter not yet implemented');
  }

  async getKlines(_symbol: string, _interval: string, _limit: number): Promise<KlineData[]> {
    throw new Error('Kraken adapter not yet implemented');
  }

  async getOrderBook(_symbol: string, _limit: number): Promise<OrderBookData> {
    throw new Error('Kraken adapter not yet implemented');
  }
}
