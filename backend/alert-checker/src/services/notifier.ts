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

export async function publishSns(alert: EvaluatableAlert, currentPrice: number): Promise<void> {
  await sns.send(
    new PublishCommand({
      TopicArn: config.snsTopicArn,
      Message: JSON.stringify({
        userId: alert.userId,
        type: 'alert_triggered',
        alertId: alert.alertId,
        symbol: alert.symbol,
        currentPrice,
      }),
      MessageAttributes: {
        userId: { DataType: 'String', StringValue: alert.userId },
        type: { DataType: 'String', StringValue: 'alert_triggered' },
      },
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
  await Promise.all([publishSns(alert, currentPrice), pushToWebSockets(alert, currentPrice)]);
}
