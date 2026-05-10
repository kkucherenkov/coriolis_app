/**
 * WHY this file exists:
 * Domain errors for the NPCs bounded context. Each error maps to an RFC 9457
 * problem+json document via HttpExceptionFilter. Clients key off `code` for
 * i18n and retry logic.
 */
import { DomainError } from '../../../common/errors/domain-error';

export class NpcNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'NPC_NOT_FOUND',
      status: 404,
      title: 'Not Found',
      detail: `NPC ${id} does not exist.`,
    });
  }
}

export class NpcNotOwnerError extends DomainError {
  constructor(_id: string) {
    super({
      code: 'NPC_NOT_OWNED',
      status: 404,
      title: 'Not Found',
      detail: `NPC does not exist or you do not own it.`,
    });
  }
}

export class NpcNameEmptyError extends DomainError {
  constructor() {
    super({
      code: 'NPC_NAME_EMPTY',
      status: 400,
      title: 'Validation Error',
      detail: 'name must be between 1 and 120 characters',
    });
  }
}

export class NpcNameTooLongError extends DomainError {
  constructor() {
    super({
      code: 'NPC_NAME_TOO_LONG',
      status: 400,
      title: 'Validation Error',
      detail: 'name must be between 1 and 120 characters',
    });
  }
}
