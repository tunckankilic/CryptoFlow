import type { APIGatewayProxyEventV2 } from 'aws-lambda';
import type { MaybeAuth } from './middleware/auth';

export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';

export interface HandlerCtx {
  event: APIGatewayProxyEventV2;
  auth: MaybeAuth;
  pathParams: Record<string, string>;
  query: Record<string, string>;
  body: unknown;
}

export type Handler = (ctx: HandlerCtx) => Promise<unknown>;

export interface Route {
  method: HttpMethod;
  path: string;          // e.g. '/api/v1/portfolio/holdings/:id'
  handler: Handler;
  requireAuth: boolean;  // false for /health and other public endpoints
}

interface CompiledRoute extends Route {
  regex: RegExp;
  paramNames: string[];
}

function compile(path: string): { regex: RegExp; paramNames: string[] } {
  const paramNames: string[] = [];
  // Escape regex meta characters except '/' and ':'
  const pattern = path
    .split('/')
    .map((segment) => {
      if (segment.startsWith(':')) {
        paramNames.push(segment.slice(1));
        return '([^/]+)';
      }
      return segment.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    })
    .join('/');
  return { regex: new RegExp(`^${pattern}/?$`), paramNames };
}

export function compileRoutes(routes: Route[]): CompiledRoute[] {
  return routes.map((r) => ({ ...r, ...compile(r.path) }));
}

export interface MatchResult {
  route: CompiledRoute;
  pathParams: Record<string, string>;
}

export function matchRoute(
  compiled: CompiledRoute[],
  method: string,
  path: string,
): MatchResult | null {
  for (const route of compiled) {
    if (route.method !== method) continue;
    const m = route.regex.exec(path);
    if (!m) continue;
    const pathParams: Record<string, string> = {};
    route.paramNames.forEach((name, i) => {
      pathParams[name] = decodeURIComponent(m[i + 1]!);
    });
    return { route, pathParams };
  }
  return null;
}
