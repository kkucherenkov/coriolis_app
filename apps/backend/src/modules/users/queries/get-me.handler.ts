/**
 * WHY this file exists:
 * Query handlers contain read-side logic. They receive a Query, fetch data
 * through the repo port, and return a typed read model. They never mutate state.
 *
 * Soft-delete: `findActiveById` already filters `deletedAt IS NOT NULL`, so a
 * null return here always means 404 — sessions would be revoked at deletion
 * time, making this a defence-in-depth check.
 */
import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { UserNotFoundError } from '../domain/user.errors';
import { USER_REPO } from '../domain/user.ports';

import { GetMeQuery } from './get-me.query';

import type { IUserRepo, MeReadModel } from '../domain/user.ports';

@QueryHandler(GetMeQuery)
export class GetMeHandler implements IQueryHandler<GetMeQuery, MeReadModel> {
  constructor(@Inject(USER_REPO) private readonly repo: IUserRepo) {}

  async execute(query: GetMeQuery): Promise<MeReadModel> {
    const user = await this.repo.findActiveById(query.userId);
    if (!user) {
      throw new UserNotFoundError(query.userId);
    }
    return user;
  }
}
