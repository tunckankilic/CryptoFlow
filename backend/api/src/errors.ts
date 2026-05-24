export class HttpError extends Error {
  constructor(
    public readonly status: number,
    public readonly code: string,
    message: string,
    public readonly details?: unknown,
  ) {
    super(message);
    this.name = 'HttpError';
  }
}

export class UnauthorizedError extends HttpError {
  constructor(message = 'Unauthorized', details?: unknown) {
    super(401, 'unauthorized', message, details);
    this.name = 'UnauthorizedError';
  }
}

export class ForbiddenError extends HttpError {
  constructor(message = 'Forbidden', details?: unknown) {
    super(403, 'forbidden', message, details);
    this.name = 'ForbiddenError';
  }
}

export class NotFoundError extends HttpError {
  constructor(message = 'Not Found', details?: unknown) {
    super(404, 'not_found', message, details);
    this.name = 'NotFoundError';
  }
}

export class ValidationError extends HttpError {
  constructor(message = 'Invalid request', details?: unknown) {
    super(400, 'validation_error', message, details);
    this.name = 'ValidationError';
  }
}

export class ConflictError extends HttpError {
  constructor(message = 'Conflict', details?: unknown) {
    super(409, 'conflict', message, details);
    this.name = 'ConflictError';
  }
}

export class PayloadTooLargeError extends HttpError {
  constructor(message = 'Request body too large', details?: unknown) {
    super(413, 'payload_too_large', message, details);
    this.name = 'PayloadTooLargeError';
  }
}

export class RateLimitError extends HttpError {
  constructor(
    public readonly retryAfterSeconds: number,
    message = 'Too many requests',
  ) {
    super(429, 'rate_limited', message, { retryAfterSeconds });
    this.name = 'RateLimitError';
  }
}
