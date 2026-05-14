/**
 * d66 → IconId roller for the character-creation wizard's Step 7 (Icon).
 *
 * ST3001 ch.2 step 15 — «Случайным образом определи Лика-покровителя» —
 * is a d66 roll: two d6, first die as tens (11..66 → 36 outcomes). Each
 * Icon gets exactly 4 of the 36 outcomes (36 / 9), allocated in canonical
 * `NINE_ICONS` order so the table is deterministic and easy to audit.
 *
 * The wizard's default surface is manual selection (player agency over
 * numerology); this helper backs the optional "Roll d66 for me" CTA on
 * `Step7Icon.vue`.
 */
import type { IconId } from '@app/api-client-ts';

/**
 * The Nine Icons in canonical order — matches the d66 mapping below.
 *
 * Typed as a 9-tuple so `NINE_ICONS[0..8]` are non-undefined under strict TS;
 * the `IconId` constraint guarantees each entry is a valid spec icon ID.
 */
export const NINE_ICONS = [
  'lady-of-tears',
  'traveler',
  'messenger',
  'merchant',
  'dancer',
  'gambler',
  'judge',
  'faceless-one',
  'deckhand',
] as const satisfies readonly [
  IconId,
  IconId,
  IconId,
  IconId,
  IconId,
  IconId,
  IconId,
  IconId,
  IconId,
];

const D66_FACE_COUNT = 36;
const ICONS_PER_OUTCOME = 4;

/**
 * Map a 0-based d66 index (0..35) to the canonical IconId.
 *
 * Pure for testing — no `Math.random` here.
 */
export function iconIdForD66Index(index: number): IconId {
  if (!Number.isInteger(index) || index < 0 || index >= D66_FACE_COUNT) {
    throw new RangeError(
      `iconIdForD66Index: expected integer in [0, ${String(D66_FACE_COUNT)}); got ${String(index)}`,
    );
  }
  const slot = Math.floor(index / ICONS_PER_OUTCOME);
  // `slot` is bounded to [0, 9) by the index check above; the const tuple
  // typing makes every NINE_ICONS[0..8] non-undefined, so the indexed access
  // returns IconId without a runtime fallback. Defensive `?? NINE_ICONS[0]`
  // would suppress the bound check rather than express it.
  return NINE_ICONS[slot as 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8];
}

/**
 * Roll a d66 and return the resulting IconId.
 *
 * Uses `Math.random()`; for deterministic tests use {@link iconIdForD66Index}.
 */
export function rollIconD66(): IconId {
  const ix = Math.floor(Math.random() * D66_FACE_COUNT);
  return iconIdForD66Index(ix);
}
