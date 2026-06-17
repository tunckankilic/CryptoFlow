export type AlertType = 'above' | 'below' | 'percentUp' | 'percentDown';
export type AlertStatus = 'active' | 'triggered' | 'disabled';

export interface Alert {
  userId: string;
  alertId: string;
  symbol: string;
  type: AlertType;
  targetPrice?: number;
  percentChange?: number;
  basePrice?: number;
  status: AlertStatus;
  isTriggered: boolean;
  repeatEnabled: boolean;
  note?: string;
  createdAt: string;
  triggeredAt?: string;
  lastTriggerDate?: string;
}

export type CreateAlertInput = Omit<
  Alert,
  'userId' | 'alertId' | 'status' | 'isTriggered' | 'createdAt' | 'triggeredAt' | 'lastTriggerDate'
>;

export type UpdateAlertInput = Partial<
  Pick<
    Alert,
    | 'symbol'
    | 'type'
    | 'targetPrice'
    | 'percentChange'
    | 'basePrice'
    | 'status'
    | 'repeatEnabled'
    | 'note'
  >
>;
