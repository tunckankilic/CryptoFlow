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
  JournalEntry,
  CreateJournalInput,
  UpdateJournalInput,
  JournalStats,
} from '../models/journal';

export async function createEntry(
  userId: string,
  input: CreateJournalInput,
): Promise<JournalEntry> {
  if (!input.symbol || input.quantity <= 0) {
    throw new ValidationError('symbol and positive quantity are required');
  }
  const now = new Date().toISOString();
  const entry: JournalEntry = {
    ...input,
    userId,
    entryId: ulid(),
    createdAt: now,
    updatedAt: now,
  };
  await ddb.send(new PutCommand({ TableName: config.ddb.journal, Item: entry }));
  return entry;
}

export async function listEntries(userId: string): Promise<JournalEntry[]> {
  const out = await ddb.send(
    new QueryCommand({
      TableName: config.ddb.journal,
      KeyConditionExpression: 'userId = :uid',
      ExpressionAttributeValues: { ':uid': userId },
    }),
  );
  return (out.Items ?? []) as JournalEntry[];
}

export async function updateEntry(
  userId: string,
  entryId: string,
  input: UpdateJournalInput,
): Promise<JournalEntry> {
  const sets: string[] = ['#updatedAt = :updatedAt'];
  const names: Record<string, string> = { '#updatedAt': 'updatedAt' };
  const values: Record<string, unknown> = { ':updatedAt': new Date().toISOString() };

  for (const [k, v] of Object.entries(input)) {
    if (v === undefined) continue;
    sets.push(`#${k} = :${k}`);
    names[`#${k}`] = k;
    values[`:${k}`] = v;
  }
  if (sets.length === 1) throw new ValidationError('No updatable fields provided');

  const out = await ddb.send(
    new UpdateCommand({
      TableName: config.ddb.journal,
      Key: { userId, entryId },
      UpdateExpression: `SET ${sets.join(', ')}`,
      ExpressionAttributeNames: names,
      ExpressionAttributeValues: values,
      ConditionExpression: 'attribute_exists(entryId)',
      ReturnValues: 'ALL_NEW',
    }),
  );
  return out.Attributes as JournalEntry;
}

export async function deleteEntry(userId: string, entryId: string): Promise<void> {
  const existing = await ddb.send(
    new GetCommand({ TableName: config.ddb.journal, Key: { userId, entryId } }),
  );
  if (!existing.Item) throw new NotFoundError('Journal entry not found');
  await ddb.send(
    new DeleteCommand({ TableName: config.ddb.journal, Key: { userId, entryId } }),
  );
}

export async function computeStats(
  userId: string,
  period: 'weekly' | 'monthly' | 'all' = 'monthly',
): Promise<JournalStats> {
  const entries = await listEntries(userId);
  const cutoff = computeCutoff(period);
  const inWindow = cutoff
    ? entries.filter((e) => new Date(e.entryDate).getTime() >= cutoff)
    : entries;
  const closed = inWindow.filter((e) => e.exitDate && typeof e.pnl === 'number');
  const wins = closed.filter((e) => (e.pnl ?? 0) > 0).length;
  const totalPnl = closed.reduce((sum, e) => sum + (e.pnl ?? 0), 0);
  const best = closed.reduce((m, e) => Math.max(m, e.pnl ?? 0), -Infinity);
  const worst = closed.reduce((m, e) => Math.min(m, e.pnl ?? 0), Infinity);
  return {
    period,
    totalTrades: inWindow.length,
    closedTrades: closed.length,
    winRate: closed.length === 0 ? 0 : wins / closed.length,
    averagePnl: closed.length === 0 ? 0 : totalPnl / closed.length,
    totalPnl,
    bestTrade: best === -Infinity ? 0 : best,
    worstTrade: worst === Infinity ? 0 : worst,
  };
}

function computeCutoff(period: 'weekly' | 'monthly' | 'all'): number | null {
  if (period === 'all') return null;
  const now = Date.now();
  const days = period === 'weekly' ? 7 : 30;
  return now - days * 24 * 60 * 60 * 1000;
}
