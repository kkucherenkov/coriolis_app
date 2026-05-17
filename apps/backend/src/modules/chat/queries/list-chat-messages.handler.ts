import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { MEMBERSHIP_REPO, type IMembershipRepo } from '../../memberships/domain/membership.ports';
import { ChatNotMemberError } from '../domain/chat.errors';
import {
  CHAT_MESSAGE_REPO,
  type IChatMessageRepo,
  type ChatMessageReadModel,
} from '../domain/chat.ports';

import { ListChatMessagesQuery } from './list-chat-messages.query';

interface ListResult {
  items: ChatMessageReadModel[];
  nextCursor: string | null;
}

@QueryHandler(ListChatMessagesQuery)
export class ListChatMessagesHandler implements IQueryHandler<ListChatMessagesQuery, ListResult> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly membershipRepo: IMembershipRepo,
    @Inject(CHAT_MESSAGE_REPO) private readonly chatRepo: IChatMessageRepo,
  ) {}

  async execute(q: ListChatMessagesQuery): Promise<ListResult> {
    // Step 1: Resolve caller's active membership
    const callerMembership = await this.membershipRepo.findActiveByUser(
      q.gameSessionId,
      q.callerUserId,
    );
    if (!callerMembership) throw new ChatNotMemberError();

    const callerMembershipId = callerMembership.id;

    // Step 2: For whisper conversations, validate the partner is in the same session.
    // Design decision: unknown/inactive partner returns empty result rather than 404
    // to avoid leaking presence — callers cannot distinguish "no messages" from
    // "this member doesn't exist here".
    if (q.conversation !== 'broadcast') {
      const partnerMembership = await this.membershipRepo.findById(q.conversation);
      const partnerInSession =
        partnerMembership !== null &&
        partnerMembership.gameSessionId === q.gameSessionId &&
        partnerMembership.leftAt === null;

      if (!partnerInSession) {
        return { items: [], nextCursor: null };
      }
    }

    // Step 3: Clamp limit to [1, 100]; default 50 when null/undefined/NaN
    const clampedLimit = Math.min(100, Math.max(1, Number.isFinite(q.limit) ? q.limit : 50));

    return this.chatRepo.list({
      gameSessionId: q.gameSessionId,
      callerMembershipId,
      conversation: q.conversation,
      cursor: q.cursor,
      limit: clampedLimit,
    });
  }
}
