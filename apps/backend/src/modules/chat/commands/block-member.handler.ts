import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { MEMBERSHIP_REPO, type IMembershipRepo } from '../../memberships/domain/membership.ports';
import {
  ChatMessageNotAuthorizedError,
  ChatNotMemberError,
  ChatTargetNotMemberError,
} from '../domain/chat.errors';
import { CHAT_BLOCK_REPO, type IChatBlockRepo } from '../domain/chat.ports';

import { BlockMemberCommand } from './block-member.command';

@CommandHandler(BlockMemberCommand)
export class BlockMemberHandler implements ICommandHandler<BlockMemberCommand, void> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly membershipRepo: IMembershipRepo,
    @Inject(CHAT_BLOCK_REPO) private readonly blockRepo: IChatBlockRepo,
  ) {}

  async execute(cmd: BlockMemberCommand): Promise<void> {
    // 1. Resolve caller's active membership → 403 if not member
    const callerMembership = await this.membershipRepo.findActiveByUser(
      cmd.gameSessionId,
      cmd.userId,
    );
    if (callerMembership === null) {
      throw new ChatNotMemberError();
    }

    // 2. Refuse self-block — reuse ChatMessageNotAuthorizedError with 403
    if (callerMembership.id === cmd.targetMembershipId) {
      throw new ChatMessageNotAuthorizedError();
    }

    // 3. Validate target membership exists in same session and is active
    const targetMembership = await this.membershipRepo.findById(cmd.targetMembershipId);
    if (
      targetMembership === null ||
      targetMembership.leftAt !== null ||
      targetMembership.gameSessionId !== cmd.gameSessionId
    ) {
      throw new ChatTargetNotMemberError();
    }

    // 4. Insert block — idempotent (repo catches P2002 unique violation and no-ops)
    await this.blockRepo.insert({
      gameSessionId: cmd.gameSessionId,
      blockerMembershipId: callerMembership.id,
      blockedMembershipId: cmd.targetMembershipId,
    });
  }
}
