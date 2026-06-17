import { listHoldings, listTransactions } from './portfolio.service';

// ── Types ────────────────────────────────────────────────────────────────────

export interface PositionSizeResult {
  symbol: string;
  accountSize: number;
  riskPercentage: number;
  entryPrice: number;
  stopLossPrice: number;
  positionSize: number;
  positionValue: number;
  riskAmount: number;
}

export interface CorrelationMatrix {
  symbols: string[];
  matrix: number[][];
  period: string;
}

export interface VaRResult {
  portfolioValue: number;
  confidence: number;
  holdingPeriodDays: number;
  historicalVaR: number;
  historicalVaRPct: number;
  componentVaR: ComponentVaR[];
}

export interface ComponentVaR {
  symbol: string;
  weight: number;
  value: number;
  var: number;
}

// ── Constants ────────────────────────────────────────────────────────────────

const BINANCE_API = 'https://api.binance.com';

// ── Helpers ──────────────────────────────────────────────────────────────────

async function fetchDailyCloses(symbol: string, days: number): Promise<number[]> {
  const endTime = Date.now();
  const startTime = endTime - days * 24 * 60 * 60 * 1000;
  const url = `${BINANCE_API}/api/v3/klines?symbol=${symbol}&interval=1d&startTime=${startTime}&endTime=${endTime}&limit=${days}`;
  const resp = await fetch(url);
  if (!resp.ok) return [];
  const data = (await resp.json()) as number[][];
  return data.map((k) => parseFloat(String(k[4]))); // close prices
}

function dailyReturns(prices: number[]): number[] {
  const returns: number[] = [];
  for (let i = 1; i < prices.length; i++) {
    if (prices[i - 1] !== 0) {
      returns.push((prices[i] - prices[i - 1]) / prices[i - 1]);
    }
  }
  return returns;
}

function pearsonCorrelation(x: number[], y: number[]): number {
  const n = Math.min(x.length, y.length);
  if (n < 3) return 0;

  let sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;
  for (let i = 0; i < n; i++) {
    sumX += x[i];
    sumY += y[i];
    sumXY += x[i] * y[i];
    sumX2 += x[i] * x[i];
    sumY2 += y[i] * y[i];
  }

  const numerator = n * sumXY - sumX * sumY;
  const denominator = Math.sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));
  if (denominator === 0) return 0;
  return Math.round((numerator / denominator) * 1000) / 1000;
}

function percentile(arr: number[], p: number): number {
  const sorted = [...arr].sort((a, b) => a - b);
  const idx = (p / 100) * (sorted.length - 1);
  const lower = Math.floor(idx);
  const upper = Math.ceil(idx);
  if (lower === upper) return sorted[lower];
  return sorted[lower] + (sorted[upper] - sorted[lower]) * (idx - lower);
}

// ── Position Size Calculator ────────────────────────────────────────────────

export function calculatePositionSize(
  accountSize: number,
  riskPercentage: number,
  entryPrice: number,
  stopLossPrice: number,
  symbol: string,
): PositionSizeResult {
  const riskAmount = accountSize * (riskPercentage / 100);
  const priceRisk = Math.abs(entryPrice - stopLossPrice);
  const positionSize = priceRisk > 0 ? riskAmount / priceRisk : 0;
  const positionValue = positionSize * entryPrice;

  return {
    symbol,
    accountSize: Math.round(accountSize * 100) / 100,
    riskPercentage,
    entryPrice,
    stopLossPrice,
    positionSize: Math.round(positionSize * 100000000) / 100000000, // 8 decimal for crypto
    positionValue: Math.round(positionValue * 100) / 100,
    riskAmount: Math.round(riskAmount * 100) / 100,
  };
}

// ── Correlation Matrix ──────────────────────────────────────────────────────

export async function getCorrelationMatrix(
  userId: string,
  period: string = 'monthly',
): Promise<CorrelationMatrix> {
  const holdings = await listHoldings(userId);
  const symbols = holdings
    .map((h) => h.symbol.toUpperCase())
    .filter((s) => s.endsWith('USDT'))
    .slice(0, 10); // Limit to 10 for performance

  if (symbols.length === 0) {
    return { symbols: [], matrix: [], period };
  }

  const days = period === 'weekly' ? 30 : period === 'monthly' ? 90 : period === 'quarterly' ? 180 : 365;

  // Fetch all price histories in parallel
  const priceHistories = await Promise.all(
    symbols.map((s) => fetchDailyCloses(s, days)),
  );

  // Calculate returns for each
  const returnSeries = priceHistories.map((prices) => dailyReturns(prices));

  // Build correlation matrix
  const n = symbols.length;
  const matrix: number[][] = Array.from({ length: n }, () => Array(n).fill(0));

  for (let i = 0; i < n; i++) {
    matrix[i][i] = 1;
    for (let j = i + 1; j < n; j++) {
      const corr = pearsonCorrelation(returnSeries[i], returnSeries[j]);
      matrix[i][j] = corr;
      matrix[j][i] = corr;
    }
  }

  return {
    symbols: symbols.map((s) => s.replace('USDT', '')),
    matrix,
    period,
  };
}

// ── Value at Risk (Historical Simulation) ───────────────────────────────────

export async function calculateVaR(
  userId: string,
  confidence: number = 95,
  holdingPeriodDays: number = 1,
): Promise<VaRResult> {
  const holdings = await listHoldings(userId);
  if (holdings.length === 0) {
    return {
      portfolioValue: 0,
      confidence,
      holdingPeriodDays,
      historicalVaR: 0,
      historicalVaRPct: 0,
      componentVaR: [],
    };
  }

  // Fetch current prices
  const resp = await fetch(`${BINANCE_API}/api/v3/ticker/price`);
  const tickers = (await resp.json()) as Array<{ symbol: string; price: string }>;
  const priceMap = new Map(tickers.map((t) => [t.symbol, parseFloat(t.price)]));

  // Calculate portfolio value and weights
  let portfolioValue = 0;
  const holdingValues: Array<{ symbol: string; value: number }> = [];

  for (const h of holdings) {
    const symbol = h.symbol.toUpperCase();
    const price = priceMap.get(symbol) ?? h.avgBuyPrice;
    const value = h.quantity * price;
    portfolioValue += value;
    holdingValues.push({ symbol, value });
  }

  if (portfolioValue === 0) {
    return {
      portfolioValue: 0,
      confidence,
      holdingPeriodDays,
      historicalVaR: 0,
      historicalVaRPct: 0,
      componentVaR: [],
    };
  }

  // Fetch historical returns for each asset (90 days)
  const symbolReturns = new Map<string, number[]>();
  await Promise.all(
    holdingValues.map(async ({ symbol }) => {
      const prices = await fetchDailyCloses(symbol, 90);
      symbolReturns.set(symbol, dailyReturns(prices));
    }),
  );

  // Calculate portfolio daily returns (weighted)
  const minLen = Math.min(
    ...Array.from(symbolReturns.values()).map((r) => r.length).filter((l) => l > 0),
    90,
  );

  const portfolioReturns: number[] = [];
  for (let d = 0; d < minLen; d++) {
    let dayReturn = 0;
    for (const { symbol, value } of holdingValues) {
      const returns = symbolReturns.get(symbol) ?? [];
      const weight = value / portfolioValue;
      dayReturn += weight * (returns[d] ?? 0);
    }
    portfolioReturns.push(dayReturn);
  }

  // Scale to holding period
  const scaledReturns = portfolioReturns.map(
    (r) => r * Math.sqrt(holdingPeriodDays),
  );

  // VaR at confidence level
  const varPct = -percentile(scaledReturns, 100 - confidence);
  const varAbs = varPct * portfolioValue;

  // Component VaR
  const componentVaR: ComponentVaR[] = holdingValues.map(({ symbol, value }) => {
    const returns = symbolReturns.get(symbol) ?? [];
    const scaled = returns.map((r) => r * Math.sqrt(holdingPeriodDays));
    const cVarPct = scaled.length > 0 ? -percentile(scaled, 100 - confidence) : 0;
    return {
      symbol: symbol.replace('USDT', ''),
      weight: Math.round((value / portfolioValue) * 10000) / 10000,
      value: Math.round(value * 100) / 100,
      var: Math.round(cVarPct * value * 100) / 100,
    };
  });

  return {
    portfolioValue: Math.round(portfolioValue * 100) / 100,
    confidence,
    holdingPeriodDays,
    historicalVaR: Math.round(varAbs * 100) / 100,
    historicalVaRPct: Math.round(varPct * 10000) / 10000,
    componentVaR,
  };
}
