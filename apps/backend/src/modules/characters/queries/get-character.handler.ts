import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { CharacterNotFoundError, CharacterNotOwnedError } from '../domain/character.errors';
import { CHARACTER_REPO, CharacterReadModel } from '../domain/character.ports';

import { GetCharacterQuery } from './get-character.query';

import type { ICharacterRepo } from '../domain/character.ports';

@QueryHandler(GetCharacterQuery)
export class GetCharacterHandler implements IQueryHandler<GetCharacterQuery, CharacterReadModel> {
  constructor(@Inject(CHARACTER_REPO) private readonly repo: ICharacterRepo) {}

  async execute(query: GetCharacterQuery): Promise<CharacterReadModel> {
    const { characterId, ownerId } = query;

    const character = await this.repo.findActiveById(characterId);
    if (!character) throw new CharacterNotFoundError(characterId);
    if (character.ownerId !== ownerId) throw new CharacterNotOwnedError(characterId);

    return character;
  }
}
