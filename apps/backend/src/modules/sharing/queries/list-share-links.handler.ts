import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { CharacterNotFoundError, CharacterNotOwnedError } from '../../characters/domain/character.errors';
import { CHARACTER_REPO } from '../../characters/domain/character.ports';
import { SHARE_LINK_REPO } from '../domain/share-link.ports';

import { ListShareLinksQuery } from './list-share-links.query';

import type { ICharacterRepo } from '../../characters/domain/character.ports';
import type { IShareLinkRepo, ShareLinkReadModel } from '../domain/share-link.ports';

interface ShareLinkListResult {
  items: ShareLinkReadModel[];
}

@QueryHandler(ListShareLinksQuery)
export class ListShareLinksHandler implements IQueryHandler<ListShareLinksQuery, ShareLinkListResult> {
  constructor(
    @Inject(CHARACTER_REPO) private readonly characterRepo: ICharacterRepo,
    @Inject(SHARE_LINK_REPO) private readonly shareLinkRepo: IShareLinkRepo,
  ) {}

  async execute(query: ListShareLinksQuery): Promise<ShareLinkListResult> {
    const { callerId, characterId } = query;

    const ownership = await this.characterRepo.findOwnerIdById(characterId);
    if (!ownership) {
      throw new CharacterNotFoundError(characterId);
    }
    if (ownership.ownerId !== callerId) {
      throw new CharacterNotOwnedError(characterId);
    }

    const items = await this.shareLinkRepo.listByCharacterId(characterId);
    return { items };
  }
}
