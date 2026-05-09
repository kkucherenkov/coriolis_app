/**
 * WHY this file exists:
 * Domain errors are the sole mechanism for signalling business rule violations
 * in this bounded context. HttpExceptionFilter maps them to RFC 9457
 * application/problem+json without any logic in the controller or handler.
 *
 * The `code` slug must match the OpenAPI spec examples (DISPLAY_NAME_EMPTY,
 * DISPLAY_NAME_TOO_LONG). Clients key off `code` for i18n and retry logic.
 */
import { DomainError } from '../../../common/errors/domain-error';

/** Thrown when the authenticated user's row is not found or is soft-deleted. */
export class UserNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'USER_NOT_FOUND',
      status: 404,
      title: 'User not found',
      detail: `No account found for ${id}. The passage may have been sealed.`,
    });
  }
}

/** Thrown when `displayName` is set to an empty string (spec: reject with 400). */
export class DisplayNameEmptyError extends DomainError {
  constructor() {
    super({
      code: 'DISPLAY_NAME_EMPTY',
      status: 400,
      title: 'Validation Error',
      detail: 'Your display name must be between 1 and 80 characters — give your fellow Companions something to call you.',
    });
  }
}

/** Thrown when `displayName` exceeds 80 characters (spec: reject with 400). */
export class DisplayNameTooLongError extends DomainError {
  constructor() {
    super({
      code: 'DISPLAY_NAME_TOO_LONG',
      status: 400,
      title: 'Validation Error',
      detail: 'That display name is too long for the ship manifest — keep it to 80 characters or fewer.',
    });
  }
}

/** Thrown when `theme` is set to a value outside the allowed enum. */
export class InvalidThemeError extends DomainError {
  constructor(value: string) {
    super({
      code: 'INVALID_THEME',
      status: 400,
      title: 'Validation Error',
      detail: `'${value}' is not a valid theme — allowed values are 'dark' and 'high-contrast'.`,
    });
  }
}

/**
 * Thrown when the request body contains read-only fields (`email`, `createdAt`).
 * The global ValidationPipe with `forbidNonWhitelisted: true` will handle
 * unknown fields before this error is needed, but it is defined for handler-level
 * defence in case the pipe is not in effect (e.g. in unit tests).
 */
export class ReadOnlyFieldError extends DomainError {
  constructor(field: string) {
    super({
      code: 'READ_ONLY_FIELD',
      status: 400,
      title: 'Validation Error',
      detail: `Field '${field}' is maintained by the server and cannot be updated directly.`,
    });
  }
}
