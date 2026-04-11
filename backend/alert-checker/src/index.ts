import type { ScheduledHandler } from 'aws-lambda';
import { QueryCommand } from '@aws-sdk/lib-dynamodb';
import { ddb } from './lib/ddb';
import { config } from './config';
import { fetchAllPrices } from './lib/binance';
import { isTriggered, type EvaluatableAlert } from './services/alert-evaluator';
import { markTriggered, notifyUser, isInCooldown } from './services/notifier';
import { logger } from './logger';

interface AlertRecord extends EvaluatableAlert {
  status: 'active' | 'triggered' | 'disabled';
  repeatEnabled?: boolean;
  lastTriggerDate?: string;
}

async function fetchActiveAlerts(): Promise<AlertRecord[]> {
  const out = await ddb.send(
    new QueryCommand({
      TableName: config.ddb.alerts,
      IndexName: 'status-index',
      KeyConditionExpression: '#status = :active',
      ExpressionAttributeNames: { '#status': 'status' },
      ExpressionAttributeValues: { ':active': 'active' },
    }),
  );
  return (out.Items ?? []) as AlertRecord[];
}

export const handler: ScheduledHandler = async () => {
  const alerts = await fetchActiveAlerts();
  if (alerts.length === 0) {
    logger.info('no active alerts');
    return;
  }

  let prices: Map<string, number>;
  try {
    prices = await fetchAllPrices();
  } catch (err) {
    logger.error('binance fetch failed', {
      error: err instanceof Error ? err.message : String(err),
    });
    return;
  }

  let triggeredCount = 0;
  for (const alert of alerts) {
    if (alert.repeatEnabled && isInCooldown(alert.lastTriggerDate)) continue;
    const price = prices.get(alert.symbol);
    if (price === undefined) continue;
    if (!isTriggered(alert, price)) continue;

    try {
      await markTriggered(alert, price);
      await notifyUser(alert, price);
      triggeredCount++;
      logger.info('alert triggered', {
        alertId: alert.alertId,
        userId: alert.userId,
        symbol: alert.symbol,
        currentPrice: price,
      });
    } catch (err) {
      logger.error('failed to process triggered alert', {
        alertId: alert.alertId,
        error: err instanceof Error ? err.message : String(err),
      });
    }
  }

  logger.info('alert checker done', {
    activeAlerts: alerts.length,
    triggered: triggeredCount,
  });
};
