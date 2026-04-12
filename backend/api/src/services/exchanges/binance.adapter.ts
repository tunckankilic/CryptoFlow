import type {
  ExchangeAdapter,
  TickerData,
  KlineData,
  OrderBookData,
} from './exchange.interface';

const BASE_URL = 'https://api.binance.com';

export class BinanceAdapter implements ExchangeAdapter {
  readonly name = 'binance' as const;
  readonly displayName = 'Binance';
  readonly isImplemented = true;

  async getTicker(symbol: string): Promise<TickerData> {
    const resp = await fetch(`${BASE_URL}/api/v3/ticker/24hr?symbol=${symbol}`);
    if (!resp.ok) throw new Error(`Binance ticker error: ${resp.status}`);
    const d = await resp.json() as Record<string, string>;
    return {
      symbol: d.symbol,
      price: parseFloat(d.lastPrice),
      volume24h: parseFloat(d.volume),
      priceChange24h: parseFloat(d.priceChange),
      priceChangePct24h: parseFloat(d.priceChangePercent),
      high24h: parseFloat(d.highPrice),
      low24h: parseFloat(d.lowPrice),
    };
  }

  async getAllTickers(): Promise<TickerData[]> {
    const resp = await fetch(`${BASE_URL}/api/v3/ticker/24hr`);
    if (!resp.ok) throw new Error(`Binance tickers error: ${resp.status}`);
    const data = (await resp.json()) as Array<Record<string, string>>;
    return data
      .filter((d) => d.symbol.endsWith('USDT'))
      .map((d) => ({
        symbol: d.symbol,
        price: parseFloat(d.lastPrice),
        volume24h: parseFloat(d.volume),
        priceChange24h: parseFloat(d.priceChange),
        priceChangePct24h: parseFloat(d.priceChangePercent),
        high24h: parseFloat(d.highPrice),
        low24h: parseFloat(d.lowPrice),
      }));
  }

  async getKlines(symbol: string, interval: string, limit: number): Promise<KlineData[]> {
    const resp = await fetch(
      `${BASE_URL}/api/v3/klines?symbol=${symbol}&interval=${interval}&limit=${limit}`,
    );
    if (!resp.ok) throw new Error(`Binance klines error: ${resp.status}`);
    const data = (await resp.json()) as number[][];
    return data.map((k) => ({
      openTime: k[0] as number,
      open: parseFloat(String(k[1])),
      high: parseFloat(String(k[2])),
      low: parseFloat(String(k[3])),
      close: parseFloat(String(k[4])),
      volume: parseFloat(String(k[5])),
      closeTime: k[6] as number,
    }));
  }

  async getOrderBook(symbol: string, limit: number): Promise<OrderBookData> {
    const resp = await fetch(
      `${BASE_URL}/api/v3/depth?symbol=${symbol}&limit=${limit}`,
    );
    if (!resp.ok) throw new Error(`Binance orderbook error: ${resp.status}`);
    const d = (await resp.json()) as {
      bids: string[][];
      asks: string[][];
    };
    return {
      bids: d.bids.map(([p, q]) => ({ price: parseFloat(p), quantity: parseFloat(q) })),
      asks: d.asks.map(([p, q]) => ({ price: parseFloat(p), quantity: parseFloat(q) })),
    };
  }
}
