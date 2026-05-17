import { Inject, Optional } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import { AppConfig } from '../../../common/config/app-config';
import {
  ChatBodyEmptyError,
  ChatBodyTooLargeError,
  ChatEditWindowExpiredError,
  ChatMessageNotAuthorizedError,
  ChatMessageNotFoundError,
} from '../domain/chat.errors';
import {
  CHAT_MESSAGE_REPO,
  type ChatMessageReadModel,
  type IChatMessageRepo,
} from '../domain/chat.ports';
import { ChatMessageEditedEvent } from '../events/chat-message-edited.event';

import { EditChatMessageCommand } from './edit-chat-message.command';

@CommandHandler(EditChatMessageCommand)
export class EditChatMessageHandler implements ICommandHandler<
  EditChatMessageCommand,
  ChatMessageReadModel
> {
  constructor(
    @Inject(CHAT_MESSAGE_REPO) private readonly chatRepo: IChatMessageRepo,
    private readonly config: AppConfig,
    private readonly eventBus: EventBus,
    @Optional() private readonly clock: () => Date = () => new Date(),
  ) {}

  async execute(cmd: EditChatMessageCommand): Promise<ChatMessageReadModel> {
    const now = this.clock();

    // 1. Load message — 404 if missing or already deleted
    const message = await this.chatRepo.findById(cmd.messageId);
    if (message?.deletedAt !== null) {
      throw new ChatMessageNotFoundError();
    }

    // 2. Visibility check for whispers — bystanders see 404, not 403
    if (message.targetMembershipId !== null) {
      const isAuthor = message.authorMembershipId === cmd.callerMembershipId;
      const isTarget = message.targetMembershipId === cmd.callerMembershipId;
      if (!isAuthor && !isTarget) {
        throw new ChatMessageNotFoundError();
      }
    }

    // 3. Authorship — only the author can edit
    if (message.authorMembershipId !== cmd.callerMembershipId) {
      throw new ChatMessageNotAuthorizedError();
    }

    // 4. Edit window
    const ageMs = now.getTime() - new Date(message.createdAt).getTime();
    if (ageMs > this.config.chat.editWindowSeconds * 1000) {
      throw new ChatEditWindowExpiredError();
    }

    // 5. Body validation
    const trimmed = cmd.body.trim();
    if (trimmed.length === 0) {
      throw new ChatBodyEmptyError();
    }
    if (Buffer.byteLength(trimmed, 'utf8') > this.config.chat.maxBodyBytes) {
      throw new ChatBodyTooLargeError();
    }

    // 6. Persist
    const updated = await this.chatRepo.updateBody(cmd.messageId, trimmed, now);

    // 7. Emit event
    this.eventBus.publish(new ChatMessageEditedEvent(updated));

    return updated;
  }
}
