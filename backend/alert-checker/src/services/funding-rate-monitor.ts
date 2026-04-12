const BINANCE_FUTURES_API = 'https://fapi.binance.com';
const EXTREME_RATE_THRESHOLD = 0.01; // 1% considered extreme

export interface FundingRateAlert {
  symbol: string;
  fundingRate: number;
  nextFundingTime: string;
  isExtreme: boolean;
  direction: 'bullish' | 'bearish';
  detectedAt: string;
}

/**
 * Monitor Binance futures funding rates for extreme values.
 * High positive rate = longs paying shorts (bearish signal).
 * High negative rate = shorts paying longs (bullish signal).
 */
export async function checkFundingRates(symbols: string[]): Promise<FundingRateAlert[]> {
  const alerts: FundingRateAlert[] = [];

  try {
    const url = `${BINANCE_FUTURES_API}/fapi/v1/premiumIndex`;
    const resp = await fetch(url);
    if (!resp.ok) return alerts;

    const data = (await resp.json()) as Array<{
      symbol: string;
      lastFundingRate: string;
      nextFundingTime: number;
    }>;

    for (const item of data) {
      if (!symbols.includes(item.symbol)) continue;

      const rate = parseFloat(item.lastFundingRate);
      if (Math.abs(rate) >= EXTREME_RATE_THRESHOLD) {
        alerts.push({
          symbol: item.symbol,
          fundingRate: rate,
          nextFundingTime: new Date(item.nextFundingTime).toISOString(),
          isExtreme: true,
          direction: rate > 0 ? 'bearish' : 'bullish',
          detectedAt: new Date().toISOString(),
        });
      }
    }
  } catch {
    // Silently fail — futures API may not be accessible
  }

  return alerts;
}
