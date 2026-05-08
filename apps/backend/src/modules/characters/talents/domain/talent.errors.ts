import { DomainError } from '../../../../common/errors/domain-error';

export class TalentNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'TALENT_NOT_FOUND',
      status: 404,
      title: 'Talent not found',
      detail: `Talent ${id} does not exist.`,
    });
  }
}

export class TalentNotOwnedError extends DomainError {
  constructor(id: string) {
    super({
      code: 'TALENT_NOT_OWNED',
      status: 403,
      title: 'Forbidden',
      detail: `Talent ${id} does not belong to the current user.`,
    });
  }
}
