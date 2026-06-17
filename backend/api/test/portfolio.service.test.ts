import { describe, it, expect, beforeEach } from 'vitest';
import { mockClient } from 'aws-sdk-client-mock';
import {
  DynamoDBDocumentClient,
  PutCommand,
  QueryCommand,
  GetCommand,
  DeleteCommand,
} from '@aws-sdk/lib-dynamodb';

import {
  createHolding,
  listHoldings,
  deleteHolding,
  buildSummary,
} from '../src/services/portfolio.service';
import { ValidationError, NotFoundError } from '../src/errors';

const ddbMock = mockClient(DynamoDBDocumentClient);

describe('portfolio.service', () => {
  beforeEach(() => {
    ddbMock.reset();
  });

  describe('createHolding', () => {
    it('writes a holding with a generated ulid', async () => {
      ddbMock.on(PutCommand).resolves({});
      const h = await createHolding('user-1', {
        symbol: 'BTCUSDT',
        baseAsset: 'BTC',
        quantity: 0.5,
        avgBuyPrice: 30000,
        firstBuyDate: '2025-01-01T00:00:00.000Z',
      });
      expect(h.userId).toBe('user-1');
      expect(h.holdingId).toMatch(/^[0-9A-HJKMNP-TV-Z]{26}$/); // ulid charset
      expect(h.symbol).toBe('BTCUSDT');
      const calls = ddbMock.commandCalls(PutCommand);
      expect(calls.length).toBe(1);
    });

    it('rejects non-positive quantity', async () => {
      await expect(
        createHolding('user-1', {
          symbol: 'BTCUSDT',
          baseAsset: 'BTC',
          quantity: 0,
          avgBuyPrice: 30000,
          firstBuyDate: '2025-01-01',
        }),
      ).rejects.toBeInstanceOf(ValidationError);
    });
  });

  describe('listHoldings', () => {
    it('queries by userId and returns items', async () => {
      ddbMock.on(QueryCommand).resolves({
        Items: [
          {
            userId: 'user-1',
            holdingId: 'h1',
            symbol: 'BTCUSDT',
            baseAsset: 'BTC',
            quantity: 1,
            avgBuyPrice: 100,
            firstBuyDate: '2025-01-01',
            createdAt: '2025-01-01',
            updatedAt: '2025-01-01',
          },
        ],
      });
      const items = await listHoldings('user-1');
      expect(items).toHaveLength(1);
      expect(items[0]?.symbol).toBe('BTCUSDT');
    });
  });

  describe('deleteHolding', () => {
    it('throws NotFoundError when item is missing', async () => {
      ddbMock.on(GetCommand).resolves({});
      await expect(deleteHolding('user-1', 'missing')).rejects.toBeInstanceOf(NotFoundError);
    });

    it('deletes when item exists', async () => {
      ddbMock.on(GetCommand).resolves({ Item: { userId: 'user-1', holdingId: 'h1' } });
      ddbMock.on(DeleteCommand).resolves({});
      await deleteHolding('user-1', 'h1');
      expect(ddbMock.commandCalls(DeleteCommand).length).toBe(1);
    });
  });

  describe('buildSummary', () => {
    it('aggregates cost and counts holdings', async () => {
      ddbMock.on(QueryCommand).resolves({
        Items: [
          { userId: 'u', holdingId: '1', symbol: 'BTCUSDT', quantity: 2, avgBuyPrice: 100 },
          { userId: 'u', holdingId: '2', symbol: 'ETHUSDT', quantity: 5, avgBuyPrice: 50 },
        ],
      });
      const s = await buildSummary('u');
      expect(s.holdingCount).toBe(2);
      expect(s.totalCost).toBe(450); // 200 + 250
      expect(s.holdings).toHaveLength(2);
    });

    it('returns zeros for empty portfolios', async () => {
      ddbMock.on(QueryCommand).resolves({ Items: [] });
      const s = await buildSummary('u');
      expect(s).toEqual({ totalCost: 0, holdingCount: 0, holdings: [] });
    });
  });
});
