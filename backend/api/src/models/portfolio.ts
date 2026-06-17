export interface Holding {
  userId: string;
  holdingId: string;
  symbol: string;
  baseAsset: string;
  quantity: number;
  avgBuyPrice: number;
  firstBuyDate: string;
  notes?: string;
  createdAt: string;
  updatedAt: string;
}

export type CreateHoldingInput = Omit<
  Holding,
  'userId' | 'holdingId' | 'createdAt' | 'updatedAt'
>;

export type UpdateHoldingInput = Partial<
  Pick<Holding, 'symbol' | 'baseAsset' | 'quantity' | 'avgBuyPrice' | 'firstBuyDate' | 'notes'>
>;

export type TxType = 'buy' | 'sell';

export interface Transaction {
  userId: string;
  transactionId: string;
  symbol: string;
  type: TxType;
  quantity: number;
  price: number;
  fee: number;
  feeAsset: string;
  timestamp: string;
  note?: string;
  createdAt: string;
}

export type CreateTransactionInput = Omit<
  Transaction,
  'userId' | 'transactionId' | 'createdAt'
>;

export interface PortfolioSummary {
  totalCost: number;
  holdingCount: number;
  holdings: Array<{
    symbol: string;
    quantity: number;
    avgBuyPrice: number;
    cost: number;
  }>;
}
