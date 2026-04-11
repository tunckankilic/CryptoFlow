import type { APIGatewayProxyHandlerV2 } from 'aws-lambda';
import { compileRoutes, matchRoute } from './router';
import { allRoutes } from './routes';
import { authenticate } from './middleware/auth';
import { mapError } from './middleware/error-handler';
import { logger } from './logger';
import { ValidationError } from './errors';

const compiled = compileRoutes(allRoutes);

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  const requestId = event.requestContext.requestId;
  const method = event.requestContext.http.method;
  const path = event.requestContext.http.path;

  try {
    const matched = matchRoute(compiled, method, path);
    if (!matched) {
      return {
        statusCode: 404,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          error: 'Not Found',
          code: 'not_found',
          requestId,
        }),
      };
    }

    const { route, pathParams } = matched;
    const auth = route.requireAuth
      ? await authenticate(event.headers.authorization ?? event.headers.Authorization)
      : null;

    let body: unknown = null;
    if (event.body) {
      try {
        const raw = event.isBase64Encoded
          ? Buffer.from(event.body, 'base64').toString('utf8')
          : event.body;
        body = raw.length > 0 ? JSON.parse(raw) : null;
      } catch {
        throw new ValidationError('Invalid JSON body');
      }
    }

    logger.info('request', {
      requestId,
      method,
      path,
      userId: auth?.userId,
    });

    const result = await route.handler({
      event,
      auth,
      pathParams,
      query: event.queryStringParameters
        ? Object.fromEntries(
            Object.entries(event.queryStringParameters).filter(
              ([, v]) => v !== undefined,
            ),
          ) as Record<string, string>
        : {},
      body,
    });

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(result ?? null),
    };
  } catch (err) {
    return mapError(err, requestId);
  }
};
