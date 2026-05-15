import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { AppConfig } from '../../../common/config/app-config';
import {
  generateInviteToken as defaultGenerate,
  hashInviteToken as defaultHash,
} from '../domain/invite-token';
import { GAME_SESSION_INVITE_REPO, type IGameSessionInviteRepo } from '../domain/membership.ports';

import { RotateInviteCommand } from './rotate-invite.command';

export interface RotateInviteResult {
  token: string;
  url: string;
  rotatedAt: string;
}

@CommandHandler(RotateInviteCommand)
export class RotateInviteHandler implements ICommandHandler<
  RotateInviteCommand,
  RotateInviteResult
> {
  constructor(
    @Inject(GAME_SESSION_INVITE_REPO) private readonly repo: IGameSessionInviteRepo,
    private readonly config: AppConfig,
    private readonly generate: () => string = defaultGenerate,
    private readonly hash: (s: string) => string = defaultHash,
  ) {}

  async execute(cmd: RotateInviteCommand): Promise<RotateInviteResult> {
    await this.repo.assertOwner(cmd.gameSessionId, cmd.userId);
    const token = this.generate();
    const hash = this.hash(token);
    const { rotatedAt } = await this.repo.rotate(cmd.gameSessionId, hash, cmd.userId);
    return {
      token,
      url: `${this.config.webHost}/app/sessions/join/${token}`,
      rotatedAt,
    };
  }
}
