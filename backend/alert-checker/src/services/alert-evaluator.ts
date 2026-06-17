export type AlertType = 'above' | 'below' | 'percentUp' | 'percentDown';

export interface EvaluatableAlert {
  alertId: string;
  userId: string;
  symbol: string;
  type: AlertType;
  targetPrice?: number;
  basePrice?: number;
  percentChange?: number;
}

/**
 * Pure function: returns true when the alert condition is met for the given
 * current price. Unknown alert types or missing thresholds return false.
 */
export function isTriggered(alert: EvaluatableAlert, currentPrice: number): boolean {
  if (!Number.isFinite(currentPrice)) return false;

  switch (alert.type) {
    case 'above':
      return alert.targetPrice !== undefined && currentPrice >= alert.targetPrice;
    case 'below':
      return alert.targetPrice !== undefined && currentPrice <= alert.targetPrice;
    case 'percentUp': {
      if (alert.basePrice === undefined || alert.percentChange === undefined) return false;
      const change = ((currentPrice - alert.basePrice) / alert.basePrice) * 100;
      return change >= alert.percentChange;
    }
    case 'percentDown': {
      if (alert.basePrice === undefined || alert.percentChange === undefined) return false;
      const change = ((currentPrice - alert.basePrice) / alert.basePrice) * 100;
      return change <= -alert.percentChange;
    }
    default:
      return false;
  }
}
