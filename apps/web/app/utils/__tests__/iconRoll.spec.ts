/**
 * iconRoll.spec.ts
 *
 * Locks the d66 → IconId mapping for the wizard's optional "Roll d66 for me"
 * CTA. Each Icon must receive exactly 4 of the 36 d66 outcomes — drift in
 * either NINE_ICONS order or the slot-allocation breaks rules-fidelity to
 * ST3001 ch.2 step 15.
 */

import { describe, it, expect, vi } from 'vitest';
import type { IconId } from '@app/api-client-ts';
import { NINE_ICONS, iconIdForD66Index, rollIconD66 } from '../iconRoll';

describe('NINE_ICONS catalogue', () => {
  it('contains exactly 9 unique entries in canonical order', () => {
    expect(NINE_ICONS).toHaveLength(9);
    expect(new Set(NINE_ICONS).size).toBe(9);
    expect(NINE_ICONS[0]).toBe('lady-of-tears');
    expect(NINE_ICONS[8]).toBe('deckhand');
  });
});

describe('iconIdForD66Index — distribution', () => {
  it('maps each of the 36 d66 outcomes to a known IconId', () => {
    for (let i = 0; i < 36; i++) {
      const id = iconIdForD66Index(i);
      expect(NINE_ICONS).toContain(id);
    }
  });

  it('grants every Icon exactly 4 outcomes (36 / 9)', () => {
    const counts = new Map<IconId, number>();
    for (let i = 0; i < 36; i++) {
      const id = iconIdForD66Index(i);
      counts.set(id, (counts.get(id) ?? 0) + 1);
    }
    for (const id of NINE_ICONS) {
      expect(counts.get(id)).toBe(4);
    }
  });

  it.each([
    [0, 'lady-of-tears'],
    [3, 'lady-of-tears'],
    [4, 'traveler'],
    [16, 'dancer'],
    [32, 'deckhand'],
    [35, 'deckhand'],
  ] as const)('index %i → %s (canonical NINE_ICONS slot)', (index, expected) => {
    expect(iconIdForD66Index(index)).toBe(expected);
  });

  it.each([-1, 36, 100, 1.5, Number.NaN])('rejects out-of-range index %s', (bad) => {
    expect(() => iconIdForD66Index(bad)).toThrow(RangeError);
  });
});

describe('rollIconD66 — wraps Math.random into the table', () => {
  it('always returns one of the Nine Icons', () => {
    const seen = new Set<IconId>();
    for (let i = 0; i < 200; i++) {
      const id = rollIconD66();
      expect(NINE_ICONS).toContain(id);
      seen.add(id);
    }
    expect(seen.size).toBeGreaterThan(0);
  });

  it('uses Math.random() to pick a d66 index — minimum and maximum branches', () => {
    const spy = vi.spyOn(Math, 'random');
    spy.mockReturnValueOnce(0);
    expect(rollIconD66()).toBe('lady-of-tears');
    spy.mockReturnValueOnce(0.999_99);
    expect(rollIconD66()).toBe('deckhand');
    spy.mockRestore();
  });
});
