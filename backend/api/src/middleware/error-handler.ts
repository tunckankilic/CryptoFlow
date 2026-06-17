import type { APIGatewayProxyStructuredResultV2 } from 'aws-lambda';
import { HttpError, RateLimitError } from '../errors';
import { logger } from '../logger';

interface ErrorBody {
  error: string;
  code: string;
  details?: unknown;
  requestId?: string;
}

export function mapError(
  err: unknown,
  requestId: string,
): APIGatewayProxyStructuredResultV2 {
  if (err instanceof HttpError) {
    const body: ErrorBody = {
      error: err.message,
      code: err.code,
      requestId,
    };
    if (err.details !== undefined) body.details = err.details;
    const headers: Record<string, string> = { 'Content-Type': 'application/json' };
    if (err instanceof RateLimitError) {
      headers['Retry-After'] = String(err.retryAfterSeconds);
    }
    return {
      statusCode: err.status,
      headers,
      body: JSON.stringify(body),
    };
  }

  logger.error('Unhandled error', {
    requestId,
    error: err instanceof Error ? err.message : String(err),
    stack: err instanceof Error ? err.stack : undefined,
  });

  return {
    statusCode: 500,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      error: 'Internal server error',
      code: 'internal_error',
      requestId,
    } satisfies ErrorBody),
  };
}
