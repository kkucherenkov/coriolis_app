import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import {
  CannotKickGmError,
  MembershipNotAuthorizedError,
  MembershipNotFoundError,
} from '../domain/membership.errors';
import { MEMBERSHIP_REPO, type IMembershipRepo } from '../domain/membership.ports';
import { MemberLeftEvent } from '../events/member-left.event';

import { LeaveSessionCommand } from './leave-session.command';

@CommandHandler(LeaveSessionCommand)
export class LeaveSessionHandler implements ICommandHandler<LeaveSessionCommand, void> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly repo: IMembershipRepo,
    private readonly bus: EventBus,
  ) {}

  async execute(cmd: LeaveSessionCommand): Promise<void> {
    const member = await this.repo.findById(cmd.membershipId);
    if (!member || member.gameSessionId !== cmd.gameSessionId) {
      throw new MembershipNotFoundError(cmd.membershipId);
    }
    if (member.userId !== cmd.userId) throw new MembershipNotAuthorizedError();
    if (member.role === 'gm') throw new CannotKickGmError();
    await this.repo.softDelete(cmd.membershipId);
    this.bus.publish(new MemberLeftEvent(cmd.membershipId, cmd.gameSessionId, cmd.userId));
  }
}
