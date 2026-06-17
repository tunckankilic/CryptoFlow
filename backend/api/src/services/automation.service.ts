import { PutCommand, QueryCommand, UpdateCommand, DeleteCommand } from '@aws-sdk/lib-dynamodb';
import { ulid } from 'ulid';
import { ddb } from '../lib/ddb';
import { config } from '../config';
import { NotFoundError, ValidationError } from '../errors';

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
    value?: number;
    schedule?: string;
  };
  action: {
    type: ActionType;
    payload?: Record<string, unknown>;
  };
  lastTriggeredAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateRuleInput {
  name: string;
  trigger: {
    type: TriggerType;
    symbol?: string;
    value?: number;
    schedule?: string;
  };
  action: {
    type: ActionType;
    payload?: Record<string, unknown>;
  };
}

const VALID_TRIGGERS: TriggerType[] = ['priceAbove', 'priceBelow', 'percentChange', 'timeSchedule'];
const VALID_ACTIONS: ActionType[] = ['sendNotification', 'addToWatchlist', 'removeAlert'];

// ── CRUD ─────────────────────────────────────────────────────────────────────

export async function createRule(userId: string, input: CreateRuleInput): Promise<AutomationRule> {
  if (!input.name || !input.trigger?.type || !input.action?.type) {
    throw new ValidationError('name, trigger.type, and action.type are required');
  }
  if (!VALID_TRIGGERS.includes(input.trigger.type)) {
    throw new ValidationError(`Invalid trigger type. Valid: ${VALID_TRIGGERS.join(', ')}`);
  }
  if (!VALID_ACTIONS.includes(input.action.type)) {
    throw new ValidationError(`Invalid action type. Valid: ${VALID_ACTIONS.join(', ')}`);
  }

  const now = new Date().toISOString();
  const rule: AutomationRule = {
    userId,
    ruleId: `RULE-${ulid()}`,
    name: input.name,
    enabled: true,
    trigger: input.trigger,
    action: input.action,
    createdAt: now,
    updatedAt: now,
  };

  // Store `enabled` as string for GSI key
  await ddb.send(
    new PutCommand({
      TableName: config.ddb.automationRules,
      Item: { ...rule, enabled: rule.enabled ? 'true' : 'false' },
    }),
  );

  return rule;
}

export async function listRules(userId: string): Promise<AutomationRule[]> {
  const out = await ddb.send(
    new QueryCommand({
      TableName: config.ddb.automationRules,
      KeyConditionExpression: 'userId = :uid',
      ExpressionAttributeValues: { ':uid': userId },
    }),
  );
  return (out.Items ?? []).map((item) => ({
    ...item,
    enabled: item.enabled === 'true' || item.enabled === true,
  })) as AutomationRule[];
}

export async function toggleRule(userId: string, ruleId: string, enabled: boolean): Promise<void> {
  const result = await ddb.send(
    new UpdateCommand({
      TableName: config.ddb.automationRules,
      Key: { userId, ruleId },
      UpdateExpression: 'SET #enabled = :enabled, updatedAt = :now',
      ExpressionAttributeNames: { '#enabled': 'enabled' },
      ExpressionAttributeValues: {
        ':enabled': enabled ? 'true' : 'false',
        ':now': new Date().toISOString(),
      },
      ConditionExpression: 'attribute_exists(ruleId)',
      ReturnValues: 'NONE',
    }),
  );
}

export async function deleteRule(userId: string, ruleId: string): Promise<void> {
  await ddb.send(
    new DeleteCommand({
      TableName: config.ddb.automationRules,
      Key: { userId, ruleId },
    }),
  );
}
