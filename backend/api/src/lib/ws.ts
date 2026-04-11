import {
  ApiGatewayManagementApiClient,
  PostToConnectionCommand,
  GoneException,
} from '@aws-sdk/client-apigatewaymanagementapi';
import { config } from '../config';

const wsClient = new ApiGatewayManagementApiClient({
  region: config.region,
  endpoint: config.wsApiEndpoint,
});

/**
 * Push a JSON payload to a single WebSocket connection.
 * Returns false if the connection is gone (caller should clean up).
 */
export async function postToConnection(
  connectionId: string,
  payload: unknown,
): Promise<boolean> {
  try {
    await wsClient.send(
      new PostToConnectionCommand({
        ConnectionId: connectionId,
        Data: Buffer.from(JSON.stringify(payload)),
      }),
    );
    return true;
  } catch (err) {
    if (err instanceof GoneException) return false;
    throw err;
  }
}
