import { listHoldings, listTransactions } from './portfolio.service';

// ── Types ────────────────────────────────────────────────────────────────────

export interface PerformanceMetrics {
  period: string;
  totalReturn: number;
  totalReturnPct: number;
  sharpeRatio: number;
  sortinoRatio: number;
  maxDrawdown: number;
  maxDrawdownPct: number;
  winRate: number;
  profitFactor: number;
  monthlyReturns: MonthlyReturn[];
  benchmarks: BenchmarkComparison[];
}

export interface MonthlyReturn {
  month: string; // YYYY-MM
  returnPct: number;
  returnAbs: number;
}

export interface BenchmarkComparison {
  symbol: string;
  portfolioReturnPct: number;
  benchmarkReturnPct: number;
  alpha: number;
}

// ── Constants ────────────────────────────────────────────────────────────────

const RISK_FREE_RATE_ANNUAL = 0.05; // 5% annual risk-free rate
const BINANCE_API = 'https://api.binance.com';
const BENCHMARK_SYMBOLS = ['BTCUSDT', 'ETHUSDT'];

// ── Helpers ──────────────────────────────────────────────────────────────────

function dailyReturns(values: number[]): number[] {
  const returns: number[] = [];
  for (let i = 1; i < values.length; i++) {
    if (values[i - 1] !== 0) {
      returns.push((values[i] - values[i - 1]) / values[i - 1]);
    }
  }
  return returns;
}

function mean(arr: number[]): number {
  if (arr.length === 0) return 0;
  return arr.reduce((a, b) => a + b, 0) / arr.length;
}

function stdDev(arr: number[]): number {
  if (arr.length < 2) return 0;
  const m = mean(arr);
  const variance = arr.reduce((sum, v) => sum + (v - m) ** 2, 0) / (arr.length - 1);
  return Math.sqrt(variance);
}

function downsideStdDev(returns: number[], threshold: number = 0): number {
  const downside = returns.filter((r) => r < threshold);
  if (downside.length < 2) return 0;
  const variance =
    downside.reduce((sum, v) => sum + (v - threshold) ** 2, 0) / (downside.length - 1);
  return Math.sqrt(variance);
}

function calcSharpeRatio(returns: number[], tradingDays: number = 365): number {
  if (returns.length < 2) return 0;
  const dailyRf = RISK_FREE_RATE_ANNUAL / tradingDays;
  const excessReturns = returns.map((r) => r - dailyRf);
  const std = stdDev(excessReturns);
  if (std === 0) return 0;
  return (mean(excessReturns) / std) * Math.sqrt(tradingDays);
}

function calcSortinoRatio(returns: number[], tradingDays: number = 365): number {
  if (returns.length < 2) return 0;
  const dailyRf = RISK_FREE_RATE_ANNUAL / tradingDays;
  const excessReturns = returns.map((r) => r - dailyRf);
  const dsd = downsideStdDev(excessReturns);
  if (dsd === 0) return 0;
  return (mean(excessReturns) / dsd) * Math.sqrt(tradingDays);
}

function calcMaxDrawdown(values: number[]): { abs: number; pct: number } {
  let peak = values[0] ?? 0;
  let maxDdAbs = 0;
  let maxDdPct = 0;

  for (const v of values) {
    if (v > peak) peak = v;
    const dd = peak - v;
    if (dd > maxDdAbs) maxDdAbs = dd;
    const ddPct = peak > 0 ? dd / peak : 0;
    if (ddPct > maxDdPct) maxDdPct = ddPct;
  }
  return { abs: maxDdAbs, pct: maxDdPct * 100 };
}

function groupByMonth(
  transactions: Array<{ timestamp: string; type: string; quantity: number; price: number; fee: number }>,
): Map<string, number> {
  const monthly = new Map<string, number>();
  for (const tx of transactions) {
    const month = tx.timestamp.slice(0, 7); // YYYY-MM
    const value = tx.type === 'sell'
      ? tx.quantity * tx.price - tx.fee
      : -(tx.quantity * tx.price + tx.fee);
    monthly.set(month, (monthly.get(month) ?? 0) + value);
  }
  return monthly;
}

async function fetchBenchmarkPrices(symbol: string, startTime: number, endTime: number): Promise<number[]> {
  const url = `${BINANCE_API}/api/v3/klines?symbol=${symbol}&interval=1d&startTime=${startTime}&endTime=${endTime}&limit=1000`;
  const resp = await fetch(url);
  if (!resp.ok) return [];
  const data = (await resp.json()) as number[][];
  return data.map((k) => parseFloat(String(k[4]))); // close prices
}

// ── Period helpers ───────────────────────────────────────────────────────────

function periodToMs(period: string): number {
  switch (period) {
    case 'weekly':
      return 7 * 24 * 60 * 60 * 1000;
    case 'monthly':
      return 30 * 24 * 60 * 60 * 1000;
    case 'quarterly':
      return 90 * 24 * 60 * 60 * 1000;
    case 'yearly':
      return 365 * 24 * 60 * 60 * 1000;
    default:
      return 365 * 24 * 60 * 60 * 1000;
  }
}

// ── Main Service ─────────────────────────────────────────────────────────────

export async function getPerformanceAnalytics(
  userId: string,
  period: string = 'monthly',
): Promise<PerformanceMetrics> {
  const now = Date.now();
  const startTime = now - periodToMs(period);

  const [holdings, allTransactions] = await Promise.all([
    listHoldings(userId),
    listTransactions(userId),
  ]);

  // Filter transactions by period
  const transactions = allTransactions.filter(
    (tx) => new Date(tx.timestamp).getTime() >= startTime,
  );

  // Build portfolio value timeline from transactions
  const portfolioValues: number[] = [];
  let runningValue = 0;
  const sortedTx = [...transactions].sort(
    (a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime(),
  );

  for (const tx of sortedTx) {
    if (tx.type === 'buy') {
      runningValue += tx.quantity * tx.price;
    } else if (tx.type === 'sell') {
      runningValue -= tx.quantity * tx.price;
    }
    portfolioValues.push(Math.abs(runningValue));
  }

  // Current portfolio value from holdings
  const totalInvested = holdings.reduce((sum, h) => sum + h.quantity * h.avgBuyPrice, 0);
  if (portfolioValues.length === 0) {
    portfolioValues.push(totalInvested);
  }

  // Calculate returns
  const returns = dailyReturns(portfolioValues.length > 1 ? portfolioValues : [totalInvested, totalInvested]);

  // Win/loss from sell transactions
  const sells = transactions.filter((tx) => tx.type === 'sell');
  const wins = sells.filter((tx) => {
    const holding = holdings.find((h) => h.symbol === tx.symbol);
    return holding ? tx.price > holding.avgBuyPrice : false;
  });
  const winRate = sells.length > 0 ? (wins.length / sells.length) * 100 : 0;

  // Profit factor
  let grossProfit = 0;
  let grossLoss = 0;
  for (const tx of sells) {
    const holding = holdings.find((h) => h.symbol === tx.symbol);
    if (!holding) continue;
    const pnl = (tx.price - holding.avgBuyPrice) * tx.quantity - tx.fee;
    if (pnl > 0) grossProfit += pnl;
    else grossLoss += Math.abs(pnl);
  }
  const profitFactor = grossLoss > 0 ? grossProfit / grossLoss : grossProfit > 0 ? Infinity : 0;

  // Max drawdown
  const drawdown = calcMaxDrawdown(portfolioValues);

  // Monthly returns
  const monthlyMap = groupByMonth(transactions);
  const monthlyReturns: MonthlyReturn[] = Array.from(monthlyMap.entries())
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([month, returnAbs]) => ({
      month,
      returnAbs: Math.round(returnAbs * 100) / 100,
      returnPct: totalInvested > 0 ? Math.round((returnAbs / totalInvested) * 10000) / 100 : 0,
    }));

  // Total return
  const totalReturn = monthlyReturns.reduce((sum, m) => sum + m.returnAbs, 0);
  const totalReturnPct = totalInvested > 0 ? (totalReturn / totalInvested) * 100 : 0;

  // Benchmark comparison
  const benchmarks: BenchmarkComparison[] = [];
  for (const symbol of BENCHMARK_SYMBOLS) {
    const prices = await fetchBenchmarkPrices(symbol, startTime, now);
    if (prices.length >= 2) {
      const benchReturn = ((prices[prices.length - 1] - prices[0]) / prices[0]) * 100;
      benchmarks.push({
        symbol: symbol.replace('USDT', ''),
        portfolioReturnPct: Math.round(totalReturnPct * 100) / 100,
        benchmarkReturnPct: Math.round(benchReturn * 100) / 100,
        alpha: Math.round((totalReturnPct - benchReturn) * 100) / 100,
      });
    }
  }

  return {
    period,
    totalReturn: Math.round(totalReturn * 100) / 100,
    totalReturnPct: Math.round(totalReturnPct * 100) / 100,
    sharpeRatio: Math.round(calcSharpeRatio(returns) * 100) / 100,
    sortinoRatio: Math.round(calcSortinoRatio(returns) * 100) / 100,
    maxDrawdown: Math.round(drawdown.abs * 100) / 100,
    maxDrawdownPct: Math.round(drawdown.pct * 100) / 100,
    winRate: Math.round(winRate * 100) / 100,
    profitFactor: profitFactor === Infinity ? 999 : Math.round(profitFactor * 100) / 100,
    monthlyReturns,
    benchmarks,
  };
}
