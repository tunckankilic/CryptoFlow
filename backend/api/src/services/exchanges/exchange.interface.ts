/**
 * Unified exchange adapter interface.
 * All exchange adapters must implement this interface for multi-exchange support.
 */

export interface TickerData {
  symbol: string;
  price: number;
  volume24h: number;
  priceChange24h: number;
  priceChangePct24h: number;
  high24h: number;
  low24h: number;
}

export interface KlineData {
  openTime: number;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
  closeTime: number;
}

export interface OrderBookData {
  bids: Array<{ price: number; quantity: number }>;
  asks: Array<{ price: number; quantity: number }>;
}

export type ExchangeName = 'binance' | 'coinbase' | 'kraken';

export interface ExchangeAdapter {
  readonly name: ExchangeName;
  readonly displayName: string;
  readonly isImplemented: boolean;

  getTicker(symbol: string): Promise<TickerData>;
  getAllTickers(): Promise<TickerData[]>;
  getKlines(symbol: string, interval: string, limit: number): Promise<KlineData[]>;
  getOrderBook(symbol: string, limit: number): Promise<OrderBookData>;
}
