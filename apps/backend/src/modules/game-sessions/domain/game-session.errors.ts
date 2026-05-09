/**
 * WHY this file exists:
 * Domain errors for the game-sessions bounded context. Each error maps to
 * an RFC 9457 problem+json document via HttpExceptionFilter.
 * Clients key off `code` for i18n and retry logic.
 */
import { DomainError } from '../../../common/errors/domain-error';

export class GameSessionNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'GAME_SESSION_NOT_FOUND',
      status: 404,
      title: 'Game Session Not Found',
      detail: `Game session ${id} does not exist or has been deleted.`,
    });
  }
}

export class GameSessionNotOwnerError extends DomainError {
  constructor(id: string) {
    super({
      code: 'GAME_SESSION_NOT_OWNER',
      status: 403,
      title: 'Forbidden',
      detail: `Game session ${id} does not belong to you.`,
    });
  }
}

export class GameSessionNameEmptyError extends DomainError {
  constructor() {
    super({
      code: 'GAME_SESSION_NAME_EMPTY',
      status: 400,
      title: 'Validation Error',
      detail: 'Game session name must be between 1 and 80 characters.',
    });
  }
}

export class GameSessionNameTooLongError extends DomainError {
  constructor() {
    super({
      code: 'GAME_SESSION_NAME_TOO_LONG',
      status: 400,
      title: 'Validation Error',
      detail: 'Game session name must not exceed 80 characters.',
    });
  }
}

/**
 * Thrown when a character being assigned to a session does not belong to
 * the caller. Cross-user assignment is forbidden in v1.
 */
export class CharacterNotOwnedError extends DomainError {
  constructor(characterId: string) {
    super({
      code: 'CHARACTER_NOT_OWNED',
      status: 403,
      title: 'Forbidden',
      detail: `Character ${characterId} does not belong to you.`,
    });
  }
}

/**
 * Thrown when a status transition is attempted that is not permitted.
 * Both active → archived and archived → active are allowed; anything
 * else (e.g. providing an unknown string) hits this error.
 */
export class InvalidGameSessionStatusTransitionError extends DomainError {
  constructor(from: string, to: string) {
    super({
      code: 'INVALID_GAME_SESSION_STATUS_TRANSITION',
      status: 422,
      title: 'Invalid Status Transition',
      detail: `Cannot transition game session status from '${from}' to '${to}'.`,
    });
  }
}
