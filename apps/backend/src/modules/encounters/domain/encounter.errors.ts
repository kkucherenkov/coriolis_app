/**
 * WHY this file exists:
 * Domain errors for the encounters bounded context. Each error maps to an RFC 9457
 * problem+json document via HttpExceptionFilter. Clients key off `code` for
 * i18n and retry logic.
 */
import { DomainError } from '../../../common/errors/domain-error';

export class EncounterNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'ENCOUNTER_NOT_FOUND',
      status: 404,
      title: 'Not Found',
      detail: `Encounter ${id} does not exist.`,
    });
  }
}

export class EncounterAccessDeniedError extends DomainError {
  constructor(id: string) {
    super({
      code: 'ENCOUNTER_ACCESS_DENIED',
      status: 403,
      title: 'Forbidden',
      detail: `You do not own the game session for encounter ${id}.`,
    });
  }
}

export class EncounterInvalidTransitionError extends DomainError {
  readonly extensions: { from: string; to: string };

  constructor(from: string, to: string) {
    super({
      code: 'ENCOUNTER_INVALID_TRANSITION',
      status: 422,
      title: 'Invalid Status Transition',
      detail: `Cannot transition encounter from '${from}' to '${to}'. Allowed: setup → active, active → ended.`,
    });
    this.extensions = { from, to };
  }
}

export class EncounterNoCombatantsError extends DomainError {
  constructor() {
    super({
      code: 'ENCOUNTER_NO_COMBATANTS',
      status: 422,
      title: 'No Combatants',
      detail:
        'Cannot transition to active: encounter has no combatants. Add at least one combatant first.',
    });
  }
}

export class EncounterInvalidStatusError extends DomainError {
  readonly extensions: { currentStatus: string; expectedStatus: string };

  constructor(currentStatus: string, expectedStatus: string, context: string) {
    super({
      code: 'ENCOUNTER_INVALID_STATUS',
      status: 422,
      title: 'Invalid encounter status',
      detail: `${context} Current status: ${currentStatus}.`,
    });
    this.extensions = { currentStatus, expectedStatus };
  }
}

export class EncounterInitiativeNotRolledError extends DomainError {
  constructor() {
    super({
      code: 'ENCOUNTER_INITIATIVE_NOT_ROLLED',
      status: 422,
      title: 'Initiative not rolled',
      detail: 'activeCombatantId is null — roll initiative before advancing turns.',
    });
  }
}

export class InitiativeDuplicateError extends DomainError {
  constructor(duplicateId: string) {
    super({
      code: 'INITIATIVE_DUPLICATE',
      status: 422,
      title: 'Duplicate combatant id',
      detail: `${duplicateId} appears more than once in combatantIds.`,
    });
  }
}

export class InitiativeUnknownCombatantError extends DomainError {
  constructor(unknownId: string, encounterId: string) {
    super({
      code: 'INITIATIVE_UNKNOWN_COMBATANT',
      status: 422,
      title: 'Unknown combatant',
      detail: `${unknownId} does not belong to encounter ${encounterId}.`,
    });
  }
}

export class InitiativeIncompleteError extends DomainError {
  constructor(missingId: string) {
    super({
      code: 'INITIATIVE_INCOMPLETE',
      status: 422,
      title: 'Incomplete initiative order',
      detail: `combatantIds is missing id: ${missingId}. Every combatant must appear exactly once.`,
    });
  }
}
