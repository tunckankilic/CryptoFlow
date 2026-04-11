import {
  PutCommand,
  DeleteCommand,
  GetCommand,
  UpdateCommand,
} from '@aws-sdk/lib-dynamodb';
import { ddb } from '../lib/ddb';
import { config } from '../config';
import { ValidationError } from '../errors';
import { logger } from '../logger';
import type {
  DeviceToken,
  NotificationPreferences,
  Platform,
} from '../models/notification';

const DEVICE_TTL_DAYS = 60;

export interface RegisterDeviceInput {
  deviceId: string;
  token: string;
  platform: Platform;
}

export async function registerDevice(
  userId: string,
  input: RegisterDeviceInput,
): Promise<DeviceToken> {
  if (!input.deviceId || !input.token || !input.platform) {
    throw new ValidationError('deviceId, token and platform are required');
  }
  if (input.platform !== 'ios' && input.platform !== 'android') {
    throw new ValidationError('platform must be ios or android');
  }
  const now = new Date();
  const expiresAt = Math.floor(now.getTime() / 1000) + DEVICE_TTL_DAYS * 86400;

  // SNS Platform Application stub: when the env var is unset (Faz 2 baseline),
  // we skip CreatePlatformEndpoint. Real APNs/FCM wiring is a manual step.
  const platformAppArn =
    input.platform === 'ios'
      ? config.snsApplePlatformAppArn
      : config.snsGooglePlatformAppArn;
  if (!platformAppArn) {
    logger.info('SNS platform app not configured — storing device token without endpoint', {
      userId,
      platform: input.platform,
    });
  }
  // TODO: when platformAppArn is set, call CreatePlatformEndpoint and store endpointArn

  const item: DeviceToken = {
    userId,
    deviceId: input.deviceId,
    token: input.token,
    platform: input.platform,
    createdAt: now.toISOString(),
    expiresAt,
  };
  await ddb.send(new PutCommand({ TableName: config.ddb.deviceTokens, Item: item }));
  return item;
}

export async function unregisterDevice(userId: string, deviceId: string): Promise<void> {
  if (!deviceId) throw new ValidationError('deviceId is required');
  await ddb.send(
    new DeleteCommand({
      TableName: config.ddb.deviceTokens,
      Key: { userId, deviceId },
    }),
  );
}

const DEFAULT_PREFS: NotificationPreferences = {
  priceAlerts: true,
  portfolioAlerts: true,
  newsAlerts: false,
  marketUpdates: false,
  soundEnabled: true,
  vibrationEnabled: true,
};

export async function getPreferences(userId: string): Promise<NotificationPreferences> {
  const out = await ddb.send(
    new GetCommand({
      TableName: config.ddb.userSettings,
      Key: { userId },
    }),
  );
  const item = out.Item as { notificationPreferences?: NotificationPreferences } | undefined;
  return { ...DEFAULT_PREFS, ...(item?.notificationPreferences ?? {}) };
}

export async function updatePreferences(
  userId: string,
  prefs: Partial<NotificationPreferences>,
): Promise<NotificationPreferences> {
  const merged: NotificationPreferences = { ...(await getPreferences(userId)), ...prefs };
  await ddb.send(
    new UpdateCommand({
      TableName: config.ddb.userSettings,
      Key: { userId },
      UpdateExpression: 'SET notificationPreferences = :p, updatedAt = :u',
      ExpressionAttributeValues: {
        ':p': merged,
        ':u': new Date().toISOString(),
      },
    }),
  );
  return merged;
}
