import { QueryCommand, UpdateCommand, PutCommand, DeleteCommand } from '@aws-sdk/lib-dynamodb';
import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';
import { ddb } from '../lib/ddb';
import { config } from '../config';
import { logger } from '../logger';

// ── Types ────────────────────────────────────────────────────────────────────

export type TriggerType = 'priceAbove' | 'priceBelow' | 'percentChange' | 'timeSchedule';
export type ActionType = 'sendNotification' | 'addToWatchlist' | 'removeAlert';

export interface AutomationRule {
  userId: string;
  ruleId: string;
  name: string;
  enabled: boolean;
  trigger: {
    type: TriggerType;
    symbol?: string;
    value?: number;       // price threshold or percent change
    schedule?: string;    // cron-like for timeSchedule (e.g., "daily", "hourly")
  };
  action: {
    type: ActionType;
    payload?: Record<string, unknown>; // e.g., { symbol: "BTCUSDT" } for addToWatchlist
  };
  lastTriggeredAt?: string;
  createdAt: string;
}

const sns = new SNSClient({ region: config.region });
const RULE_COOLDOWN_MS = 60 * 60 * 1000; // 1 hour

// ── Fetch active rules ──────────────────────────────────────────────────────

export async function fetchEnabledRules(): Promise<AutomationRule[]> {
  const out = await ddb.send(
    new QueryCommand({
      TableName: config.ddb.automationRules,
      IndexName: 'enabled-index',
      KeyConditionExpression: '#enabled = :yes',
      ExpressionAttributeNames: { '#enabled': 'enabled' },
      ExpressionAttributeValues: { ':yes': 'true' },
    }),
  );
  return (out.Items ?? []) as AutomationRule[];
}

// ── Evaluate a single rule ──────────────────────────────────────────────────

function isRuleTriggered(
  rule: AutomationRule,
  prices: Map<string, number>,
  previousPrices: Map<string, number>,
): boolean {
  const { trigger } = rule;

  switch (trigger.type) {
    case 'priceAbove': {
      if (!trigger.symbol || trigger.value == null) return false;
      const price = prices.get(trigger.symbol);
      return price !== undefined && price >= trigger.value;
    }
    case 'priceBelow': {
      if (!trigger.symbol || trigger.value == null) return false;
      const price = prices.get(trigger.symbol);
      return price !== undefined && price <= trigger.value;
    }
    case 'percentChange': {
      if (!trigger.symbol || trigger.value == null) return false;
      const current = prices.get(trigger.symbol);
      const previous = previousPrices.get(trigger.symbol);
      if (current === undefined || previous === undefined || previous === 0) return false;
      const changePct = Math.abs(((current - previous) / previous) * 100);
      return changePct >= Math.abs(trigger.value);
    }
    case 'timeSchedule': {
      // Time-based triggers check if enough time has passed since last trigger
      if (!trigger.schedule) return false;
      const lastTriggered = rule.lastTriggeredAt
        ? new Date(rule.lastTriggeredAt).getTime()
        : 0;
      const interval = trigger.schedule === 'hourly'
        ? 60 * 60 * 1000
        : 24 * 60 * 60 * 1000; // default daily
      return Date.now() - lastTriggered >= interval;
    }
    default:
      return false;
  }
}

function isInCooldown(lastTriggeredAt?: string): boolean {
  if (!lastTriggeredAt) return false;
  const last = new Date(lastTriggeredAt).getTime();
  return Date.now() - last < RULE_COOLDOWN_MS;
}

// ── Execute actions ─────────────────────────────────────────────────────────

async function executeAction(rule: AutomationRule, prices: Map<string, number>): Promise<void> {
  const { action, trigger } = rule;

  switch (action.type) {
    case 'sendNotification': {
      const symbol = trigger.symbol ?? 'Portfolio';
      const price = trigger.symbol ? prices.get(trigger.symbol) : undefined;
      await sns.send(
        new PublishCommand({
          TopicArn: config.snsTopicArn,
          Message: JSON.stringify({
            userId: rule.userId,
            type: 'automation_triggered',
            ruleId: rule.ruleId,
            ruleName: rule.name,
            symbol,
            currentPrice: price,
          }),
          MessageAttributes: {
            userId: { DataType: 'String', StringValue: rule.userId },
            type: { DataType: 'String', StringValue: 'automation_triggered' },
          },
        }),
      );
      break;
    }
    case 'addToWatchlist': {
      const symbol = (action.payload?.symbol as string) ?? trigger.symbol;
      if (!symbol) break;
      await ddb.send(
        new PutCommand({
          TableName: config.ddb.watchlist,
          Item: {
            userId: rule.userId,
            symbol,
            addedAt: new Date().toISOString(),
            sortOrder: 999,
          },
        }),
      );
      break;
    }
    case 'removeAlert': {
      const alertId = action.payload?.alertId as string | undefined;
      if (!alertId) break;
      await ddb.send(
        new DeleteCommand({
          TableName: config.ddb.alerts,
          Key: { userId: rule.userId, alertId },
        }),
      );
      break;
    }
  }
}

// ── Mark rule as triggered ──────────────────────────────────────────────────

async function markRuleTriggered(rule: AutomationRule): Promise<void> {
  await ddb.send(
    new UpdateCommand({
      TableName: config.ddb.automationRules,
      Key: { userId: rule.userId, ruleId: rule.ruleId },
      UpdateExpression: 'SET lastTriggeredAt = :now',
      ExpressionAttributeValues: { ':now': new Date().toISOString() },
    }),
  );
}

// ── Main evaluator ──────────────────────────────────────────────────────────

export async function evaluateAutomationRules(
  prices: Map<string, number>,
  previousPrices: Map<string, number> = new Map(),
): Promise<number> {
  let rules: AutomationRule[];
  try {
    rules = await fetchEnabledRules();
  } catch (err) {
    logger.error('failed to fetch automation rules', {
      error: err instanceof Error ? err.message : String(err),
    });
    return 0;
  }

  if (rules.length === 0) return 0;

  let triggered = 0;
  for (const rule of rules) {
    if (isInCooldown(rule.lastTriggeredAt)) continue;
    if (!isRuleTriggered(rule, prices, previousPrices)) continue;

    try {
      await executeAction(rule, prices);
      await markRuleTriggered(rule);
      triggered++;
      logger.info('automation rule triggered', {
        ruleId: rule.ruleId,
        userId: rule.userId,
        name: rule.name,
        triggerType: rule.trigger.type,
        actionType: rule.action.type,
      });
    } catch (err) {
      logger.error('failed to execute automation rule', {
        ruleId: rule.ruleId,
        error: err instanceof Error ? err.message : String(err),
      });
    }
  }

  return triggered;
}
