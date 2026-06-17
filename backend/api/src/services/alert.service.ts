import {
  PutCommand,
  QueryCommand,
  UpdateCommand,
  DeleteCommand,
  GetCommand,
} from '@aws-sdk/lib-dynamodb';
import { ulid } from 'ulid';
import { ddb } from '../lib/ddb';
import { config } from '../config';
import { NotFoundError, ValidationError } from '../errors';
import type { Alert, CreateAlertInput, UpdateAlertInput } from '../models/alert';

const ALLOWED_TYPES = new Set(['above', 'below', 'percentUp', 'percentDown']);

export async function createAlert(
  userId: string,
  input: CreateAlertInput,
): Promise<Alert> {
  if (!input.symbol || !ALLOWED_TYPES.has(input.type)) {
    throw new ValidationError('symbol and valid type are required');
  }
  if ((input.type === 'above' || input.type === 'below') && input.targetPrice === undefined) {
    throw new ValidationError('targetPrice is required for above/below alerts');
  }
  if (
    (input.type === 'percentUp' || input.type === 'percentDown') &&
    (input.percentChange === undefined || input.basePrice === undefined)
  ) {
    throw new ValidationError(
      'percentChange and basePrice are required for percent alerts',
    );
  }

  const alert: Alert = {
    userId,
    alertId: ulid(),
    symbol: input.symbol,
    type: input.type,
    targetPrice: input.targetPrice,
    percentChange: input.percentChange,
    basePrice: input.basePrice,
    status: 'active',
    isTriggered: false,
    repeatEnabled: input.repeatEnabled ?? false,
    note: input.note,
    createdAt: new Date().toISOString(),
  };
  await ddb.send(new PutCommand({ TableName: config.ddb.alerts, Item: alert }));
  return alert;
}

export async function listAlerts(userId: string): Promise<Alert[]> {
  const out = await ddb.send(
    new QueryCommand({
      TableName: config.ddb.alerts,
      KeyConditionExpression: 'userId = :uid',
      ExpressionAttributeValues: { ':uid': userId },
    }),
  );
  return (out.Items ?? []) as Alert[];
}

export async function updateAlert(
  userId: string,
  alertId: string,
  input: UpdateAlertInput,
): Promise<Alert> {
  const sets: string[] = [];
  const names: Record<string, string> = {};
  const values: Record<string, unknown> = {};

  for (const [k, v] of Object.entries(input)) {
    if (v === undefined) continue;
    sets.push(`#${k} = :${k}`);
    names[`#${k}`] = k;
    values[`:${k}`] = v;
  }
  if (sets.length === 0) throw new ValidationError('No updatable fields provided');

  const out = await ddb.send(
    new UpdateCommand({
      TableName: config.ddb.alerts,
      Key: { userId, alertId },
      UpdateExpression: `SET ${sets.join(', ')}`,
      ExpressionAttributeNames: names,
      ExpressionAttributeValues: values,
      ConditionExpression: 'attribute_exists(alertId)',
      ReturnValues: 'ALL_NEW',
    }),
  );
  return out.Attributes as Alert;
}

export async function deleteAlert(userId: string, alertId: string): Promise<void> {
  const existing = await ddb.send(
    new GetCommand({ TableName: config.ddb.alerts, Key: { userId, alertId } }),
  );
  if (!existing.Item) throw new NotFoundError('Alert not found');
  await ddb.send(
    new DeleteCommand({ TableName: config.ddb.alerts, Key: { userId, alertId } }),
  );
}
