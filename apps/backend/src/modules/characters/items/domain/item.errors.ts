import { DomainError } from '../../../../common/errors/domain-error';

export class ItemNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'ITEM_NOT_FOUND',
      status: 404,
      title: 'Item not found',
      detail: `Item ${id} does not exist.`,
    });
  }
}

export class ItemNotOwnedError extends DomainError {
  constructor(id: string) {
    super({
      code: 'ITEM_NOT_OWNED',
      status: 403,
      title: 'Forbidden',
      detail: `Item ${id} does not belong to the current user.`,
    });
  }
}

export class ItemTypeMismatchError extends DomainError {
  constructor(id: string) {
    super({
      code: 'ITEM_TYPE_MISMATCH',
      status: 400,
      title: 'Validation Error',
      detail: `Item ${id} type cannot be changed after creation.`,
    });
  }
}
