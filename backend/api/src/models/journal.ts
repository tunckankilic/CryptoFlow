export type JournalSide = 'long' | 'short';

export interface JournalEntry {
  userId: string;
  entryId: string;
  symbol: string;
  side: JournalSide;
  entryPrice: number;
  exitPrice?: number;
  quantity: number;
  pnl?: number;
  pnlPercentage?: number;
  riskRewardRatio?: number;
  strategy?: string;
  emotion?: string;
  notes?: string;
  tags?: string[];
  screenshotPath?: string;
  entryDate: string;
  exitDate?: string;
  createdAt: string;
  updatedAt: string;
}

export type CreateJournalInput = Omit<
  JournalEntry,
  'userId' | 'entryId' | 'createdAt' | 'updatedAt'
>;

export type UpdateJournalInput = Partial<
  Omit<JournalEntry, 'userId' | 'entryId' | 'createdAt' | 'updatedAt'>
>;

export interface JournalStats {
  period: string;
  totalTrades: number;
  closedTrades: number;
  winRate: number;
  averagePnl: number;
  totalPnl: number;
  bestTrade: number;
  worstTrade: number;
}
