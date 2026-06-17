export type Platform = 'ios' | 'android';

export interface DeviceToken {
  userId: string;
  deviceId: string;
  token: string;
  platform: Platform;
  endpointArn?: string; // Set later when SNS Platform Application is configured
  createdAt: string;
  expiresAt: number; // unix seconds — DDB TTL
}

export interface NotificationPreferences {
  priceAlerts: boolean;
  portfolioAlerts: boolean;
  newsAlerts: boolean;
  marketUpdates: boolean;
  soundEnabled: boolean;
  vibrationEnabled: boolean;
}
