/**
 * bridge.spec.ts
 *
 * Locks the pure formatters that back the Bridge dashboard
 * (`apps/web/app/pages/app/dashboard.vue`):
 *
 *   - `pickAphorism` — deterministic day-of-epoch → aphorism key.
 *   - `formatCycleClock` — 24-hour HH:MM, locale-respecting.
 *   - `formatCycleDate` — long-form weekday + day + month.
 *   - `formatSyncLabel` — offline / pending / relative-time branches.
 */

import { describe, it, expect, vi } from 'vitest';
import {
  APHORISM_KEYS,
  formatCycleClock,
  formatCycleDate,
  formatSyncLabel,
  pickAphorism,
} from '../bridge';

const T = (k: string): string => `t:${k}`;

describe('APHORISM_KEYS', () => {
  it('contains exactly the three curated lines in declaration order', () => {
    expect(APHORISM_KEYS).toEqual(['aphorism.wheel', 'aphorism.icons', 'aphorism.dark']);
  });
});

describe('pickAphorism', () => {
  it('returns the same key for two timestamps in the same UTC day', () => {
    const a = new Date('2026-05-14T05:01:00Z');
    const b = new Date('2026-05-14T18:59:59Z');
    expect(pickAphorism(a)).toBe(pickAphorism(b));
  });

  it('advances to the next key at the UTC day boundary', () => {
    const day1 = new Date('2026-05-14T23:59:59Z');
    const day2 = new Date('2026-05-15T00:00:00Z');
    expect(pickAphorism(day1)).not.toBe(pickAphorism(day2));
  });

  it.each([
    // day index = floor(epoch_ms / 86 400 000); day % 3 → key.
    ['1970-01-01T12:00:00Z', 'aphorism.wheel'], // day 0 → 0
    ['1970-01-02T00:00:00Z', 'aphorism.icons'], // day 1 → 1
    ['1970-01-03T00:00:00Z', 'aphorism.dark'], // day 2 → 2
    ['1970-01-04T00:00:00Z', 'aphorism.wheel'], // day 3 → 0 (wraps)
  ] as const)('day %s → %s', (iso, expected) => {
    expect(pickAphorism(new Date(iso))).toBe(expected);
  });

  it('throws when given an empty key list', () => {
    expect(() => pickAphorism(new Date(), [])).toThrow(/must contain at least one entry/);
  });
});

describe('formatCycleClock', () => {
  it('renders HH:MM in 24-hour format', () => {
    // 17:05 UTC may or may not localise to 17:05 depending on the test
    // host's timezone — we assert the shape, not the exact value.
    const out = formatCycleClock(new Date('2026-05-14T17:05:00Z'), 'en-US');
    expect(out).toMatch(/^\d{2}:\d{2}$/);
  });
});

describe('formatCycleDate', () => {
  it('includes the localised weekday + day + month', () => {
    const out = formatCycleDate(new Date('2026-05-14T12:00:00Z'), 'en-US');
    // Example: "Thursday, May 14" — host TZ might bump the day, so we
    // assert structure rather than the literal weekday.
    expect(out).toMatch(/[A-Za-z]+,?\s+(\d{1,2}\s+[A-Za-z]+|[A-Za-z]+\s+\d{1,2})/);
  });
});

describe('formatSyncLabel', () => {
  const NOW = new Date('2026-05-14T12:00:00Z');

  it('returns the offline message when online=false (no relative time)', () => {
    const result = formatSyncLabel({
      online: false,
      now: NOW,
      lastSyncAt: NOW,
      locale: 'en-US',
      t: T,
    });
    expect(result).toBe('t:sync.offline');
  });

  it('returns the pending message when no lastSyncAt has been recorded', () => {
    const result = formatSyncLabel({
      online: true,
      now: NOW,
      lastSyncAt: null,
      locale: 'en-US',
      t: T,
    });
    expect(result).toBe('t:sync.pending');
  });

  it('formats sub-minute deltas as seconds', () => {
    const result = formatSyncLabel({
      online: true,
      now: NOW,
      lastSyncAt: new Date(NOW.getTime() - 5000), // 5 s ago
      locale: 'en-US',
      t: T,
    });
    expect(result.toLowerCase()).toMatch(/second|now/);
  });

  it('formats sub-hour deltas as minutes', () => {
    const result = formatSyncLabel({
      online: true,
      now: NOW,
      lastSyncAt: new Date(NOW.getTime() - 12 * 60_000), // 12 min ago
      locale: 'en-US',
      t: T,
    });
    expect(result.toLowerCase()).toMatch(/minute/);
  });

  it('formats >1h deltas as hours', () => {
    const result = formatSyncLabel({
      online: true,
      now: NOW,
      lastSyncAt: new Date(NOW.getTime() - 3 * 60 * 60_000), // 3 h ago
      locale: 'en-US',
      t: T,
    });
    expect(result.toLowerCase()).toMatch(/hour/);
  });

  it('does not call `t` when a relative-time branch resolves', () => {
    const tSpy = vi.fn((k: string) => k);
    formatSyncLabel({
      online: true,
      now: NOW,
      lastSyncAt: new Date(NOW.getTime() - 30_000),
      locale: 'en-US',
      t: tSpy,
    });
    expect(tSpy).not.toHaveBeenCalled();
  });
});
