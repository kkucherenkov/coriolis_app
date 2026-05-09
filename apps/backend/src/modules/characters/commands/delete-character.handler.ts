import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { CharacterNotFoundError, CharacterNotOwnedError } from '../domain/character.errors';
import { CHARACTER_REPO } from '../domain/character.ports';

import { DeleteCharacterCommand } from './delete-character.command';

import type { ICharacterRepo } from '../domain/character.ports';

@CommandHandler(DeleteCharacterCommand)
export class DeleteCharacterHandler implements ICommandHandler<DeleteCharacterCommand, void> {
  constructor(@Inject(CHARACTER_REPO) private readonly repo: ICharacterRepo) {}

  async execute(command: DeleteCharacterCommand): Promise<void> {
    const { characterId, ownerId } = command;

    const existing = await this.repo.findActiveById(characterId);
    if (!existing) throw new CharacterNotFoundError(characterId);
    if (existing.ownerId !== ownerId) throw new CharacterNotOwnedError(characterId);

    await this.repo.delete(characterId);
  }
}
