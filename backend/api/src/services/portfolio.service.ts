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
import type {
  Holding,
  CreateHoldingInput,
  UpdateHoldingInput,
  Transaction,
  CreateTransactionInput,
  PortfolioSummary,
} from '../models/portfolio';

// ---------- Holdings ----------

export async function createHolding(
  userId: string,
  input: CreateHoldingInput,
): Promise<Holding> {
  if (!input.symbol || input.quantity <= 0) {
    throw new ValidationError('symbol and positive quantity are required');
  }
  const now = new Date().toISOString();
  const holding: Holding = {
    userId,
    holdingId: ulid(),
    symbol: input.symbol,
    baseAsset: input.baseAsset,
    quantity: input.quantity,
    avgBuyPrice: input.avgBuyPrice,
    firstBuyDate: input.firstBuyDate,
    notes: input.notes,
    createdAt: now,
    updatedAt: now,
  };
  await ddb.send(
    new PutCommand({
      TableName: config.ddb.holdings,
      Item: holding,
    }),
  );
  return holding;
}

export async function listHoldings(userId: string): Promise<Holding[]> {
  const out = await ddb.send(
    new QueryCommand({
      TableName: config.ddb.holdings,
      KeyConditionExpression: 'userId = :uid',
      ExpressionAttributeValues: { ':uid': userId },
    }),
  );
  return (out.Items ?? []) as Holding[];
}

export async function updateHolding(
  userId: string,
  holdingId: string,
  input: UpdateHoldingInput,
): Promise<Holding> {
  const sets: string[] = ['#updatedAt = :updatedAt'];
  const names: Record<string, string> = { '#updatedAt': 'updatedAt' };
  const values: Record<string, unknown> = { ':updatedAt': new Date().toISOString() };

  for (const [k, v] of Object.entries(input)) {
    if (v === undefined) continue;
    sets.push(`#${k} = :${k}`);
    names[`#${k}`] = k;
    values[`:${k}`] = v;
  }

  if (sets.length === 1) {
    throw new ValidationError('No updatable fields provided');
  }

  const out = await ddb.send(
    new UpdateCommand({
      TableName: config.ddb.holdings,
      Key: { userId, holdingId },
      UpdateExpression: `SET ${sets.join(', ')}`,
      ExpressionAttributeNames: names,
      ExpressionAttributeValues: values,
      ConditionExpression: 'attribute_exists(holdingId)',
      ReturnValues: 'ALL_NEW',
    }),
  );
  return out.Attributes as Holding;
}

export async function deleteHolding(userId: string, holdingId: string): Promise<void> {
  const existing = await ddb.send(
    new GetCommand({
      TableName: config.ddb.holdings,
      Key: { userId, holdingId },
    }),
  );
  if (!existing.Item) throw new NotFoundError('Holding not found');
  await ddb.send(
    new DeleteCommand({
      TableName: config.ddb.holdings,
      Key: { userId, holdingId },
    }),
  );
}

// ---------- Transactions ----------

export async function createTransaction(
  userId: string,
  input: CreateTransactionInput,
): Promise<Transaction> {
  if (!input.symbol || input.quantity <= 0 || input.price <= 0) {
    throw new ValidationError('symbol, positive quantity and price are required');
  }
  if (input.type !== 'buy' && input.type !== 'sell') {
    throw new ValidationError('type must be buy or sell');
  }
  const tx: Transaction = {
    userId,
    transactionId: ulid(),
    symbol: input.symbol,
    type: input.type,
    quantity: input.quantity,
    price: input.price,
    fee: input.fee,
    feeAsset: input.feeAsset,
    timestamp: input.timestamp,
    note: input.note,
    createdAt: new Date().toISOString(),
  };
  await ddb.send(
    new PutCommand({
      TableName: config.ddb.transactions,
      Item: tx,
    }),
  );
  return tx;
}

export async function listTransactions(userId: string): Promise<Transaction[]> {
  const out = await ddb.send(
    new QueryCommand({
      TableName: config.ddb.transactions,
      KeyConditionExpression: 'userId = :uid',
      ExpressionAttributeValues: { ':uid': userId },
    }),
  );
  return (out.Items ?? []) as Transaction[];
}

// ---------- Summary ----------

export async function buildSummary(userId: string): Promise<PortfolioSummary> {
  const holdings = await listHoldings(userId);
  const items = holdings.map((h) => ({
    symbol: h.symbol,
    quantity: h.quantity,
    avgBuyPrice: h.avgBuyPrice,
    cost: h.quantity * h.avgBuyPrice,
  }));
  const totalCost = items.reduce((sum, h) => sum + h.cost, 0);
  return {
    totalCost,
    holdingCount: items.length,
    holdings: items,
  };
}
