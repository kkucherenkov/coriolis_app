/**
 * WHY this file exists:
 * Domain errors for the ships bounded context. Each error maps to an RFC 9457
 * problem+json document via HttpExceptionFilter. Clients key off `code` for
 * i18n and retry logic.
 */
import { DomainError } from '../../../common/errors/domain-error';

export class ShipNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'SHIP_NOT_FOUND',
      status: 404,
      title: 'Not Found',
      detail: `Ship ${id} does not exist.`,
    });
  }
}

export class ShipNotOwnerError extends DomainError {
  constructor(_id: string) {
    super({
      code: 'SHIP_NOT_OWNED',
      status: 403,
      title: 'Forbidden',
      detail: `You do not own this ship.`,
    });
  }
}

export class ShipNameEmptyError extends DomainError {
  constructor() {
    super({
      code: 'SHIP_NAME_EMPTY',
      status: 400,
      title: 'Validation Error',
      detail: 'name must be between 1 and 80 characters',
    });
  }
}

export class ShipNameTooLongError extends DomainError {
  constructor() {
    super({
      code: 'SHIP_NAME_TOO_LONG',
      status: 400,
      title: 'Validation Error',
      detail: 'name must be between 1 and 80 characters',
    });
  }
}

export class ShipNotImplementedError extends DomainError {
  constructor(feature: string) {
    super({
      code: 'NOT_IMPLEMENTED',
      status: 501,
      title: 'Not Implemented',
      detail: `${feature} is not yet implemented.`,
    });
  }
}

export class ShipModuleNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'MODULE_NOT_FOUND',
      status: 404,
      title: 'Not Found',
      detail: `Module ${id} does not exist.`,
    });
  }
}

export class ShipModuleMandatoryError extends DomainError {
  constructor(slot: string) {
    super({
      code: 'SHIP_MODULE_MANDATORY',
      status: 422,
      title: 'Unprocessable Entity',
      detail: `Module with slot ${slot} is mandatory and cannot be removed.`,
    });
  }
}

export class ShipModuleSlotInvalidError extends DomainError {
  constructor(slot: string) {
    super({
      code: 'MODULE_SLOT_INVALID',
      status: 400,
      title: 'Validation Error',
      detail: `slot value ${slot} is not a valid ShipModuleSlot`,
    });
  }
}

export class ShipModuleTypeMismatchError extends DomainError {
  constructor(detail: string) {
    super({
      code: 'MODULE_TYPE_MISMATCH',
      status: 400,
      title: 'Validation Error',
      detail,
    });
  }
}

export class ShipModuleNotOwnedError extends DomainError {
  constructor(_id: string) {
    super({
      code: 'MODULE_NOT_OWNED',
      status: 403,
      title: 'Forbidden',
      detail: 'You do not own this module.',
    });
  }
}
