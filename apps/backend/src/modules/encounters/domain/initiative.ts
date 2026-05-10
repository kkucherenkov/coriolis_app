/**
 * WHY this file exists:
 * Pure domain functions for initiative tie-resolution and ordering.
 * Zero side-effects, no NestJS/Prisma imports — trivially unit-testable.
 *
 * Tie-breaking rule (ST3001 ГЛАВА 5 «Раунды, ходы и инициатива», line 18):
 *   «В случае ничьей определите очерёдность хода случайным образом
 *   (бросьте ещё по одному кубику, только на этот раз безо всяких
 *   модификаторов — у кого больше, тот и ходит раньше).»
 *
 * Implementation: re-roll a fresh d6 for combatants tied on `initiative`,
 * up to MAX_REROLL_PASSES passes. Any combatants still tied after that are
 * left in stable insertion order (createdAt asc) — the GM is expected to
 * use the reorder operation to set the final order.
 *
 * T-2026-05-10-012: sumWeaponInitiative + clampInitiative added.
 *   Per ST3001 ГЛАВА 6, only equipped weapons contribute their initiative
 *   bonus. The d6 base (1..6) plus weapon modifier is clamped to 1..10,
 *   matching Combatant.initiative.maximum from the spec.
 */

import type { CombatantWithSnapshot } from '../../combatants/domain/combatant.ports';

export const MAX_REROLL_PASSES = 3;

const MIN_INITIATIVE = 1;
const MAX_INITIATIVE = 10;

/** Minimal weapon shape required to compute the initiative modifier. */
export interface WeaponInitiativeItem {
  initiative?: number;
  equipped?: boolean;
}

/**
 * Sums the `initiative` modifiers from a combatant's equipped weapons.
 * Per ST3001 ГЛАВА 6, only equipped weapons contribute their bonus —
 * carrying a Посох (+2) in your pack while wielding a Меч (+0) gives
 * +0, not +2. Returns 0 when the source has no equipped weapons or
 * no weapon-typed items at all (PCs and NPCs alike).
 */
export function sumWeaponInitiative(weapons: readonly WeaponInitiativeItem[]): number {
  return weapons
    .filter((w) => w.equipped === true)
    .reduce((sum, w) => sum + (w.initiative ?? 0), 0);
}

/**
 * Clamps the d6+modifier sum into the spec's stored range. The d6
 * base is 1..6; modifier sum is bounded by per-weapon −5..+5 (and a
 * realistic stack tops out around +4 with multi-weapon ambush combos),
 * so the 1..10 bound matches Combatant.initiative.maximum from the spec.
 */
export function clampInitiative(value: number): number {
  if (value < MIN_INITIATIVE) return MIN_INITIATIVE;
  if (value > MAX_INITIATIVE) return MAX_INITIATIVE;
  return value;
}

function groupByInitiative(items: CombatantWithSnapshot[]): Map<number, CombatantWithSnapshot[]> {
  const groups = new Map<number, CombatantWithSnapshot[]>();
  for (const item of items) {
    const key = item.combatant.initiative ?? 0;
    const bucket = groups.get(key) ?? [];
    bucket.push(item);
    groups.set(key, bucket);
  }
  return groups;
}

/**
 * Resolves initiative ties by re-rolling d6 for tied combatants until every
 * value is unique or `MAX_REROLL_PASSES` passes are exhausted. Pure: takes
 * a `rollD6` callback so randomness stays in the handler.
 *
 * Returns a new array; does not mutate the input. Each combatant in the
 * input must already have a non-null `initiative`.
 */
export function rerollTies(
  items: CombatantWithSnapshot[],
  rollD6: () => number,
): CombatantWithSnapshot[] {
  let working = items.map((item) => ({
    ...item,
    combatant: { ...item.combatant },
  }));

  for (let pass = 0; pass < MAX_REROLL_PASSES; pass++) {
    const groups = groupByInitiative(working);
    const tiedIds = new Set<string>();
    for (const bucket of groups.values()) {
      if (bucket.length > 1) {
        for (const item of bucket) tiedIds.add(item.combatant.id);
      }
    }

    if (tiedIds.size === 0) return working;

    working = working.map((item) =>
      tiedIds.has(item.combatant.id)
        ? { ...item, combatant: { ...item.combatant, initiative: rollD6() } }
        : item,
    );
  }

  return working;
}

/**
 * Sorts combatants by initiative (desc), then createdAt (asc) for any
 * combatants still tied after `rerollTies` exhausts its passes.
 *
 * Returns a new array — does not mutate the input.
 */
export function sortInitiative(items: CombatantWithSnapshot[]): CombatantWithSnapshot[] {
  return items.toSorted((a, b) => {
    const initA = a.combatant.initiative ?? 0;
    const initB = b.combatant.initiative ?? 0;

    if (initB !== initA) return initB - initA;

    return a.combatant.createdAt.localeCompare(b.combatant.createdAt);
  });
}

export { type CombatantWithSnapshot } from '../../combatants/domain/combatant.ports';
