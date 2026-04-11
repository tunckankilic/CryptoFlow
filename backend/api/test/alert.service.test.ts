import { describe, it, expect, beforeEach } from 'vitest';
import { mockClient } from 'aws-sdk-client-mock';
import {
  DynamoDBDocumentClient,
  PutCommand,
  QueryCommand,
} from '@aws-sdk/lib-dynamodb';

import { createAlert, listAlerts } from '../src/services/alert.service';
import { ValidationError } from '../src/errors';

const ddbMock = mockClient(DynamoDBDocumentClient);

describe('alert.service', () => {
  beforeEach(() => ddbMock.reset());

  it('rejects above-alert without targetPrice', async () => {
    await expect(
      createAlert('u', { symbol: 'BTCUSDT', type: 'above', repeatEnabled: false }),
    ).rejects.toBeInstanceOf(ValidationError);
  });

  it('rejects percentUp without basePrice + percentChange', async () => {
    await expect(
      createAlert('u', {
        symbol: 'BTCUSDT',
        type: 'percentUp',
        percentChange: 5,
        repeatEnabled: false,
      }),
    ).rejects.toBeInstanceOf(ValidationError);
  });

  it('creates a valid above alert', async () => {
    ddbMock.on(PutCommand).resolves({});
    const a = await createAlert('u', {
      symbol: 'BTCUSDT',
      type: 'above',
      targetPrice: 50000,
      repeatEnabled: false,
    });
    expect(a.status).toBe('active');
    expect(a.isTriggered).toBe(false);
    expect(a.alertId).toMatch(/^[0-9A-HJKMNP-TV-Z]{26}$/);
  });

  it('lists alerts via Query', async () => {
    ddbMock.on(QueryCommand).resolves({ Items: [{ alertId: '1' }, { alertId: '2' }] });
    const alerts = await listAlerts('u');
    expect(alerts).toHaveLength(2);
  });
});
