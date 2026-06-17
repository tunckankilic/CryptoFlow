import { describe, it, expect } from 'vitest';
import { compileRoutes, matchRoute, type Route } from '../src/router';

const routes: Route[] = [
  { method: 'GET', path: '/health', requireAuth: false, handler: async () => ({}) },
  {
    method: 'GET',
    path: '/api/v1/portfolio/holdings',
    requireAuth: true,
    handler: async () => ({}),
  },
  {
    method: 'PUT',
    path: '/api/v1/portfolio/holdings/:id',
    requireAuth: true,
    handler: async () => ({}),
  },
  {
    method: 'DELETE',
    path: '/api/v1/watchlist/:symbol',
    requireAuth: true,
    handler: async () => ({}),
  },
];

const compiled = compileRoutes(routes);

describe('matchRoute', () => {
  it('matches a static path', () => {
    const m = matchRoute(compiled, 'GET', '/health');
    expect(m?.route.path).toBe('/health');
    expect(m?.pathParams).toEqual({});
  });

  it('returns null for unknown path', () => {
    expect(matchRoute(compiled, 'GET', '/nope')).toBeNull();
  });

  it('returns null when method does not match', () => {
    expect(matchRoute(compiled, 'POST', '/health')).toBeNull();
  });

  it('extracts a single path param', () => {
    const m = matchRoute(compiled, 'PUT', '/api/v1/portfolio/holdings/01H123');
    expect(m?.route.path).toBe('/api/v1/portfolio/holdings/:id');
    expect(m?.pathParams).toEqual({ id: '01H123' });
  });

  it('decodes URL-encoded path params', () => {
    const m = matchRoute(compiled, 'DELETE', '/api/v1/watchlist/BTC%2FUSDT');
    expect(m?.pathParams).toEqual({ symbol: 'BTC/USDT' });
  });

  it('does not match a parameterized path against a static one', () => {
    const m = matchRoute(compiled, 'GET', '/api/v1/portfolio/holdings/01H123');
    expect(m).toBeNull();
  });

  it('tolerates a trailing slash', () => {
    const m = matchRoute(compiled, 'GET', '/health/');
    expect(m?.route.path).toBe('/health');
  });
});
