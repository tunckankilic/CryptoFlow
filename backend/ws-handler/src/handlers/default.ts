import type { APIGatewayProxyWebsocketEventV2 } from 'aws-lambda';
import { logger } from '../logger';

// We are server-push only in Faz 2; client messages are silently acknowledged.
export async function onDefault(event: APIGatewayProxyWebsocketEventV2) {
  logger.info('ws default route', {
    connectionId: event.requestContext.connectionId,
  });
  return { statusCode: 200, body: 'OK' };
}
