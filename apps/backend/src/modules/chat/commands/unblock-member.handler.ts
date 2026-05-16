import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { MEMBERSHIP_REPO, type IMembershipRepo } from '../../memberships/domain/membership.ports';
import { ChatNotMemberError } from '../domain/chat.errors';
import { CHAT_BLOCK_REPO, type IChatBlockRepo } from '../domain/chat.ports';

import { UnblockMemberCommand } from './unblock-member.command';

@CommandHandler(UnblockMemberCommand)
export class UnblockMemberHandler implements ICommandHandler<UnblockMemberCommand, void> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly membershipRepo: IMembershipRepo,
    @Inject(CHAT_BLOCK_REPO) private readonly blockRepo: IChatBlockRepo,
  ) {}

  async execute(cmd: UnblockMemberCommand): Promise<void> {
    // 1. Resolve caller's active membership → 403 if not member
    const callerMembership = await this.membershipRepo.findActiveByUser(
      cmd.gameSessionId,
      cmd.userId,
    );
    if (callerMembership === null) {
      throw new ChatNotMemberError();
    }

    // 2. Delete block — idempotent (repo catches P2025 not-found and no-ops)
    await this.blockRepo.delete({
      gameSessionId: cmd.gameSessionId,
      blockerMembershipId: callerMembership.id,
      blockedMembershipId: cmd.targetMembershipId,
    });
  }
}
