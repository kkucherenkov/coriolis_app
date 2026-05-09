/**
 * Export returns the same full Character DTO as GetCharacter.
 * It is a separate query so the controller can set appropriate headers
 * (e.g., Content-Disposition) without touching GetCharacter.
 */
import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { CharacterNotFoundError, CharacterNotOwnedError } from '../domain/character.errors';
import { CHARACTER_REPO, CharacterReadModel } from '../domain/character.ports';

import { ExportCharacterQuery } from './export-character.query';

import type { ICharacterRepo } from '../domain/character.ports';

@QueryHandler(ExportCharacterQuery)
export class ExportCharacterHandler implements IQueryHandler<
  ExportCharacterQuery,
  CharacterReadModel
> {
  constructor(@Inject(CHARACTER_REPO) private readonly repo: ICharacterRepo) {}

  async execute(query: ExportCharacterQuery): Promise<CharacterReadModel> {
    const { characterId, ownerId } = query;

    const character = await this.repo.findActiveById(characterId);
    if (!character) throw new CharacterNotFoundError(characterId);
    if (character.ownerId !== ownerId) throw new CharacterNotOwnedError(characterId);

    return character;
  }
}
