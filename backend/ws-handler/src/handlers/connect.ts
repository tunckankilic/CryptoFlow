import type { APIGatewayProxyWebsocketEventV2 } from 'aws-lambda';
import { PutCommand } from '@aws-sdk/lib-dynamodb';
import { ddb } from '../lib/ddb';
import { config } from '../config';
import { verifyToken } from '../middleware/auth';
import { logger } from '../logger';

const CONNECTION_TTL_SECONDS = 7200; // 2 hours

// API Gateway includes queryStringParameters on the $connect upgrade event,
// but the upstream type definition in @types/aws-lambda only declares them on
// the authorizer event, so we widen here.
type ConnectEvent = APIGatewayProxyWebsocketEventV2 & {
  queryStringParameters?: Record<string, string | undefined>;
};

export async function onConnect(event: ConnectEvent) {
  const connectionId = event.requestContext.connectionId;
  const token = event.queryStringParameters?.token;

  let userId: string;
  try {
    const verified = await verifyToken(token);
    userId = verified.userId;
  } catch (err) {
    logger.warn('ws connect rejected', {
      connectionId,
      reason: err instanceof Error ? err.message : 'unknown',
    });
    return { statusCode: 401, body: 'Unauthorized' };
  }

  const now = Math.floor(Date.now() / 1000);
  await ddb.send(
    new PutCommand({
      TableName: config.ddb.wsConnections,
      Item: {
        connectionId,
        userId,
        connectedAt: new Date().toISOString(),
        expiresAt: now + CONNECTION_TTL_SECONDS,
      },
    }),
  );

  logger.info('ws connect', { connectionId, userId });
  return { statusCode: 200, body: 'Connected' };
}
