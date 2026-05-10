/**
 * WHY this file exists:
 * Pure domain function for sorting combatants by initiative result.
 * Zero side-effects, no NestJS/Prisma imports — trivially unit-testable.
 *
 * Tie-breaking rule (ST3001):
 *   1. initiative desc
 *   2. agility desc (from pcSnapshot.attributes.agility or npcSnapshot.attributes.agility)
 *   3. stable original order (createdAt asc) for remaining ties
 */

import type { CombatantWithSnapshot } from '../../combatants/domain/combatant.ports';

/**
 * Returns the agility value for a combatant from its snapshot.
 * Falls back to 0 when no snapshot is present (defensive).
 */
function getAgility(item: CombatantWithSnapshot): number {
  if (item.pcSnapshot) return item.pcSnapshot.attributes.agility;
  if (item.npcSnapshot) return item.npcSnapshot.attributes.agility;
  return 0;
}

/**
 * Sorts combatants by initiative (desc), then agility (desc), then createdAt (asc).
 *
 * The `initiative` field is guaranteed non-null when this function is called
 * (the handler assigns a value to every combatant before sorting).
 *
 * Returns a new array — does not mutate the input.
 */
export function sortInitiative(items: CombatantWithSnapshot[]): CombatantWithSnapshot[] {
  return items.toSorted((a, b) => {
    const initA = a.combatant.initiative ?? 0;
    const initB = b.combatant.initiative ?? 0;

    // 1. initiative desc
    if (initB !== initA) return initB - initA;

    // 2. agility desc
    const agilityDiff = getAgility(b) - getAgility(a);
    if (agilityDiff !== 0) return agilityDiff;

    // 3. stable: createdAt asc
    return a.combatant.createdAt.localeCompare(b.combatant.createdAt);
  });
}

export { type CombatantWithSnapshot } from '../../combatants/domain/combatant.ports';
