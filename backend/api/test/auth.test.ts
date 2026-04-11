import { describe, it, expect, vi, beforeEach } from 'vitest';

// Mock aws-jwt-verify before importing the auth module so the verifier
// instance picks up our stub instead of contacting Cognito.
// vi.mock is hoisted above imports, so we use vi.hoisted for the spy.
const { verifyMock } = vi.hoisted(() => ({ verifyMock: vi.fn() }));

vi.mock('aws-jwt-verify', () => ({
  CognitoJwtVerifier: {
    create: () => ({ verify: verifyMock }),
  },
}));

import { authenticate } from '../src/middleware/auth';
import { UnauthorizedError } from '../src/errors';

describe('authenticate', () => {
  beforeEach(() => {
    verifyMock.mockReset();
  });

  it('throws when no header is supplied', async () => {
    await expect(authenticate(undefined)).rejects.toBeInstanceOf(UnauthorizedError);
  });

  it('throws when scheme is not Bearer', async () => {
    await expect(authenticate('Basic abc')).rejects.toBeInstanceOf(UnauthorizedError);
  });

  it('throws on empty bearer token', async () => {
    await expect(authenticate('Bearer ')).rejects.toBeInstanceOf(UnauthorizedError);
  });

  it('throws when verifier rejects the token', async () => {
    verifyMock.mockRejectedValueOnce(new Error('expired'));
    await expect(authenticate('Bearer junk')).rejects.toBeInstanceOf(UnauthorizedError);
  });

  it('returns auth context for a valid token', async () => {
    verifyMock.mockResolvedValueOnce({
      sub: 'user-123',
      username: 'testuser',
      email: 'test@example.com',
    });
    const ctx = await authenticate('Bearer valid');
    expect(ctx).toEqual({
      userId: 'user-123',
      username: 'testuser',
      email: 'test@example.com',
    });
  });

  it('omits username/email when missing', async () => {
    verifyMock.mockResolvedValueOnce({ sub: 'user-456' });
    const ctx = await authenticate('Bearer valid');
    expect(ctx.userId).toBe('user-456');
    expect(ctx.username).toBeUndefined();
    expect(ctx.email).toBeUndefined();
  });
});
