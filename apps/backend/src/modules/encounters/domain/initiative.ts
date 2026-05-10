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
 */

import type { CombatantWithSnapshot } from '../../combatants/domain/combatant.ports';

export const MAX_REROLL_PASSES = 3;

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
