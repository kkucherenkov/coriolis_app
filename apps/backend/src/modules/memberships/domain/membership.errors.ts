/**
 * WHY this file exists:
 * Domain errors for the memberships bounded context. Each maps to an
 * RFC 9457 problem+json via HttpExceptionFilter.
 *
 * Codes are namespaced under MEMBERSHIP_* / INVITE_*; clients key off
 * `code` for i18n and retry logic.
 */
import { DomainError } from '../../../common/errors/domain-error';

export class MembershipNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'MEMBERSHIP_NOT_FOUND',
      status: 404,
      title: 'Membership Not Found',
      detail: `Membership ${id} does not exist or has left the session.`,
    });
  }
}

export class MembershipNotAuthorizedError extends DomainError {
  constructor() {
    super({
      code: 'MEMBERSHIP_NOT_AUTHORIZED',
      status: 403,
      title: 'Forbidden',
      detail: 'Caller may not perform this action on this membership.',
    });
  }
}

export class CannotKickGmError extends DomainError {
  constructor() {
    super({
      code: 'CANNOT_KICK_GM',
      status: 422,
      title: 'Cannot Kick GM',
      detail: 'The GM membership cannot be removed from its own session.',
    });
  }
}

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

export class InviteRevokedError extends DomainError {
  constructor() {
    super({
      code: 'INVITE_REVOKED',
      status: 410,
      title: 'Invite Revoked',
      detail: 'This invite link is no longer valid. Ask the GM for a new one.',
    });
  }
}
