import {
  PutCommand,
  QueryCommand,
  DeleteCommand,
  TransactWriteCommand,
} from '@aws-sdk/lib-dynamodb';
import { ddb } from '../lib/ddb';
import { config } from '../config';
import { ValidationError } from '../errors';
import type { WatchlistItem, ReorderInput } from '../models/watchlist';

export async function addItem(
  userId: string,
  symbol: string,
  order = 0,
): Promise<WatchlistItem> {
  if (!symbol) throw new ValidationError('symbol is required');
  const item: WatchlistItem = {
    userId,
    symbol,
    order,
    addedAt: new Date().toISOString(),
  };
  await ddb.send(new PutCommand({ TableName: config.ddb.watchlist, Item: item }));
  return item;
}

export async function listItems(userId: string): Promise<WatchlistItem[]> {
  const out = await ddb.send(
    new QueryCommand({
      TableName: config.ddb.watchlist,
      KeyConditionExpression: 'userId = :uid',
      ExpressionAttributeValues: { ':uid': userId },
    }),
  );
  const items = (out.Items ?? []) as WatchlistItem[];
  return items.sort((a, b) => a.order - b.order);
}

export async function removeItem(userId: string, symbol: string): Promise<void> {
  await ddb.send(
    new DeleteCommand({
      TableName: config.ddb.watchlist,
      Key: { userId, symbol },
    }),
  );
}

export async function reorder(userId: string, input: ReorderInput): Promise<void> {
  if (!Array.isArray(input.items) || input.items.length === 0) {
    throw new ValidationError('items array required');
  }
  if (input.items.length > 25) {
    throw new ValidationError('Cannot reorder more than 25 items per request');
  }
  await ddb.send(
    new TransactWriteCommand({
      TransactItems: input.items.map((it) => ({
        Update: {
          TableName: config.ddb.watchlist,
          Key: { userId, symbol: it.symbol },
          UpdateExpression: 'SET #order = :order',
          ExpressionAttributeNames: { '#order': 'order' },
          ExpressionAttributeValues: { ':order': it.order },
        },
      })),
    }),
  );
}
