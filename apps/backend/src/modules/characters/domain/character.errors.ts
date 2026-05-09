/**
 * WHY this file exists:
 * Domain errors are the sole mechanism for signalling business rule violations
 * in the characters bounded context. HttpExceptionFilter maps them to RFC 9457
 * application/problem+json. Clients key off `code` for i18n and retry logic.
 */
import { DomainError } from '../../../common/errors/domain-error';

export class CharacterNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'CHARACTER_NOT_FOUND',
      status: 404,
      title: 'Character not found',
      detail: `We could not locate character ${id} — it may have set out for the Far Quarter without telling us.`,
    });
  }
}

export class CharacterNotOwnedError extends DomainError {
  constructor(id: string) {
    super({
      code: 'CHARACTER_NOT_OWNED',
      status: 403,
      title: 'Forbidden',
      detail: `Character ${id} does not belong to your crew. Access denied.`,
    });
  }
}

export class CharacterNameEmptyError extends DomainError {
  constructor() {
    super({
      code: 'CHARACTER_NAME_EMPTY',
      status: 400,
      title: 'Validation Error',
      detail: 'Every Companion needs a name — provide between 1 and 80 characters.',
    });
  }
}

export class CharacterNameTooLongError extends DomainError {
  constructor() {
    super({
      code: 'CHARACTER_NAME_TOO_LONG',
      status: 400,
      title: 'Validation Error',
      detail: 'That name is too long for the manifest — keep it to 80 characters or fewer.',
    });
  }
}

export class AttributeOutOfRangeError extends DomainError {
  constructor(attribute: string, value: number) {
    super({
      code: 'ATTRIBUTE_OUT_OF_RANGE',
      status: 422,
      title: 'Validation Error',
      detail: `Attribute '${attribute}' value ${String(value)} falls outside the permitted range (1–5). Check the character rules.`,
    });
  }
}

export class SkillOutOfRangeError extends DomainError {
  constructor(skill: string, value: number) {
    super({
      code: 'SKILL_OUT_OF_RANGE',
      status: 422,
      title: 'Validation Error',
      detail: `Skill '${skill}' value ${String(value)} is not within the permitted range (0–5).`,
    });
  }
}

export class IconUnknownError extends DomainError {
  constructor(iconId: string) {
    super({
      code: 'ICON_UNKNOWN',
      status: 400,
      title: 'Validation Error',
      detail: `'${iconId}' is not one of the Nine Icons recognised in the Third Horizon.`,
    });
  }
}

/**
 * Thrown when the client attempts to set a server-computed read-only field.
 * Belt-and-suspenders defence on top of the OpenAPI spec's readOnly markers.
 * PRD §5.2: hp.max, mp.max, encumbrance.max are derived — never user-writable.
 */
export class ReadOnlyFieldError extends DomainError {
  constructor(field: string) {
    super({
      code: 'READ_ONLY_FIELD',
      status: 422,
      title: 'Validation Error',
      detail: `Field '${field}' is calculated by the server and cannot be set directly.`,
    });
  }
}

/**
 * Thrown when the client attempts an illegal status transition.
 * Only draft → active (forge) is permitted. The reverse (active → draft)
 * is a product rule violation — ADR 0002.
 */
export class InvalidStatusTransitionError extends DomainError {
  constructor(from: string, to: string) {
    super({
      code: 'INVALID_STATUS_TRANSITION',
      status: 422,
      title: 'Invalid Status Transition',
      detail: `Cannot transition character status from '${from}' to '${to}'. Only draft → active is permitted.`,
    });
  }
}
