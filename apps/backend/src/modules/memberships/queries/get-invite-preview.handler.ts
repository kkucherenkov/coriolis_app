import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { InviteNotFoundError } from '../domain/membership.errors';
import { hashInviteToken } from '../domain/invite-token';
import {
  GAME_SESSION_INVITE_REPO,
  MEMBERSHIP_REPO,
  type IGameSessionInviteRepo,
  type IMembershipRepo,
  type InvitePreviewReadModel,
} from '../domain/membership.ports';

import { GetInvitePreviewQuery } from './get-invite-preview.query';

export const DISPLAY_NAME_FETCHER = Symbol('DISPLAY_NAME_FETCHER');

@QueryHandler(GetInvitePreviewQuery)
export class GetInvitePreviewHandler implements IQueryHandler<
  GetInvitePreviewQuery,
  InvitePreviewReadModel
> {
  constructor(
    @Inject(GAME_SESSION_INVITE_REPO) private readonly iRepo: IGameSessionInviteRepo,
    @Inject(MEMBERSHIP_REPO) private readonly mRepo: IMembershipRepo,
    @Inject(DISPLAY_NAME_FETCHER)
    private readonly fetchDisplayName: (userId: string) => Promise<string>,
  ) {}

  async execute(q: GetInvitePreviewQuery): Promise<InvitePreviewReadModel> {
    const tokenHash = hashInviteToken(q.token);
    const session = await this.iRepo.findSessionByTokenHash(tokenHash);
    if (!session) throw new InviteNotFoundError(q.token);

    const [gmDisplayName, existingMembership] = await Promise.all([
      this.fetchDisplayName(session.gmUserId),
      q.callerUserId
        ? this.mRepo.findActiveByUser(session.gameSessionId, q.callerUserId)
        : Promise.resolve(null),
    ]);

    return {
      sessionName: session.sessionName,
      gmDisplayName,
      alreadyJoined: existingMembership !== null,
    };
  }
}
