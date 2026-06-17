import {
  QueryCommand,
  UpdateCommand,
  DeleteCommand,
} from '@aws-sdk/lib-dynamodb';
import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';
import { ddb } from '../lib/ddb';
import { config } from '../config';
import { postToConnection } from '../lib/ws';
import { logger } from '../logger';
import type { EvaluatableAlert } from './alert-evaluator';

const sns = new SNSClient({ region: config.region });

const REPEAT_COOLDOWN_MS = 60 * 60 * 1000; // 1 hour

interface DeviceRecord {
  userId: string;
  deviceId: string;
  endpointArn?: string;
}

export async function markTriggered(
  alert: EvaluatableAlert & { repeatEnabled?: boolean; lastTriggerDate?: string },
  currentPrice: number,
): Promise<void> {
  const now = new Date();
  const isRepeat = alert.repeatEnabled === true;
  await ddb.send(
    new UpdateCommand({
      TableName: config.ddb.alerts,
      Key: { userId: alert.userId, alertId: alert.alertId },
      UpdateExpression: isRepeat
        ? 'SET #status = :active, lastTriggerDate = :now, lastPrice = :p'
        : 'SET #status = :triggered, isTriggered = :t, triggeredAt = :now, lastPrice = :p',
      ExpressionAttributeNames: { '#status': 'status' },
      ExpressionAttributeValues: isRepeat
        ? { ':active': 'active', ':now': now.toISOString(), ':p': currentPrice }
        : {
            ':triggered': 'triggered',
            ':t': true,
            ':now': now.toISOString(),
            ':p': currentPrice,
          },
    }),
  );
}

export function isInCooldown(lastTriggerDate?: string): boolean {
  if (!lastTriggerDate) return false;
  const last = new Date(lastTriggerDate).getTime();
  if (!Number.isFinite(last)) return false;
  return Date.now() - last < REPEAT_COOLDOWN_MS;
}

async function getUserDevices(userId: string): Promise<DeviceRecord[]> {
  const out = await ddb.send(
    new QueryCommand({
      TableName: config.ddb.deviceTokens,
      KeyConditionExpression: 'userId = :uid',
      ExpressionAttributeValues: { ':uid': userId },
    }),
  );
  return (out.Items ?? []) as DeviceRecord[];
}

async function deleteDeviceRecord(userId: string, deviceId: string): Promise<void> {
  await ddb.send(
    new DeleteCommand({
      TableName: config.ddb.deviceTokens,
      Key: { userId, deviceId },
    }),
  );
}

function isEndpointDisabledError(err: unknown): boolean {
  if (typeof err !== 'object' || err === null) return false;
  const e = err as { name?: string; message?: string };
  return (
    e.name === 'EndpointDisabledException' ||
    /endpoint.*disabled/i.test(e.message ?? '')
  );
}

export async function publishToDevices(
  alert: EvaluatableAlert,
  currentPrice: number,
): Promise<void> {
  const devices = await getUserDevices(alert.userId);
  if (devices.length === 0) return;

  const title = `${alert.symbol} alert`;
  const body = `${alert.symbol} reached ${currentPrice}`;
  const customData = {
    type: 'alert_triggered',
    alertId: alert.alertId,
    symbol: alert.symbol,
    currentPrice,
  };
  const apsPayload = {
    aps: { alert: { title, body }, sound: 'default' },
    data: customData,
  };
  const messageJson = JSON.stringify(apsPayload);
  // SNS expects platform key matching the platform application's actual
  // platform — we send both keys so the same alert-checker works against
  // dev (APNS_SANDBOX) and prod (APNS) without extra configuration.
  const Message = JSON.stringify({
    APNS: messageJson,
    APNS_SANDBOX: messageJson,
  });

  await Promise.all(
    devices.map(async (device) => {
      if (!device.endpointArn) {
        logger.warn('device record has no endpointArn — skipping', {
          userId: device.userId,
          deviceId: device.deviceId,
        });
        return;
      }
      try {
        await sns.send(
          new PublishCommand({
            TargetArn: device.endpointArn,
            MessageStructure: 'json',
            Message,
          }),
        );
      } catch (err) {
        if (isEndpointDisabledError(err)) {
          logger.info('removing disabled APNs endpoint', {
            userId: device.userId,
            deviceId: device.deviceId,
            endpointArn: device.endpointArn,
          });
          await deleteDeviceRecord(device.userId, device.deviceId);
          return;
        }
        logger.error('SNS publish to endpoint failed', {
          userId: device.userId,
          endpointArn: device.endpointArn,
          error: err instanceof Error ? err.message : String(err),
        });
      }
    }),
  );
}

export async function pushToWebSockets(
  alert: EvaluatableAlert,
  currentPrice: number,
): Promise<void> {
  const out = await ddb.send(
    new QueryCommand({
      TableName: config.ddb.wsConnections,
      IndexName: 'userId-index',
      KeyConditionExpression: 'userId = :uid',
      ExpressionAttributeValues: { ':uid': alert.userId },
    }),
  );
  const conns = (out.Items ?? []) as Array<{ connectionId: string }>;
  if (conns.length === 0) return;

  const payload = {
    type: 'alert_triggered',
    alertId: alert.alertId,
    symbol: alert.symbol,
    currentPrice,
    timestamp: new Date().toISOString(),
  };

  await Promise.all(
    conns.map(async (c) => {
      const alive = await postToConnection(c.connectionId, payload);
      if (!alive) {
        // Stale connection — clean up.
        await ddb.send(
          new DeleteCommand({
            TableName: config.ddb.wsConnections,
            Key: { connectionId: c.connectionId },
          }),
        );
        logger.info('cleaned up stale ws connection', { connectionId: c.connectionId });
      }
    }),
  );
}

export async function notifyUser(
  alert: EvaluatableAlert,
  currentPrice: number,
): Promise<void> {
  await Promise.all([publishToDevices(alert, currentPrice), pushToWebSockets(alert, currentPrice)]);
}
