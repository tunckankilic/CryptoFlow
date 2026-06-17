import { describe, it, expect } from 'vitest';
import { isTriggered } from '../src/services/alert-evaluator';

const base = { alertId: 'a', userId: 'u', symbol: 'BTCUSDT' as const };

describe('isTriggered', () => {
  describe('above', () => {
    it('triggers when price equals target', () => {
      expect(isTriggered({ ...base, type: 'above', targetPrice: 100 }, 100)).toBe(true);
    });
    it('triggers when price exceeds target', () => {
      expect(isTriggered({ ...base, type: 'above', targetPrice: 100 }, 101)).toBe(true);
    });
    it('does not trigger when price is below target', () => {
      expect(isTriggered({ ...base, type: 'above', targetPrice: 100 }, 99)).toBe(false);
    });
    it('returns false when targetPrice is missing', () => {
      expect(isTriggered({ ...base, type: 'above' }, 100)).toBe(false);
    });
  });

  describe('below', () => {
    it('triggers when price equals target', () => {
      expect(isTriggered({ ...base, type: 'below', targetPrice: 100 }, 100)).toBe(true);
    });
    it('triggers when price is below target', () => {
      expect(isTriggered({ ...base, type: 'below', targetPrice: 100 }, 99)).toBe(true);
    });
    it('does not trigger when price exceeds target', () => {
      expect(isTriggered({ ...base, type: 'below', targetPrice: 100 }, 101)).toBe(false);
    });
  });

  describe('percentUp', () => {
    it('triggers when change reaches threshold', () => {
      expect(
        isTriggered(
          { ...base, type: 'percentUp', basePrice: 100, percentChange: 10 },
          110,
        ),
      ).toBe(true);
    });
    it('does not trigger before threshold', () => {
      expect(
        isTriggered(
          { ...base, type: 'percentUp', basePrice: 100, percentChange: 10 },
          109,
        ),
      ).toBe(false);
    });
    it('returns false without basePrice', () => {
      expect(
        isTriggered({ ...base, type: 'percentUp', percentChange: 10 }, 110),
      ).toBe(false);
    });
  });

  describe('percentDown', () => {
    it('triggers when change drops past threshold', () => {
      expect(
        isTriggered(
          { ...base, type: 'percentDown', basePrice: 100, percentChange: 10 },
          90,
        ),
      ).toBe(true);
    });
    it('does not trigger before threshold', () => {
      expect(
        isTriggered(
          { ...base, type: 'percentDown', basePrice: 100, percentChange: 10 },
          91,
        ),
      ).toBe(false);
    });
  });

  it('returns false for non-finite price', () => {
    expect(isTriggered({ ...base, type: 'above', targetPrice: 1 }, NaN)).toBe(false);
  });
});
