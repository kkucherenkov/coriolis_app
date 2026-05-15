import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import {
  GAME_SESSION_INVITE_REPO,
  type IGameSessionInviteRepo,
  type InviteMetadataReadModel,
} from '../domain/membership.ports';

import { GetInviteMetadataQuery } from './get-invite-metadata.query';

@QueryHandler(GetInviteMetadataQuery)
export class GetInviteMetadataHandler implements IQueryHandler<
  GetInviteMetadataQuery,
  InviteMetadataReadModel
> {
  constructor(@Inject(GAME_SESSION_INVITE_REPO) private readonly repo: IGameSessionInviteRepo) {}

  async execute(q: GetInviteMetadataQuery): Promise<InviteMetadataReadModel> {
    await this.repo.assertOwner(q.gameSessionId, q.userId);
    return this.repo.getMetadata(q.gameSessionId);
  }
}
