import { Inject, Optional } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import { AppConfig } from '../../../common/config/app-config';
import { MEMBERSHIP_REPO, type IMembershipRepo } from '../../memberships/domain/membership.ports';
import {
  ChatBodyEmptyError,
  ChatBodyTooLargeError,
  ChatTargetBlockedError,
  ChatTargetNotMemberError,
} from '../domain/chat.errors';
import {
  CHAT_BLOCK_REPO,
  CHAT_MESSAGE_REPO,
  CHAT_RATE_LIMITER,
  type IChatBlockRepo,
  type IChatMessageRepo,
  type IChatRateLimiter,
  type ChatMessageReadModel,
} from '../domain/chat.ports';
import { ChatMessagePostedEvent } from '../events/chat-message-posted.event';

import { PostChatMessageCommand } from './post-chat-message.command';

@CommandHandler(PostChatMessageCommand)
export class PostChatMessageHandler implements ICommandHandler<
  PostChatMessageCommand,
  ChatMessageReadModel
> {
  constructor(
    @Inject(CHAT_MESSAGE_REPO) private readonly chatRepo: IChatMessageRepo,
    @Inject(MEMBERSHIP_REPO) private readonly membershipRepo: IMembershipRepo,
    @Inject(CHAT_BLOCK_REPO) private readonly blockRepo: IChatBlockRepo,
    @Inject(CHAT_RATE_LIMITER) private readonly rateLimiter: IChatRateLimiter,
    private readonly config: AppConfig,
    private readonly eventBus: EventBus,
    @Optional() private readonly clock: () => Date = () => new Date(),
  ) {}

  async execute(cmd: PostChatMessageCommand): Promise<ChatMessageReadModel> {
    const now = this.clock();

    // 1. Rate limit check — runs before any body validation
    await this.rateLimiter.consume(cmd.userId, now);

    // 2. Trim body; validate empty + size
    const trimmed = cmd.body.trim();
    if (trimmed.length === 0) {
      throw new ChatBodyEmptyError();
    }
    if (Buffer.byteLength(trimmed, 'utf8') > this.config.chat.maxBodyBytes) {
      throw new ChatBodyTooLargeError();
    }

    // 3. If whisper: validate target membership + block check
    if (cmd.targetMembershipId !== null) {
      const target = await this.membershipRepo.findById(cmd.targetMembershipId);
      if (target === null || target.leftAt !== null || target.gameSessionId !== cmd.gameSessionId) {
        throw new ChatTargetNotMemberError();
      }

      const isBlocked = await this.blockRepo.exists({
        gameSessionId: cmd.gameSessionId,
        blockerMembershipId: cmd.targetMembershipId,
        blockedMembershipId: cmd.authorMembershipId,
      });
      if (isBlocked) {
        throw new ChatTargetBlockedError();
      }
    }

    // 4. Persist
    const row = await this.chatRepo.insert({
      gameSessionId: cmd.gameSessionId,
      authorMembershipId: cmd.authorMembershipId,
      targetMembershipId: cmd.targetMembershipId,
      kind: 'text',
      body: trimmed,
      systemKey: null,
      systemParams: null,
    });

    // 5. Emit event
    this.eventBus.publish(new ChatMessagePostedEvent(row));

    return row;
  }
}
