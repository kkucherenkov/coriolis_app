import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { GAME_SESSION_INVITE_REPO, type IGameSessionInviteRepo } from '../domain/membership.ports';

import { RevokeInviteCommand } from './revoke-invite.command';

@CommandHandler(RevokeInviteCommand)
export class RevokeInviteHandler implements ICommandHandler<RevokeInviteCommand, void> {
  constructor(@Inject(GAME_SESSION_INVITE_REPO) private readonly repo: IGameSessionInviteRepo) {}

  async execute(cmd: RevokeInviteCommand): Promise<void> {
    await this.repo.assertOwner(cmd.gameSessionId, cmd.userId);
    await this.repo.revoke(cmd.gameSessionId);
  }
}
