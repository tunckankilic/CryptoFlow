type Level = 'debug' | 'info' | 'warn' | 'error';

interface LogMeta {
  [key: string]: unknown;
}

/**
 * Keys whose values are always sensitive and must never reach CloudWatch.
 * Match is case-insensitive on the leaf key name.
 */
const SENSITIVE_KEYS = new Set([
  'authorization',
  'cookie',
  'password',
  'token',
  'accesstoken',
  'access_token',
  'refreshtoken',
  'refresh_token',
  'idtoken',
  'id_token',
  'secret',
  'apikey',
  'api_key',
  'privatekey',
  'private_key',
  'devicetoken',
  'device_token',
]);

/**
 * Mask an email so it stays useful for debugging without leaking PII in full.
 * `foo.bar@example.com` → `fo***@example.com`
 */
function maskEmail(email: string): string {
  const at = email.indexOf('@');
  if (at <= 0) return '***';
  const local = email.slice(0, at);
  const domain = email.slice(at);
  const visible = local.slice(0, Math.min(2, local.length));
  return `${visible}***${domain}`;
}

function redact(value: unknown, depth = 0): unknown {
  if (depth > 5) return '[depth-limit]';
  if (value === null || value === undefined) return value;
  if (Array.isArray(value)) return value.map((v) => redact(v, depth + 1));
  if (typeof value !== 'object') return value;

  const out: Record<string, unknown> = {};
  for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
    const lower = k.toLowerCase();
    if (SENSITIVE_KEYS.has(lower)) {
      out[k] = '[REDACTED]';
    } else if (lower === 'email' && typeof v === 'string') {
      out[k] = maskEmail(v);
    } else {
      out[k] = redact(v, depth + 1);
    }
  }
  return out;
}

function emit(level: Level, msg: string, meta?: LogMeta): void {
  const safeMeta = meta ? (redact(meta) as LogMeta) : undefined;
  const line = JSON.stringify({
    level,
    time: new Date().toISOString(),
    msg,
    ...safeMeta,
  });
  // CloudWatch indexes JSON automatically; stdout/stderr split is enough.
  if (level === 'error') {
    console.error(line);
  } else {
    console.log(line);
  }
}

export const logger = {
  debug: (msg: string, meta?: LogMeta) => emit('debug', msg, meta),
  info: (msg: string, meta?: LogMeta) => emit('info', msg, meta),
  warn: (msg: string, meta?: LogMeta) => emit('warn', msg, meta),
  error: (msg: string, meta?: LogMeta) => emit('error', msg, meta),
};
