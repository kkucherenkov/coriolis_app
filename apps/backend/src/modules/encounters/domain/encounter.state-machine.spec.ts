/**
 * Unit tests for encounter state machine pure functions.
 * No NestJS, no Prisma, no async — just logic.
 */
import { describe, expect, it } from 'vitest';

import { EncounterInvalidTransitionError, EncounterNoCombatantsError } from './encounter.errors';
import {
  assertCanTransition,
  guardTransition,
  requiresCombatants,
} from './encounter.state-machine';

describe('assertCanTransition', () => {
  it('allows setup → active', () => {
    expect(() => assertCanTransition('setup', 'active')).not.toThrow();
  });

  it('allows active → ended', () => {
    expect(() => assertCanTransition('active', 'ended')).not.toThrow();
  });

  it('rejects active → setup', () => {
    expect(() => assertCanTransition('active', 'setup')).toThrow(EncounterInvalidTransitionError);
  });

  it('rejects ended → active', () => {
    expect(() => assertCanTransition('ended', 'active')).toThrow(EncounterInvalidTransitionError);
  });

  it('rejects ended → setup', () => {
    expect(() => assertCanTransition('ended', 'setup')).toThrow(EncounterInvalidTransitionError);
  });

  it('rejects setup → ended (skip)', () => {
    expect(() => assertCanTransition('setup', 'ended')).toThrow(EncounterInvalidTransitionError);
  });

  it('includes from/to in error extensions', () => {
    let err: EncounterInvalidTransitionError | undefined;
    try {
      assertCanTransition('active', 'setup');
    } catch (error) {
      err = error as EncounterInvalidTransitionError;
    }
    expect(err?.extensions).toEqual({ from: 'active', to: 'setup' });
    expect(err?.code).toBe('ENCOUNTER_INVALID_TRANSITION');
    expect(err?.status).toBe(422);
  });
});

describe('requiresCombatants', () => {
  it('returns true for setup → active', () => {
    expect(requiresCombatants('setup', 'active')).toBe(true);
  });

  it('returns false for active → ended', () => {
    expect(requiresCombatants('active', 'ended')).toBe(false);
  });

  it('returns false for ended → setup (invalid but queried)', () => {
    expect(requiresCombatants('ended', 'setup')).toBe(false);
  });
});

describe('guardTransition', () => {
  it('passes setup → active when hasCombatants=true', () => {
    expect(() => guardTransition('setup', 'active', true)).not.toThrow();
  });

  it('throws ENCOUNTER_NO_COMBATANTS for setup → active when no combatants', () => {
    expect(() => guardTransition('setup', 'active', false)).toThrow(EncounterNoCombatantsError);
  });

  it('ENCOUNTER_NO_COMBATANTS has status 422', () => {
    let err: EncounterNoCombatantsError | undefined;
    try {
      guardTransition('setup', 'active', false);
    } catch (error) {
      err = error as EncounterNoCombatantsError;
    }
    expect(err?.code).toBe('ENCOUNTER_NO_COMBATANTS');
    expect(err?.status).toBe(422);
  });

  it('passes active → ended regardless of combatants', () => {
    expect(() => guardTransition('active', 'ended', false)).not.toThrow();
    expect(() => guardTransition('active', 'ended', true)).not.toThrow();
  });

  it('throws ENCOUNTER_INVALID_TRANSITION for reverse transition before combatant check', () => {
    expect(() => guardTransition('active', 'setup', false)).toThrow(
      EncounterInvalidTransitionError,
    );
  });
});
