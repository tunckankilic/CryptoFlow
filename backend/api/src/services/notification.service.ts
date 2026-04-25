import {
  PutCommand,
  DeleteCommand,
  GetCommand,
  UpdateCommand,
} from '@aws-sdk/lib-dynamodb';
import {
  SNSClient,
  CreatePlatformEndpointCommand,
  SetEndpointAttributesCommand,
} from '@aws-sdk/client-sns';
import { ddb } from '../lib/ddb';
import { config } from '../config';
import { ValidationError } from '../errors';
import { logger } from '../logger';
import type {
  DeviceToken,
  NotificationPreferences,
  Platform,
} from '../models/notification';

const sns = new SNSClient({ region: config.region });

// AWS SNS returns InvalidParameter when the device token is already
// registered as an endpoint. The error message embeds the existing
// endpoint ARN — parse it so we can update + reuse instead of failing.
const EXISTING_ENDPOINT_RE = /Endpoint (arn:aws:sns:\S+) already exists/;

async function ensurePlatformEndpoint(
  platformAppArn: string,
  deviceToken: string,
  customUserData: string,
): Promise<string> {
  try {
    const out = await sns.send(
      new CreatePlatformEndpointCommand({
        PlatformApplicationArn: platformAppArn,
        Token: deviceToken,
        CustomUserData: customUserData,
      }),
    );
    if (!out.EndpointArn) {
      throw new Error('SNS CreatePlatformEndpoint returned no EndpointArn');
    }
    return out.EndpointArn;
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    const match = msg.match(EXISTING_ENDPOINT_RE);
    if (!match) throw err;
    const existingArn = match[1];
    // Re-enable the endpoint and refresh the token in case it changed.
    await sns.send(
      new SetEndpointAttributesCommand({
        EndpointArn: existingArn,
        Attributes: {
          Token: deviceToken,
          Enabled: 'true',
          CustomUserData: customUserData,
        },
      }),
    );
    return existingArn;
  }
}

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
  if (input.platform !== 'ios') {
    throw new ValidationError('platform must be ios');
  }
  const now = new Date();
  const expiresAt = Math.floor(now.getTime() / 1000) + DEVICE_TTL_DAYS * 86400;

  const endpointArn = await ensurePlatformEndpoint(
    config.snsApplePlatformAppArn,
    input.token,
    JSON.stringify({ userId, deviceId: input.deviceId }),
  );
  logger.info('registered APNs endpoint', { userId, deviceId: input.deviceId, endpointArn });

  const item: DeviceToken = {
    userId,
    deviceId: input.deviceId,
    token: input.token,
    platform: input.platform,
    endpointArn,
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
