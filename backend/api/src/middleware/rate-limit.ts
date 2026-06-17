import { RateLimitError } from '../errors';

/**
 * In-memory sliding-window rate limiter.
 *
 * State lives in the Lambda execution-container heap, so each warm container
 * keeps its own counter. For low-traffic single-user / CV-scale deployments
 * this is sufficient: AWS keeps a small number of warm containers, and the
 * Lambda `reserved_concurrent_executions` cap (set in Terraform) bounds the
 * worst case even if many containers race.
 *
 * For multi-region or high-concurrency setups, swap this for a DynamoDB-backed
 * counter (PK = bucket key, TTL = window end) — same interface.
 */

export interface BucketConfig {
  /** Sliding window size in milliseconds. */
  windowMs: number;
  /** Max requests allowed within the window. */
  max: number;
}

/** Per-IP guard applied to every request, before auth. Blocks dumb floods. */
export const PER_IP: BucketConfig = { windowMs: 60_000, max: 120 };

/** Per-userId guard applied after auth. Blocks abuse from legit accounts. */
export const PER_USER: BucketConfig = { windowMs: 60_000, max: 60 };

const buckets = new Map<string, number[]>();

/** Soft cap on map size before a sweep runs. */
const MAX_KEYS = 5000;

export function checkRateLimit(
  prefix: string,
  key: string,
  config: BucketConfig,
): void {
  const id = `${prefix}:${key}`;
  const now = Date.now();
  const cutoff = now - config.windowMs;

  const existing = buckets.get(id) ?? [];
  const fresh = existing.filter((t) => t > cutoff);

  if (fresh.length >= config.max) {
    const oldest = fresh[0]!;
    const retryAfter = Math.max(1, Math.ceil((oldest + config.windowMs - now) / 1000));
    throw new RateLimitError(retryAfter);
  }

  fresh.push(now);
  buckets.set(id, fresh);

  // Opportunistic GC — stop the map from growing unbounded if many distinct
  // keys hit a warm container.
  if (buckets.size > MAX_KEYS) {
    for (const [k, v] of buckets) {
      const stillFresh = v.filter((t) => t > cutoff);
      if (stillFresh.length === 0) {
        buckets.delete(k);
      } else if (stillFresh.length !== v.length) {
        buckets.set(k, stillFresh);
      }
    }
  }
}

/** Test-only: reset internal state between tests. */
export function __resetRateLimitState(): void {
  buckets.clear();
}
