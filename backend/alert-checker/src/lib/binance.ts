/**
 * Fetch the latest price for every Binance ticker.
 *
 * Endpoint: GET https://api.binance.com/api/v3/ticker/price
 * No API key required (public endpoint).
 * Returns a single map: symbol → price (number).
 */
export async function fetchAllPrices(): Promise<Map<string, number>> {
  const res = await fetch('https://api.binance.com/api/v3/ticker/price');
  if (!res.ok) {
    throw new Error(`Binance ticker fetch failed: ${res.status}`);
  }
  const data = (await res.json()) as Array<{ symbol: string; price: string }>;
  const out = new Map<string, number>();
  for (const row of data) {
    const n = Number(row.price);
    if (Number.isFinite(n)) out.set(row.symbol, n);
  }
  return out;
}
