export interface WatchlistItem {
  userId: string;
  symbol: string;
  order: number;
  addedAt: string;
}

export interface ReorderInput {
  items: Array<{ symbol: string; order: number }>;
}
