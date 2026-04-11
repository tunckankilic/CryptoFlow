import { describe, it, expect } from 'vitest';
import { isInCooldown } from '../src/services/notifier';

describe('isInCooldown', () => {
  it('returns false when no lastTriggerDate is recorded', () => {
    expect(isInCooldown(undefined)).toBe(false);
  });

  it('returns true within the 1-hour window', () => {
    const tenMinutesAgo = new Date(Date.now() - 10 * 60 * 1000).toISOString();
    expect(isInCooldown(tenMinutesAgo)).toBe(true);
  });

  it('returns false after the 1-hour window', () => {
    const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString();
    expect(isInCooldown(twoHoursAgo)).toBe(false);
  });

  it('returns false for unparseable dates', () => {
    expect(isInCooldown('not-a-date')).toBe(false);
  });
});
