import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { MEMBERSHIP_REPO, type IMembershipRepo } from '../../memberships/domain/membership.ports';
import { ChatNotMemberError } from '../domain/chat.errors';
import {
  CHAT_BLOCK_REPO,
  type IChatBlockRepo,
  type ChatBlockSummaryReadModel,
} from '../domain/chat.ports';

import { ListBlocksQuery } from './list-blocks.query';

@QueryHandler(ListBlocksQuery)
export class ListBlocksHandler implements IQueryHandler<
  ListBlocksQuery,
  ChatBlockSummaryReadModel[]
> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly membershipRepo: IMembershipRepo,
    @Inject(CHAT_BLOCK_REPO) private readonly blockRepo: IChatBlockRepo,
  ) {}

  async execute(q: ListBlocksQuery): Promise<ChatBlockSummaryReadModel[]> {
    const callerMembership = await this.membershipRepo.findActiveByUser(
      q.gameSessionId,
      q.callerUserId,
    );
    if (!callerMembership) throw new ChatNotMemberError();

    return this.blockRepo.listForBlocker({
      gameSessionId: q.gameSessionId,
      blockerMembershipId: callerMembership.id,
    });
  }
}
