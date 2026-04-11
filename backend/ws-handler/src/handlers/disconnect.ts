import type { APIGatewayProxyWebsocketEventV2 } from 'aws-lambda';
import { DeleteCommand } from '@aws-sdk/lib-dynamodb';
import { ddb } from '../lib/ddb';
import { config } from '../config';
import { logger } from '../logger';

export async function onDisconnect(event: APIGatewayProxyWebsocketEventV2) {
  const connectionId = event.requestContext.connectionId;
  await ddb.send(
    new DeleteCommand({
      TableName: config.ddb.wsConnections,
      Key: { connectionId },
    }),
  );
  logger.info('ws disconnect', { connectionId });
  return { statusCode: 200, body: 'Disconnected' };
}
