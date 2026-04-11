import { CognitoJwtVerifier } from 'aws-jwt-verify';
import { config } from '../config';
import { UnauthorizedError } from '../errors';

// Mobile clients send the Cognito access token. The verifier validates
// signature, expiry, issuer, token_use, and client_id automatically.
const verifier = CognitoJwtVerifier.create({
  userPoolId: config.cognito.userPoolId,
  tokenUse: 'access',
  clientId: config.cognito.clientId,
});

export interface AuthContext {
  userId: string;
  username?: string;
  email?: string;
}

// `null` is allowed in the request handler context type so public routes
// can declare auth as not present without lying about the type.
export type MaybeAuth = AuthContext | null;

export async function authenticate(authHeader?: string): Promise<AuthContext> {
  if (!authHeader || !authHeader.toLowerCase().startsWith('bearer ')) {
    throw new UnauthorizedError('Missing or malformed Authorization header');
  }
  const token = authHeader.slice(7).trim();
  if (!token) throw new UnauthorizedError('Empty bearer token');
  try {
    const payload = await verifier.verify(token);
    return {
      userId: payload.sub,
      username: typeof payload.username === 'string' ? payload.username : undefined,
      email: typeof payload.email === 'string' ? payload.email : undefined,
    };
  } catch {
    throw new UnauthorizedError('Invalid or expired token');
  }
}
