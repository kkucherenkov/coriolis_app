import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { MEMBERSHIP_REPO, type IMembershipRepo } from '../../memberships/domain/membership.ports';
import { ChatMessageNotFoundError } from '../domain/chat.errors';
import {
  CHAT_MESSAGE_REPO,
  type IChatMessageRepo,
  type ChatMessageReadModel,
} from '../domain/chat.ports';

import { GetChatMessageQuery } from './get-chat-message.query';

@QueryHandler(GetChatMessageQuery)
export class GetChatMessageHandler implements IQueryHandler<
  GetChatMessageQuery,
  ChatMessageReadModel
> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly membershipRepo: IMembershipRepo,
    @Inject(CHAT_MESSAGE_REPO) private readonly chatRepo: IChatMessageRepo,
  ) {}

  async execute(q: GetChatMessageQuery): Promise<ChatMessageReadModel> {
    // Step 1: Load the message — 404 if missing
    const message = await this.chatRepo.findById(q.messageId);
    if (!message) throw new ChatMessageNotFoundError();

    // Step 2: Resolve caller's membership in the message's session.
    // Use 404 (not 403) when no membership — privacy contract: bystanders cannot
    // distinguish "not allowed" from "doesn't exist".
    const callerMembership = await this.membershipRepo.findActiveByUser(
      message.gameSessionId,
      q.callerUserId,
    );
    if (!callerMembership) throw new ChatMessageNotFoundError();

    const callerMembershipId = callerMembership.id;

    // Step 3: Visibility rules
    if (message.kind === 'system' || message.targetMembershipId === null) {
      // Broadcast / system: any active session member may read — already confirmed above
      return message;
    }

    // Whisper: only author or target may read; everyone else (including GMs who are
    // not party to the conversation) gets 404 — non-existence over forbidden.
    const isAuthor = callerMembershipId === message.authorMembershipId;
    const isTarget = callerMembershipId === message.targetMembershipId;
    if (!isAuthor && !isTarget) throw new ChatMessageNotFoundError();

    return message;
  }
}
