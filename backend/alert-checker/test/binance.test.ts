import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { fetchAllPrices } from '../src/lib/binance';

describe('fetchAllPrices', () => {
  const originalFetch = globalThis.fetch;

  beforeEach(() => {
    globalThis.fetch = vi.fn();
  });
  afterEach(() => {
    globalThis.fetch = originalFetch;
  });

  it('parses ticker rows into a Map', async () => {
    (globalThis.fetch as unknown as ReturnType<typeof vi.fn>).mockResolvedValueOnce({
      ok: true,
      json: async () => [
        { symbol: 'BTCUSDT', price: '50000.5' },
        { symbol: 'ETHUSDT', price: '2500.0' },
      ],
    });
    const out = await fetchAllPrices();
    expect(out.get('BTCUSDT')).toBe(50000.5);
    expect(out.get('ETHUSDT')).toBe(2500);
    expect(out.size).toBe(2);
  });

  it('throws when the API returns an error status', async () => {
    (globalThis.fetch as unknown as ReturnType<typeof vi.fn>).mockResolvedValueOnce({
      ok: false,
      status: 503,
    });
    await expect(fetchAllPrices()).rejects.toThrow(/503/);
  });

  it('skips non-numeric rows', async () => {
    (globalThis.fetch as unknown as ReturnType<typeof vi.fn>).mockResolvedValueOnce({
      ok: true,
      json: async () => [
        { symbol: 'BTCUSDT', price: '50000' },
        { symbol: 'BAD', price: 'NaN' },
      ],
    });
    const out = await fetchAllPrices();
    expect(out.has('BTCUSDT')).toBe(true);
    expect(out.has('BAD')).toBe(false);
  });
});
