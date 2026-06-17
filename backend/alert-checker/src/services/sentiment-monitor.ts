const FEAR_GREED_API = 'https://api.alternative.me/fng/';
const RAPID_CHANGE_THRESHOLD = 15; // 15-point shift is considered rapid

export interface SentimentAlert {
  currentValue: number;
  previousValue: number;
  change: number;
  classification: string;
  detectedAt: string;
}

/**
 * Monitor Fear & Greed Index for rapid shifts.
 * A shift of >=15 points between today and yesterday triggers an alert.
 */
export async function checkSentimentShift(): Promise<SentimentAlert | null> {
  try {
    const url = `${FEAR_GREED_API}?limit=2&format=json`;
    const resp = await fetch(url);
    if (!resp.ok) return null;

    const data = (await resp.json()) as {
      data: Array<{
        value: string;
        value_classification: string;
        timestamp: string;
      }>;
    };

    if (!data.data || data.data.length < 2) return null;

    const current = parseInt(data.data[0].value, 10);
    const previous = parseInt(data.data[1].value, 10);
    const change = current - previous;

    if (Math.abs(change) >= RAPID_CHANGE_THRESHOLD) {
      return {
        currentValue: current,
        previousValue: previous,
        change,
        classification: data.data[0].value_classification,
        detectedAt: new Date().toISOString(),
      };
    }
  } catch {
    // Silently fail
  }

  return null;
}
