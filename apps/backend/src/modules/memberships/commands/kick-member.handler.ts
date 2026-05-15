import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import { MemberKickedEvent } from '../events/member-kicked.event';
import { CannotKickGmError, MembershipNotFoundError } from '../domain/membership.errors';
import {
  GAME_SESSION_INVITE_REPO,
  MEMBERSHIP_REPO,
  type IGameSessionInviteRepo,
  type IMembershipRepo,
} from '../domain/membership.ports';

import { KickMemberCommand } from './kick-member.command';

@CommandHandler(KickMemberCommand)
export class KickMemberHandler implements ICommandHandler<KickMemberCommand, void> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly mRepo: IMembershipRepo,
    @Inject(GAME_SESSION_INVITE_REPO) private readonly iRepo: IGameSessionInviteRepo,
    private readonly bus: EventBus,
  ) {}

  async execute(cmd: KickMemberCommand): Promise<void> {
    await this.iRepo.assertOwner(cmd.gameSessionId, cmd.callerUserId);
    const member = await this.mRepo.findById(cmd.membershipId);
    if (!member || member.gameSessionId !== cmd.gameSessionId) {
      throw new MembershipNotFoundError(cmd.membershipId);
    }
    if (member.role === 'gm') throw new CannotKickGmError();
    await this.mRepo.softDelete(cmd.membershipId);
    this.bus.publish(new MemberKickedEvent(cmd.membershipId, cmd.gameSessionId, member.userId));
  }
}
