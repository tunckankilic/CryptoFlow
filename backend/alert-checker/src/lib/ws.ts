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
