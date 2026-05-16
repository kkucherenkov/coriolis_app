import { Inject, Optional } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import { ChatMessageNotAuthorizedError, ChatMessageNotFoundError } from '../domain/chat.errors';
import { CHAT_MESSAGE_REPO, type IChatMessageRepo } from '../domain/chat.ports';
import { ChatMessageDeletedEvent } from '../events/chat-message-deleted.event';

import { DeleteChatMessageCommand } from './delete-chat-message.command';

@CommandHandler(DeleteChatMessageCommand)
export class DeleteChatMessageHandler implements ICommandHandler<DeleteChatMessageCommand, void> {
  constructor(
    @Inject(CHAT_MESSAGE_REPO) private readonly chatRepo: IChatMessageRepo,
    private readonly eventBus: EventBus,
    @Optional() private readonly clock: () => Date = () => new Date(),
  ) {}

  async execute(cmd: DeleteChatMessageCommand): Promise<void> {
    const now = this.clock();

    // 1. Load message — 404 if missing or already deleted
    const message = await this.chatRepo.findById(cmd.messageId);
    if (message === null || message.deletedAt !== null) {
      throw new ChatMessageNotFoundError();
    }

    // 2. Visibility check — whisper bystanders (including GM) see 404, not 403.
    //    GM has no visibility into whispers they are not party to — privacy contract.
    if (message.targetMembershipId !== null) {
      const isAuthor = message.authorMembershipId === cmd.callerMembershipId;
      const isTarget = message.targetMembershipId === cmd.callerMembershipId;
      if (!isAuthor && !isTarget) {
        throw new ChatMessageNotFoundError();
      }
    }

    // 3. Kind-aware authz:
    //    - Broadcast: allow if caller is author OR caller is GM.
    //    - Whisper: allow ONLY if caller is author (GM bypass is explicitly denied —
    //      see Feature 11.6.1.b; GM would have hit the visibility filter above first).
    if (message.targetMembershipId === null) {
      // Broadcast
      const isAuthor = message.authorMembershipId === cmd.callerMembershipId;
      if (!isAuthor && !cmd.isCallerGm) {
        throw new ChatMessageNotAuthorizedError();
      }
    } else {
      // Whisper — only author can delete; target cannot delete
      if (message.authorMembershipId !== cmd.callerMembershipId) {
        throw new ChatMessageNotAuthorizedError();
      }
    }

    // 4. Soft-delete
    await this.chatRepo.softDelete(cmd.messageId, now);

    // 5. Emit event
    this.eventBus.publish(
      new ChatMessageDeletedEvent({
        id: message.id,
        gameSessionId: message.gameSessionId,
        targetMembershipId: message.targetMembershipId,
        deletedAt: now.toISOString(),
      }),
    );
  }
}
