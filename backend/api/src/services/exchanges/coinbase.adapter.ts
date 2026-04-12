import type {
  ExchangeAdapter,
  TickerData,
  KlineData,
  OrderBookData,
} from './exchange.interface';

/**
 * Coinbase exchange adapter — STUB implementation.
 * All methods throw "not implemented" errors.
 * To be fully implemented when Coinbase integration is prioritized.
 */
export class CoinbaseAdapter implements ExchangeAdapter {
  readonly name = 'coinbase' as const;
  readonly displayName = 'Coinbase';
  readonly isImplemented = false;

  async getTicker(_symbol: string): Promise<TickerData> {
    throw new Error('Coinbase adapter not yet implemented');
  }

  async getAllTickers(): Promise<TickerData[]> {
    throw new Error('Coinbase adapter not yet implemented');
  }

  async getKlines(_symbol: string, _interval: string, _limit: number): Promise<KlineData[]> {
    throw new Error('Coinbase adapter not yet implemented');
  }

  async getOrderBook(_symbol: string, _limit: number): Promise<OrderBookData> {
    throw new Error('Coinbase adapter not yet implemented');
  }
}
