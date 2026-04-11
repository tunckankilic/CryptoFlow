import { listHoldings } from './portfolio.service';
import { listItems as listWatchlist } from './watchlist.service';

export interface PortfolioSummaryWidget {
  totalCost: number;
  topHoldings: Array<{ symbol: string; quantity: number; cost: number }>;
  generatedAt: string;
}

export async function getPortfolioSummaryWidget(
  userId: string,
): Promise<PortfolioSummaryWidget> {
  const holdings = await listHoldings(userId);
  const enriched = holdings.map((h) => ({
    symbol: h.symbol,
    quantity: h.quantity,
    cost: h.quantity * h.avgBuyPrice,
  }));
  const totalCost = enriched.reduce((s, h) => s + h.cost, 0);
  const topHoldings = enriched.sort((a, b) => b.cost - a.cost).slice(0, 3);
  return {
    totalCost,
    topHoldings,
    generatedAt: new Date().toISOString(),
  };
}

export interface WatchlistSummaryWidget {
  symbols: string[];
  generatedAt: string;
}

export async function getWatchlistSummaryWidget(
  userId: string,
): Promise<WatchlistSummaryWidget> {
  const items = await listWatchlist(userId);
  return {
    symbols: items.map((i) => i.symbol),
    generatedAt: new Date().toISOString(),
  };
}
