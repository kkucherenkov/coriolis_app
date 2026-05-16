import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import {
  CharacterNotOwnedError,
  MembershipNotAuthorizedError,
  MembershipNotFoundError,
} from '../domain/membership.errors';
import {
  MEMBERSHIP_REPO,
  type IMembershipRepo,
  type MembershipReadModel,
} from '../domain/membership.ports';
import { CharacterLinkedEvent } from '../events/character-linked.event';

import { LinkCharacterCommand } from './link-character.command';

export const CHARACTER_OWNERSHIP = Symbol('CHARACTER_OWNERSHIP');

export interface ICharacterOwnership {
  isOwnedBy(characterId: string, userId: string): Promise<boolean>;
}

@CommandHandler(LinkCharacterCommand)
export class LinkCharacterHandler implements ICommandHandler<
  LinkCharacterCommand,
  MembershipReadModel
> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly repo: IMembershipRepo,
    @Inject(CHARACTER_OWNERSHIP) private readonly ownership: ICharacterOwnership,
    private readonly bus: EventBus,
  ) {}

  async execute(cmd: LinkCharacterCommand): Promise<MembershipReadModel> {
    const member = await this.repo.findById(cmd.membershipId);
    if (member?.gameSessionId !== cmd.gameSessionId) {
      throw new MembershipNotFoundError(cmd.membershipId);
    }
    if (member.userId !== cmd.callerUserId) throw new MembershipNotAuthorizedError();
    if (cmd.characterId !== null) {
      const ok = await this.ownership.isOwnedBy(cmd.characterId, cmd.callerUserId);
      if (!ok) throw new CharacterNotOwnedError(cmd.characterId);
    }
    const updated = await this.repo.setCharacter(cmd.membershipId, cmd.characterId);
    this.bus.publish(
      new CharacterLinkedEvent(updated.id, updated.gameSessionId, updated.userId, cmd.characterId),
    );
    return updated;
  }
}
