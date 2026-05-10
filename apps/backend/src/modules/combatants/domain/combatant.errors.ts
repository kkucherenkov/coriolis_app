/**
 * WHY this file exists:
 * Domain errors for the combatants bounded context. Each error maps to an RFC 9457
 * problem+json document via HttpExceptionFilter. Clients key off `code` for
 * i18n and retry logic.
 *
 * Error codes match the OpenAPI spec (openapi.yaml v0.16.0) exactly.
 */
import { DomainError } from '../../../common/errors/domain-error';

/** 404 — combatant id does not exist or caller does not own its encounter. */
export class CombatantNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'COMBATANT_NOT_FOUND',
      status: 404,
      title: 'Not Found',
      detail: `Combatant ${id} does not exist.`,
    });
  }
}

/**
 * 422 — a combatant with the same (combatantType, sourceId) pair is already
 * on the encounter.
 */
export class CombatantDuplicateError extends DomainError {
  constructor(combatantType: string, sourceId: string) {
    super({
      code: 'COMBATANT_DUPLICATE',
      status: 422,
      title: 'Unprocessable Entity',
      detail: `Combatant with type '${combatantType}' and sourceId '${sourceId}' is already on this encounter.`,
    });
  }
}

/**
 * 422 — the referenced source entity (Character or Npc) does not exist.
 */
export class CombatantSourceNotFoundError extends DomainError {
  constructor(sourceId: string) {
    super({
      code: 'COMBATANT_SOURCE_NOT_FOUND',
      status: 422,
      title: 'Unprocessable Entity',
      detail: `The source entity ${sourceId} does not exist.`,
    });
  }
}

/**
 * 422 — caller does not own the source Character or Npc.
 */
export class CombatantSourceNotOwnedError extends DomainError {
  constructor(sourceId: string) {
    super({
      code: 'COMBATANT_SOURCE_NOT_OWNED',
      status: 422,
      title: 'Unprocessable Entity',
      detail: `You do not own the source entity ${sourceId}.`,
    });
  }
}

/**
 * 422 — combatants can only be added or removed while encounter is in setup status.
 */
export class EncounterLockedForCombatError extends DomainError {
  constructor() {
    super({
      code: 'ENCOUNTER_LOCKED_FOR_COMBAT',
      status: 422,
      title: 'Unprocessable Entity',
      detail: 'Combatants can only be added or removed while the encounter is in setup status.',
    });
  }
}

/**
 * 422 — combatant mutations are not allowed when the encounter is ended.
 */
export class EncounterEndedError extends DomainError {
  constructor(encounterId: string) {
    super({
      code: 'ENCOUNTER_ENDED',
      status: 422,
      title: 'Unprocessable Entity',
      detail: `Encounter ${encounterId} is ended; combatant mutations are not allowed.`,
    });
  }
}
