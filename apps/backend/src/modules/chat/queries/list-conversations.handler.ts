import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { MEMBERSHIP_REPO, type IMembershipRepo } from '../../memberships/domain/membership.ports';
import { ChatNotMemberError } from '../domain/chat.errors';
import {
  CHAT_MESSAGE_REPO,
  CHAT_READ_CURSOR_REPO,
  type IChatMessageRepo,
  type IChatReadCursorRepo,
  type ConversationSummaryReadModel,
  type ConversationKey,
} from '../domain/chat.ports';

import { ListConversationsQuery } from './list-conversations.query';

interface ListConversationsResult {
  items: ConversationSummaryReadModel[];
}

@QueryHandler(ListConversationsQuery)
export class ListConversationsHandler implements IQueryHandler<
  ListConversationsQuery,
  ListConversationsResult
> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly membershipRepo: IMembershipRepo,
    @Inject(CHAT_MESSAGE_REPO) private readonly chatRepo: IChatMessageRepo,
    @Inject(CHAT_READ_CURSOR_REPO) private readonly cursorRepo: IChatReadCursorRepo,
  ) {}

  async execute(q: ListConversationsQuery): Promise<ListConversationsResult> {
    // Step 1: Resolve caller's active membership
    const callerMembership = await this.membershipRepo.findActiveByUser(
      q.gameSessionId,
      q.callerUserId,
    );
    if (!callerMembership) throw new ChatNotMemberError();

    const callerMembershipId = callerMembership.id;

    // Step 2: Load whisper summaries from repo (unreadCount = 0 placeholder from repo)
    const whispers = await this.chatRepo.listConversations({
      gameSessionId: q.gameSessionId,
      callerMembershipId,
    });

    // Step 3: Collect all conversation keys for a single read-cursor batch lookup
    const conversationKeys: ConversationKey[] = [
      'broadcast',
      ...whispers.map((w) => w.conversationKey),
    ];

    const cursorMap = await this.cursorRepo.getMap({
      membershipId: callerMembershipId,
      keys: conversationKeys,
    });

    // Step 4: Compute unread counts + lastMessageAt for every conversation.
    // countNewerThan returns { count, lastMessageAt } in one Prisma call:
    // - count is filtered by `after` (the read cursor)
    // - lastMessageAt is the max createdAt across ALL messages in the conversation
    //   (no after filter), so the broadcast row always has an accurate lastMessageAt.
    const broadcastCursor = cursorMap.get('broadcast') ?? null;
    const { count: broadcastUnread, lastMessageAt: broadcastLastAt } =
      await this.chatRepo.countNewerThan({
        gameSessionId: q.gameSessionId,
        conversation: 'broadcast',
        callerMembershipId,
        after: broadcastCursor,
      });

    // Step 5: Build whisper rows with real unread counts
    const enrichedWhispers: ConversationSummaryReadModel[] = await Promise.all(
      whispers.map(async (w) => {
        const cursor = cursorMap.get(w.conversationKey) ?? null;
        const { count: unreadCount } = await this.chatRepo.countNewerThan({
          gameSessionId: q.gameSessionId,
          conversation: w.conversationKey,
          callerMembershipId,
          after: cursor,
        });
        return { ...w, unreadCount };
      }),
    );

    // Step 6: Prepend synthetic broadcast row — always first
    const broadcastRow: ConversationSummaryReadModel = {
      conversationKey: 'broadcast',
      kind: 'broadcast',
      partnerMembershipId: null,
      partnerDisplayName: null,
      partnerCharacterName: null,
      lastMessageAt: broadcastLastAt ? broadcastLastAt.toISOString() : null,
      unreadCount: broadcastUnread,
    };

    return { items: [broadcastRow, ...enrichedWhispers] };
  }
}
