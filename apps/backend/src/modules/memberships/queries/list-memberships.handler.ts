import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { MembershipNotAuthorizedError } from '../domain/membership.errors';
import {
  MEMBERSHIP_REPO,
  type IMembershipRepo,
  type MembershipReadModel,
} from '../domain/membership.ports';

import { ListMembershipsQuery } from './list-memberships.query';

@QueryHandler(ListMembershipsQuery)
export class ListMembershipsHandler implements IQueryHandler<
  ListMembershipsQuery,
  MembershipReadModel[]
> {
  constructor(@Inject(MEMBERSHIP_REPO) private readonly repo: IMembershipRepo) {}

  async execute(q: ListMembershipsQuery): Promise<MembershipReadModel[]> {
    const callerMembership = await this.repo.findActiveByUser(q.gameSessionId, q.callerUserId);
    if (!callerMembership) throw new MembershipNotAuthorizedError();
    return this.repo.listActive(q.gameSessionId);
  }
}
