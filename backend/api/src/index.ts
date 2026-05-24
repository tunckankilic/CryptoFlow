import type { APIGatewayProxyHandlerV2 } from 'aws-lambda';
import { compileRoutes, matchRoute } from './router';
import { allRoutes } from './routes';
import { authenticate } from './middleware/auth';
import { mapError } from './middleware/error-handler';
import { checkRateLimit, PER_IP, PER_USER } from './middleware/rate-limit';
import { logger } from './logger';
import { PayloadTooLargeError, ValidationError } from './errors';

/**
 * Hard upper bound on request body size. API Gateway already caps at 10MB,
 * but this app's largest legitimate payload (a holding/transaction/journal
 * entry) is well under 8KB. 256KB leaves headroom for unanticipated batch
 * payloads while preventing a megabyte-flood DoS on Lambda CPU/memory.
 */
const MAX_BODY_BYTES = 256 * 1024;

const compiled = compileRoutes(allRoutes);

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  const requestId = event.requestContext.requestId;
  const method = event.requestContext.http.method;
  const stage = event.requestContext.stage;
  const rawPath = event.requestContext.http.path;
  const path =
    stage && stage !== '$default' && rawPath.startsWith(`/${stage}/`)
      ? rawPath.slice(stage.length + 1)
      : rawPath === `/${stage}`
        ? '/'
        : rawPath;

  try {
    // Layer 1: per-IP throttle, applied before any route work.
    // Falls back to "unknown" if the gateway didn't populate sourceIp (local invoke).
    const sourceIp = event.requestContext.http.sourceIp || 'unknown';
    checkRateLimit('ip', sourceIp, PER_IP);

    const matched = matchRoute(compiled, method, path);
    if (!matched) {
      logger.info('route not matched', {
        requestId,
        method,
        path,
        rawPath: event.rawPath,
        stage: event.requestContext.stage,
      });
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

    // Layer 2: per-userId throttle for authenticated requests. Stricter than
    // per-IP so a single compromised account can't burn through the per-IP
    // budget on a shared NAT.
    if (auth?.userId) {
      checkRateLimit('user', auth.userId, PER_USER);
    }

    let body: unknown = null;
    if (event.body) {
      // Cheap pre-check on the encoded length to reject obvious floods before
      // we even decode/parse. Base64 expands by ~4/3, so this is a slight
      // over-estimate of the decoded size, which is the conservative direction.
      if (event.body.length > MAX_BODY_BYTES) {
        throw new PayloadTooLargeError('Request body exceeds 256KB limit');
      }
      try {
        const raw = event.isBase64Encoded
          ? Buffer.from(event.body, 'base64').toString('utf8')
          : event.body;
        if (Buffer.byteLength(raw, 'utf8') > MAX_BODY_BYTES) {
          throw new PayloadTooLargeError('Request body exceeds 256KB limit');
        }
        body = raw.length > 0 ? JSON.parse(raw) : null;
      } catch (err) {
        if (err instanceof PayloadTooLargeError) throw err;
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
