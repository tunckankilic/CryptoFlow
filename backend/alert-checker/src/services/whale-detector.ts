const BINANCE_API = 'https://api.binance.com';
const VOLUME_SPIKE_MULTIPLIER = 3;

export interface WhaleAlert {
  symbol: string;
  currentVolume: number;
  avgVolume: number;
  spikeMultiplier: number;
  detectedAt: string;
}

/**
 * Detect volume spikes that indicate whale activity.
 * A spike is defined as current volume > 3x the 7-day average.
 */
export async function detectWhaleActivity(symbols: string[]): Promise<WhaleAlert[]> {
  const alerts: WhaleAlert[] = [];

  for (const symbol of symbols) {
    try {
      // Fetch 7 daily klines for average volume
      const klineUrl = `${BINANCE_API}/api/v3/klines?symbol=${symbol}&interval=1d&limit=8`;
      const klineResp = await fetch(klineUrl);
      if (!klineResp.ok) continue;

      const klines = (await klineResp.json()) as number[][];
      if (klines.length < 2) continue;

      // Last entry is today (partial), previous entries for average
      const historicalVolumes = klines.slice(0, -1).map((k) => parseFloat(String(k[5])));
      const currentVolume = parseFloat(String(klines[klines.length - 1][5]));

      const avgVolume =
        historicalVolumes.reduce((a, b) => a + b, 0) / historicalVolumes.length;

      if (avgVolume > 0 && currentVolume > avgVolume * VOLUME_SPIKE_MULTIPLIER) {
        alerts.push({
          symbol,
          currentVolume,
          avgVolume,
          spikeMultiplier: Math.round((currentVolume / avgVolume) * 100) / 100,
          detectedAt: new Date().toISOString(),
        });
      }
    } catch {
      // Skip symbol on error
    }
  }

  return alerts;
}
