import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import {
  MEMBERSHIP_REPO,
  type IMembershipRepo,
  type MyMembershipReadModel,
} from '../domain/membership.ports';

import { GetMyMembershipsQuery } from './get-my-memberships.query';

@QueryHandler(GetMyMembershipsQuery)
export class GetMyMembershipsHandler implements IQueryHandler<
  GetMyMembershipsQuery,
  MyMembershipReadModel[]
> {
  constructor(@Inject(MEMBERSHIP_REPO) private readonly repo: IMembershipRepo) {}

  async execute(q: GetMyMembershipsQuery): Promise<MyMembershipReadModel[]> {
    return this.repo.findActiveSessionsForUser(q.userId);
  }
}
