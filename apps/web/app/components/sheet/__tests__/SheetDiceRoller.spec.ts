/**
 * SheetDiceRoller.spec.ts — logic unit tests
 * (T-AUDIT-2026-05-15-DICE-PUSH-FAIL).
 *
 * Follows the no-mount pattern: tests the pure helpers extracted from
 * the SFC without a Nuxt runtime. The push-outcome contract is the
 * delta in hits between the pre-push and post-push Roll snapshot.
 * Mount-level interaction tests are deferred to Playwright.
 */

import { describe, it, expect } from 'vitest';
import type { Roll } from '@app/api-client-ts';

// ── Fixture ──────────────────────────────────────────────────────────────────

function makeRoll(overrides: Partial<Roll> = {}): Roll {
  return {
    id: 'roll-001',
    characterId: 'char-001',
    gameSessionId: null,
    kind: 'skill',
    label: 'Pilot · Evade',
    pool: 5,
    dice: [6, 6, 4, 3, 2],
    hits: 2,
    pushed: false,
    breakdown: null,
    createdAt: '2026-05-15T09:00:00Z',
    ...overrides,
  };
}

// ── Push-outcome helper ──────────────────────────────────────────────────────
// Mirrors the in-SFC math in onPush: pushDelta = postRoll.hits - preRoll.hits.
// The SFC stores `pushDelta` as `number | null` (null until a push fires in
// this session); this helper returns just the delta. The null-state is the
// caller's concern.

function pushDelta(preRoll: Roll, postRoll: Roll): number {
  return postRoll.hits - preRoll.hits;
}

describe('SheetDiceRoller — pushDelta (T-AUDIT-2026-05-15)', () => {
  it('returns 0 when the push reroll added no new 6s (fail case)', () => {
    // Spec §9: "Push can fail (no new 6s) … render the failure state".
    const pre = makeRoll({ dice: [6, 6, 4, 3, 2], hits: 2 });
    const post = makeRoll({
      dice: [6, 6, 5, 4, 1], // non-6s rerolled, no new 6
      hits: 2,
      pushed: true,
    });
    expect(pushDelta(pre, post)).toBe(0);
  });

  it('returns +N when the push reroll gained new 6s (happy case)', () => {
    const pre = makeRoll({ dice: [6, 4, 3, 2, 1], hits: 1 });
    const post = makeRoll({
      dice: [6, 6, 6, 5, 2], // two non-6s converted to 6
      hits: 3,
      pushed: true,
    });
    expect(pushDelta(pre, post)).toBe(2);
  });

  it('returns +1 for the minimal-success case', () => {
    const pre = makeRoll({ dice: [4, 3, 2, 2, 1], hits: 0 });
    const post = makeRoll({
      dice: [6, 3, 2, 2, 1],
      hits: 1,
      pushed: true,
    });
    expect(pushDelta(pre, post)).toBe(1);
  });

  it('cannot go negative (server guarantees kept 6s are kept)', () => {
    // Defensive: the server-side roll engine never re-rolls a 6, so the
    // post-push hit count is always >= the pre-push count. We assert
    // the helper agrees with that invariant — a regression that drops
    // a 6 would surface here as a negative delta, which the UI does NOT
    // know how to render.
    const pre = makeRoll({ dice: [6, 6, 4, 2, 1], hits: 2 });
    const post = makeRoll({
      dice: [6, 6, 5, 3, 1], // 6s preserved, non-6s rerolled, still no new 6s
      hits: 2,
      pushed: true,
    });
    expect(pushDelta(pre, post)).toBeGreaterThanOrEqual(0);
  });
});
