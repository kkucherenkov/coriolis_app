import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import { CharacterNotOwnedError, InviteNotFoundError } from '../domain/membership.errors';
import { hashInviteToken } from '../domain/invite-token';
import {
  GAME_SESSION_INVITE_REPO,
  MEMBERSHIP_REPO,
  type IGameSessionInviteRepo,
  type IMembershipRepo,
  type MembershipReadModel,
} from '../domain/membership.ports';
import { MemberJoinedEvent } from '../events/member-joined.event';
import { CHARACTER_OWNERSHIP, type ICharacterOwnership } from './link-character.handler';

import { AcceptInviteCommand } from './accept-invite.command';

@CommandHandler(AcceptInviteCommand)
export class AcceptInviteHandler implements ICommandHandler<
  AcceptInviteCommand,
  MembershipReadModel
> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly mRepo: IMembershipRepo,
    @Inject(GAME_SESSION_INVITE_REPO) private readonly iRepo: IGameSessionInviteRepo,
    @Inject(CHARACTER_OWNERSHIP) private readonly charOwnership: ICharacterOwnership,
    private readonly bus: EventBus,
  ) {}

  async execute(cmd: AcceptInviteCommand): Promise<MembershipReadModel> {
    const tokenHash = hashInviteToken(cmd.token);
    const session = await this.iRepo.findSessionByTokenHash(tokenHash);
    if (!session) throw new InviteNotFoundError(cmd.token);

    const existing = await this.mRepo.findActiveByUser(session.gameSessionId, cmd.userId);
    if (existing) return existing;

    if (cmd.characterId) {
      const owned = await this.charOwnership.isOwnedBy(cmd.characterId, cmd.userId);
      if (!owned) throw new CharacterNotOwnedError(cmd.characterId);
    }

    const membership = await this.mRepo.insert({
      gameSessionId: session.gameSessionId,
      userId: cmd.userId,
      role: 'player',
      characterId: cmd.characterId,
    });

    this.bus.publish(new MemberJoinedEvent(membership.id, session.gameSessionId, cmd.userId));

    return membership;
  }
}
