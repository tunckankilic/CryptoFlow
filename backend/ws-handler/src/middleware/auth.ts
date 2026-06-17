import { CognitoJwtVerifier } from 'aws-jwt-verify';
import { config } from '../config';

const verifier = CognitoJwtVerifier.create({
  userPoolId: config.cognito.userPoolId,
  tokenUse: 'access',
  clientId: config.cognito.clientId,
});

export interface VerifiedUser {
  userId: string;
}

/**
 * WebSocket clients pass the JWT as a `token` query string parameter on
 * the $connect upgrade request because custom HTTP headers are not portable
 * across native WebSocket implementations.
 */
export async function verifyToken(token: string | undefined): Promise<VerifiedUser> {
  if (!token) throw new Error('missing-token');
  const payload = await verifier.verify(token);
  return { userId: payload.sub };
}
