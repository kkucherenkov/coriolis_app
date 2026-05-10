/**
 * WHY this file exists:
 * Pure state-machine functions for the Encounter lifecycle.
 * These have zero side-effects and no NestJS/Prisma imports —
 * they can be imported anywhere and unit-tested trivially.
 *
 * Allowed transitions:
 *   setup → active   (requires ≥1 combatant — Block 3 lifts the guard)
 *   active → ended   (resets activeCombatantId to null)
 *
 * Everything else is an ENCOUNTER_INVALID_TRANSITION (422).
 */
import { EncounterInvalidTransitionError, EncounterNoCombatantsError } from './encounter.errors';

import type { EncounterStatus } from './encounter.ports';

/** All edges in the allowed transition graph. */
const ALLOWED_TRANSITIONS: ReadonlySet<`${EncounterStatus}->${EncounterStatus}`> = new Set([
  'setup->active',
  'active->ended',
]);

/**
 * Asserts that a status transition is legal.
 * Throws EncounterInvalidTransitionError (422) if not.
 *
 * @example
 *   assertCanTransition('setup', 'active');  // ok
 *   assertCanTransition('active', 'setup');  // throws
 */
export function assertCanTransition(from: EncounterStatus, to: EncounterStatus): void {
  const edge = `${from}->${to}`;
  if (!ALLOWED_TRANSITIONS.has(edge)) {
    throw new EncounterInvalidTransitionError(from, to);
  }
}

/**
 * Returns true when the transition requires ≥1 combatant on the encounter.
 * Currently only setup → active requires combatants.
 * Block 3 inverts the combatant-count check to allow the transition.
 */
export function requiresCombatants(from: EncounterStatus, to: EncounterStatus): boolean {
  return from === 'setup' && to === 'active';
}

/**
 * Full guard used by UpdateEncounterHandler:
 *  1. assertCanTransition (422 ENCOUNTER_INVALID_TRANSITION)
 *  2. if requiresCombatants → throw EncounterNoCombatantsError (422 ENCOUNTER_NO_COMBATANTS)
 *
 * The hasCombatants flag is supplied by the caller. Block 3 passes the
 * real count; until then the handler always passes false.
 */
export function guardTransition(
  from: EncounterStatus,
  to: EncounterStatus,
  hasCombatants: boolean,
): void {
  assertCanTransition(from, to);
  if (requiresCombatants(from, to) && !hasCombatants) {
    throw new EncounterNoCombatantsError();
  }
}
