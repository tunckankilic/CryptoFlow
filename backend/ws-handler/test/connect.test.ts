import { describe, it, expect, vi, beforeEach } from 'vitest';
import { mockClient } from 'aws-sdk-client-mock';
import { DynamoDBDocumentClient, PutCommand, DeleteCommand } from '@aws-sdk/lib-dynamodb';
const { verifyMock } = vi.hoisted(() => ({ verifyMock: vi.fn() }));
vi.mock('aws-jwt-verify', () => ({
  CognitoJwtVerifier: { create: () => ({ verify: verifyMock }) },
}));

import { onConnect } from '../src/handlers/connect';
import { onDisconnect } from '../src/handlers/disconnect';

const ddbMock = mockClient(DynamoDBDocumentClient);

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function makeEvent(overrides: Record<string, unknown> = {}): any {
  return {
    requestContext: {
      connectionId: 'conn-1',
      routeKey: '$connect',
      eventType: 'CONNECT',
      messageDirection: 'IN',
      connectedAt: 0,
      requestId: 'r',
      requestTime: '',
      requestTimeEpoch: 0,
      apiId: 'api',
      domainName: 'd',
      stage: 'dev',
      extendedRequestId: 'e',
    },
    queryStringParameters: { token: 'tok' },
    isBase64Encoded: false,
    ...overrides,
  };
}

describe('ws onConnect', () => {
  beforeEach(() => {
    ddbMock.reset();
    verifyMock.mockReset();
  });

  it('rejects when token is missing', async () => {
    const res = await onConnect(makeEvent({ queryStringParameters: undefined }));
    expect((res as { statusCode: number }).statusCode).toBe(401);
  });

  it('rejects when verifier throws', async () => {
    verifyMock.mockRejectedValueOnce(new Error('bad'));
    const res = await onConnect(makeEvent());
    expect((res as { statusCode: number }).statusCode).toBe(401);
  });

  it('writes a connection row when token is valid', async () => {
    verifyMock.mockResolvedValueOnce({ sub: 'user-1' });
    ddbMock.on(PutCommand).resolves({});
    const res = await onConnect(makeEvent());
    expect((res as { statusCode: number }).statusCode).toBe(200);
    const calls = ddbMock.commandCalls(PutCommand);
    expect(calls.length).toBe(1);
    const item = calls[0]!.args[0].input.Item as Record<string, unknown>;
    expect(item.userId).toBe('user-1');
    expect(item.connectionId).toBe('conn-1');
    expect(typeof item.expiresAt).toBe('number');
  });
});

describe('ws onDisconnect', () => {
  beforeEach(() => ddbMock.reset());

  it('issues a delete by connectionId', async () => {
    ddbMock.on(DeleteCommand).resolves({});
    const res = await onDisconnect(
      makeEvent({
        requestContext: {
          ...makeEvent().requestContext,
          routeKey: '$disconnect',
          eventType: 'DISCONNECT',
        },
      }),
    );
    expect((res as { statusCode: number }).statusCode).toBe(200);
    expect(ddbMock.commandCalls(DeleteCommand).length).toBe(1);
  });
});
