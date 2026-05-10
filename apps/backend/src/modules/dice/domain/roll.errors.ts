/**
 * WHY this file exists:
 * Domain errors for the dice bounded context. HttpExceptionFilter maps them
 * to RFC 9457 application/problem+json. Clients key off `code` for i18n and
 * retry logic.
 */
import { DomainError } from '../../../common/errors/domain-error';

export class RollNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'ROLL_NOT_FOUND',
      status: 404,
      title: 'Roll not found',
      detail: `Roll ${id} does not exist — it may have drifted into the Far Quarter.`,
    });
  }
}

export class RollNotPushableError extends DomainError {
  constructor(reason: 'ALREADY_PUSHED' | 'EXHAUSTED') {
    const detail =
      reason === 'ALREADY_PUSHED'
        ? 'This roll has already been pushed once. Dice are final.'
        : 'The character is Exhausted and cannot push rolls (PRD §10).';

    super({
      code: 'ROLL_NOT_PUSHABLE',
      status: 422,
      title: 'Roll cannot be pushed',
      detail,
    });
  }
}

export class RollPoolOutOfRangeError extends DomainError {
  constructor(pool: number) {
    super({
      code: 'ROLL_POOL_OUT_OF_RANGE',
      status: 422,
      title: 'Validation Error',
      detail: `Pool ${String(pool)} is outside the permitted range (0–20).`,
    });
  }
}

export class PushNotAllowedOnNonSkillRollError extends DomainError {
  constructor(kind: string) {
    super({
      code: 'PUSH_NOT_ALLOWED_ON_NON_SKILL_ROLL',
      status: 400,
      title: 'Validation Error',
      detail: `Push is only allowed on skill rolls (ST3001 ГЛАВА 3 §«Вознесение молитв»). The roll kind is '${kind}'.`,
    });
  }
}
