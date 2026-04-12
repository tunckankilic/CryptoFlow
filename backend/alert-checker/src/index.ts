import type { ScheduledHandler } from 'aws-lambda';
import { QueryCommand } from '@aws-sdk/lib-dynamodb';
import { ddb } from './lib/ddb';
import { config } from './config';
import { fetchAllPrices } from './lib/binance';
import { isTriggered, type EvaluatableAlert } from './services/alert-evaluator';
import { markTriggered, notifyUser, isInCooldown } from './services/notifier';
import { detectWhaleActivity } from './services/whale-detector';
import { checkFundingRates } from './services/funding-rate-monitor';
import { checkSentimentShift } from './services/sentiment-monitor';
import { evaluateAutomationRules } from './services/automation-evaluator';
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

  // ── Smart Notifications (best-effort, failures don't block) ──
  try {
    const watchedSymbols = [...new Set(alerts.map((a) => a.symbol))];

    const [whaleAlerts, fundingAlerts, sentimentAlert] = await Promise.all([
      detectWhaleActivity(watchedSymbols).catch(() => []),
      checkFundingRates(watchedSymbols).catch(() => []),
      checkSentimentShift().catch(() => null),
    ]);

    if (whaleAlerts.length > 0) {
      logger.info('whale activity detected', { count: whaleAlerts.length });
    }
    if (fundingAlerts.length > 0) {
      logger.info('extreme funding rates', { count: fundingAlerts.length });
    }
    if (sentimentAlert) {
      logger.info('sentiment shift detected', {
        change: sentimentAlert.change,
        classification: sentimentAlert.classification,
      });
    }
    // TODO: Send smart notifications to subscribed users via SNS
  } catch (err) {
    logger.error('smart notifications check failed', {
      error: err instanceof Error ? err.message : String(err),
    });
  }

  // ── Automation Rules (best-effort) ──
  try {
    const automationTriggered = await evaluateAutomationRules(prices);
    if (automationTriggered > 0) {
      logger.info('automation rules triggered', { count: automationTriggered });
    }
  } catch (err) {
    logger.error('automation rules check failed', {
      error: err instanceof Error ? err.message : String(err),
    });
  }
};
