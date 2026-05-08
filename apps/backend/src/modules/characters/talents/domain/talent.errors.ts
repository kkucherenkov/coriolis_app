import { DomainError } from '../../../../common/errors/domain-error';

export class TalentNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'TALENT_NOT_FOUND',
      status: 404,
      title: 'Talent not found',
      detail: `Talent ${id} could not be found — it may have been struck from the record.`,
    });
  }
}

export class TalentNotOwnedError extends DomainError {
  constructor(id: string) {
    super({
      code: 'TALENT_NOT_OWNED',
      status: 403,
      title: 'Forbidden',
      detail: `Talent ${id} does not belong to your character. Access denied.`,
    });
  }
}
