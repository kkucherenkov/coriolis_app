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
      detail: `Character ${id} does not exist.`,
    });
  }
}

export class CharacterNotOwnedError extends DomainError {
  constructor(id: string) {
    super({
      code: 'CHARACTER_NOT_OWNED',
      status: 403,
      title: 'Forbidden',
      detail: `Character ${id} does not belong to the current user.`,
    });
  }
}

export class CharacterNameEmptyError extends DomainError {
  constructor() {
    super({
      code: 'CHARACTER_NAME_EMPTY',
      status: 400,
      title: 'Validation Error',
      detail: 'name must be between 1 and 80 characters',
    });
  }
}

export class CharacterNameTooLongError extends DomainError {
  constructor() {
    super({
      code: 'CHARACTER_NAME_TOO_LONG',
      status: 400,
      title: 'Validation Error',
      detail: 'name must not exceed 80 characters',
    });
  }
}

export class AttributeOutOfRangeError extends DomainError {
  constructor(attribute: string, value: number) {
    super({
      code: 'ATTRIBUTE_OUT_OF_RANGE',
      status: 422,
      title: 'Validation Error',
      detail: `Attribute '${attribute}' value ${value} is out of range (1–5).`,
    });
  }
}

export class SkillOutOfRangeError extends DomainError {
  constructor(skill: string, value: number) {
    super({
      code: 'SKILL_OUT_OF_RANGE',
      status: 422,
      title: 'Validation Error',
      detail: `Skill '${skill}' value ${value} is out of range (0–5).`,
    });
  }
}

export class IconUnknownError extends DomainError {
  constructor(iconId: string) {
    super({
      code: 'ICON_UNKNOWN',
      status: 400,
      title: 'Validation Error',
      detail: `Unknown icon '${iconId}'. Must be one of the Nine Icons.`,
    });
  }
}
