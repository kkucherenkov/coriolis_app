/**
 * WHY this file exists:
 * Pure, stateless Coriolis rules-engine functions. No I/O, no DI, no NestJS
 * decorators. These are the canonical formulas — a house-rule change is a
 * single edit here.
 *
 * Formulas are sourced from PRD §5.2 and §10:
 *
 *   HP max    = STR + AGI          (PRD §5.2: "HP max = STR + AGI")
 *   MP max    = WIT + EMP          (PRD §5.2: "MP max = WIT + EMP")
 *   Enc max   = STR × 2            (PRD §5.2: "Encumbrance limit = STR × 2")
 *   Enc cur   = sum of item weights (PRD §5.3: weight in slots, CYBERNETIC uses
 *                                    systemStrain not weight — PRD does not
 *                                    explicitly state cybs are exempt, but the
 *                                    schema stores cyb-specific fields in `data`
 *                                    while `weight` remains on the common
 *                                    fields; we sum `weight` for all items
 *                                    including CYBERNETIC because the Item
 *                                    schema always carries `weight: number`.
 *                                    If a cybernetic has weight 0 it does not
 *                                    add encumbrance. Assumption documented.)
 *   Push      = not exhausted AND roll not already pushed (PRD §10)
 */

import type { ItemReadModel } from '../characters/domain/character.ports';

// --------------- HP ---------------

/**
 * PRD §5.2: "HP max = STR + AGI"
 *
 * Attribute range is 1–5 (PRD §5.2), so valid output range is 2–10.
 */
export function computeHpMax(strength: number, agility: number): number {
  return strength + agility;
}

// --------------- MP ---------------

/**
 * PRD §5.2: "MP max = WIT + EMP"
 *
 * Attribute range is 1–5 (PRD §5.2), so valid output range is 2–10.
 */
export function computeMpMax(wits: number, empathy: number): number {
  return wits + empathy;
}

// --------------- Encumbrance ---------------

/**
 * PRD §5.2: "Encumbrance limit = STR × 2"
 *
 * Attribute range is 1–5, so valid output range is 2–10.
 */
export function computeEncumbranceMax(strength: number): number {
  return strength * 2;
}

/**
 * PRD §5.3: Encumbrance is the sum of weights of items.
 *
 * Assumption (PRD does not explicitly exempt CYBERNETIC from weight):
 * All items carry `weight: number` on the common payload stored in `data`.
 * We sum the `weight` field across all items. If a CYBERNETIC item has
 * `weight: 0` in its stored data, it contributes zero encumbrance. This is
 * consistent with the schema where `weight` is a common field for every
 * item type. Phase 2 (Feature 5.4) can add exemption logic if rule-book
 * research confirms cybs are always weight-free.
 *
 * Items without a `weight` field in data are treated as 0 (defensive).
 */
export function computeEncumbranceCurrent(items: ItemReadModel[]): number {
  return items.reduce((total, item) => {
    const data = item as Record<string, unknown>;
    const weight = typeof data['weight'] === 'number' ? data['weight'] : 0;
    return total + weight;
  }, 0);
}

// --------------- Push eligibility ---------------

/**
 * PRD §10: A roll can be pushed if:
 *   1. The character is not Exhausted (Exhausted blocks push).
 *   2. The roll has not already been pushed (one push per roll).
 *
 * For v1 this function takes a plain `conditions` object and a boolean
 * `alreadyPushed`. The dice-roller in Phase 4 (Feature 7.1) will wire the
 * full `Roll` entity here.
 */
export function canPush(
  conditions: { exhausted: boolean },
  alreadyPushed: boolean,
): boolean {
  if (conditions.exhausted) return false;
  if (alreadyPushed) return false;
  return true;
}
