import { describe, it, expect } from 'vitest';

import { countHits, pushDice, rollPool } from './roll-engine';

describe('rollPool', () => {
  it('returns an array of length `pool` for positive pool sizes', () => {
    expect(rollPool(1)).toHaveLength(1);
    expect(rollPool(5)).toHaveLength(5);
    expect(rollPool(20)).toHaveLength(20);
  });

  it('returns dice within the [1, 6] range', () => {
    for (let trial = 0; trial < 50; trial++) {
      for (const die of rollPool(8)) {
        expect(die).toBeGreaterThanOrEqual(1);
        expect(die).toBeLessThanOrEqual(6);
      }
    }
  });

  it('returns exactly 2 dice when pool === 0 (Ноль кубиков, ГЛАВА 3 line 161)', () => {
    for (let trial = 0; trial < 50; trial++) {
      const dice = rollPool(0);
      expect(dice).toHaveLength(2);
      for (const die of dice) {
        expect(die).toBeGreaterThanOrEqual(1);
        expect(die).toBeLessThanOrEqual(6);
      }
    }
  });
});

describe('countHits', () => {
  it('counts every 6 in the array for a positive pool', () => {
    expect(countHits([1, 2, 3, 4, 5], 5)).toBe(0);
    expect(countHits([6, 6, 6, 1], 4)).toBe(3);
    expect(countHits([6], 1)).toBe(1);
  });

  it('returns 1 when pool === 0 and both dice rolled a 6 (Ноль кубиков double-six)', () => {
    expect(countHits([6, 6], 0)).toBe(1);
  });

  it('returns 0 when pool === 0 and at least one die is not a 6', () => {
    expect(countHits([6, 5], 0)).toBe(0);
    expect(countHits([5, 6], 0)).toBe(0);
    expect(countHits([1, 2], 0)).toBe(0);
  });

  it('does not double-count: a single 6 in the zero-dice case is still 0 hits', () => {
    // Canon: success on Ноль кубиков requires *both* sixes — never one.
    expect(countHits([6, 1], 0)).toBe(0);
  });
});

describe('pushDice', () => {
  it('preserves all 6s and rerolls every other face', () => {
    const original = [6, 6, 6, 6];
    expect(pushDice(original)).toEqual([6, 6, 6, 6]);
  });

  it('returns an array of the same length', () => {
    expect(pushDice([1, 2, 3, 4, 5, 6, 6])).toHaveLength(7);
    expect(pushDice([3, 5])).toHaveLength(2);
  });

  it('keeps existing 6s in place after push', () => {
    const result = pushDice([1, 6, 2, 6, 3]);
    expect(result[1]).toBe(6);
    expect(result[3]).toBe(6);
  });
});
