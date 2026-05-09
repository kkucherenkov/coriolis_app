import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import {
  CharacterNotFoundError,
  CharacterNotOwnedError,
} from '../../characters/domain/character.errors';
import { CHARACTER_REPO } from '../../characters/domain/character.ports';
import { generateSlug } from '../domain/slug';

import { CreateShareLinkCommand } from './create-share-link.command';

import type { ICharacterRepo } from '../../characters/domain/character.ports';
import type { ShareLinkReadModel, IShareLinkRepo } from '../domain/share-link.ports';
import { SHARE_LINK_REPO } from '../domain/share-link.ports';

@CommandHandler(CreateShareLinkCommand)
export class CreateShareLinkHandler implements ICommandHandler<
  CreateShareLinkCommand,
  ShareLinkReadModel
> {
  constructor(
    @Inject(CHARACTER_REPO) private readonly characterRepo: ICharacterRepo,
    @Inject(SHARE_LINK_REPO) private readonly shareLinkRepo: IShareLinkRepo,
  ) {}

  async execute(command: CreateShareLinkCommand): Promise<ShareLinkReadModel> {
    const { callerId, characterId, dto } = command;

    // Verify the character exists
    const ownership = await this.characterRepo.findOwnerIdById(characterId);
    if (!ownership) {
      throw new CharacterNotFoundError(characterId);
    }

    // Verify the caller owns the character
    if (ownership.ownerId !== callerId) {
      throw new CharacterNotOwnedError(characterId);
    }

    const slug = generateSlug();
    const expiresAt = dto.expiresAt ? new Date(dto.expiresAt) : null;

    return this.shareLinkRepo.create({
      slug,
      characterId,
      includeGmNotes: dto.includeGmNotes ?? false,
      label: dto.label ?? null,
      expiresAt,
    });
  }
}
