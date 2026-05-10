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
