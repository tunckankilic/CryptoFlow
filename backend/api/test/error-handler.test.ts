import { describe, it, expect } from 'vitest';
import { mapError } from '../src/middleware/error-handler';
import {
  HttpError,
  NotFoundError,
  ValidationError,
  UnauthorizedError,
} from '../src/errors';

describe('mapError', () => {
  it('maps HttpError to its status', () => {
    const r = mapError(new HttpError(418, 'teapot', 'I am a teapot'), 'rid-1');
    expect(r.statusCode).toBe(418);
    const body = JSON.parse(r.body!);
    expect(body.code).toBe('teapot');
    expect(body.requestId).toBe('rid-1');
  });

  it('maps NotFoundError to 404', () => {
    const r = mapError(new NotFoundError('missing'), 'rid');
    expect(r.statusCode).toBe(404);
    expect(JSON.parse(r.body!).code).toBe('not_found');
  });

  it('maps ValidationError to 400', () => {
    const r = mapError(new ValidationError('bad'), 'rid');
    expect(r.statusCode).toBe(400);
    expect(JSON.parse(r.body!).code).toBe('validation_error');
  });

  it('maps UnauthorizedError to 401', () => {
    const r = mapError(new UnauthorizedError(), 'rid');
    expect(r.statusCode).toBe(401);
    expect(JSON.parse(r.body!).code).toBe('unauthorized');
  });

  it('maps unknown errors to 500 internal_error', () => {
    const r = mapError(new Error('boom'), 'rid');
    expect(r.statusCode).toBe(500);
    const body = JSON.parse(r.body!);
    expect(body.code).toBe('internal_error');
    expect(body.requestId).toBe('rid');
  });

  it('includes details when HttpError carries them', () => {
    const r = mapError(
      new ValidationError('bad', { field: 'symbol' }),
      'rid',
    );
    expect(JSON.parse(r.body!).details).toEqual({ field: 'symbol' });
  });
});
