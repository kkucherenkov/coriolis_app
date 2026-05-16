import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { MEMBERSHIP_REPO, type IMembershipRepo } from '../../memberships/domain/membership.ports';
import { ChatNotMemberError, ChatTargetNotMemberError } from '../domain/chat.errors';
import { CHAT_READ_CURSOR_REPO, type IChatReadCursorRepo } from '../domain/chat.ports';

import { MarkConversationReadCommand } from './mark-conversation-read.command';

@CommandHandler(MarkConversationReadCommand)
export class MarkConversationReadHandler implements ICommandHandler<
  MarkConversationReadCommand,
  void
> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly membershipRepo: IMembershipRepo,
    @Inject(CHAT_READ_CURSOR_REPO) private readonly readCursorRepo: IChatReadCursorRepo,
  ) {}

  async execute(cmd: MarkConversationReadCommand): Promise<void> {
    // 1. Resolve caller's active membership
    const callerMembership = await this.membershipRepo.findActiveByUser(
      cmd.gameSessionId,
      cmd.userId,
    );
    if (callerMembership === null) {
      throw new ChatNotMemberError();
    }

    // 2. If conversationKey is not 'broadcast', validate the keyed membership
    //    exists in the same session and is still active (leftAt IS NULL).
    if (cmd.conversationKey !== 'broadcast') {
      const partnerMembership = await this.membershipRepo.findById(cmd.conversationKey);
      if (
        partnerMembership === null ||
        partnerMembership.leftAt !== null ||
        partnerMembership.gameSessionId !== cmd.gameSessionId
      ) {
        throw new ChatTargetNotMemberError();
      }
    }

    // 3. Upsert read cursor — purely caller-private state, no event emitted.
    await this.readCursorRepo.upsert({
      membershipId: callerMembership.id,
      conversationKey: cmd.conversationKey,
      lastReadAt: cmd.lastReadAt,
    });
  }
}
