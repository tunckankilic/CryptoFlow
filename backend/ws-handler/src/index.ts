import type {
  APIGatewayProxyWebsocketEventV2,
  APIGatewayProxyResultV2,
} from 'aws-lambda';
import { onConnect } from './handlers/connect';
import { onDisconnect } from './handlers/disconnect';
import { onDefault } from './handlers/default';
import { logger } from './logger';

export const handler = async (
  event: APIGatewayProxyWebsocketEventV2,
): Promise<APIGatewayProxyResultV2> => {
  const route = event.requestContext.routeKey;
  try {
    switch (route) {
      case '$connect':
        return await onConnect(event);
      case '$disconnect':
        return await onDisconnect(event);
      default:
        return await onDefault(event);
    }
  } catch (err) {
    logger.error('ws handler error', {
      route,
      error: err instanceof Error ? err.message : String(err),
    });
    return { statusCode: 500, body: 'Internal Error' };
  }
};
