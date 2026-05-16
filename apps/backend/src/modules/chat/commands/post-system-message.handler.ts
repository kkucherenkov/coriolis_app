import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import {
  CHAT_MESSAGE_REPO,
  type ChatMessageReadModel,
  type IChatMessageRepo,
} from '../domain/chat.ports';
import { ChatMessagePostedEvent } from '../events/chat-message-posted.event';

import { PostSystemMessageCommand } from './post-system-message.command';

/**
 * Internal-only command handler — NOT exposed via HTTP.
 * Consumed by Stream D event subscribers (Feature 11.7: member-join, roll-pushed system messages).
 *
 * Defensive guard: system messages are always broadcast (targetMembershipId === null).
 * If a caller somehow attaches a targetMembershipId to the command object, the handler
 * throws an Error (programming-error category, not a DomainError) to surface the bug early.
 */
@CommandHandler(PostSystemMessageCommand)
export class PostSystemMessageHandler implements ICommandHandler<
  PostSystemMessageCommand,
  ChatMessageReadModel
> {
  constructor(
    @Inject(CHAT_MESSAGE_REPO) private readonly chatRepo: IChatMessageRepo,
    private readonly eventBus: EventBus,
  ) {}

  async execute(cmd: PostSystemMessageCommand): Promise<ChatMessageReadModel> {
    // Defensive guard — system messages must always be broadcast.
    if ((cmd as unknown as Record<string, unknown>)['targetMembershipId'] != null) {
      throw new Error(
        'System messages must always be broadcast (targetMembershipId must be null).',
      );
    }

    const row = await this.chatRepo.insert({
      gameSessionId: cmd.gameSessionId,
      authorMembershipId: null,
      targetMembershipId: null,
      kind: 'system',
      body: null,
      systemKey: cmd.systemKey,
      systemParams: cmd.systemParams,
    });

    this.eventBus.publish(new ChatMessagePostedEvent(row));

    return row;
  }
}
