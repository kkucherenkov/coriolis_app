import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { CharacterNotFoundError, CharacterNotOwnedError } from '../../domain/character.errors';
import { CHARACTER_REPO } from '../../domain/character.ports';
import { TALENT_REPO } from '../domain/talent.ports';

import { AddTalentCommand } from './add-talent.command';

import type { ICharacterRepo, TalentReadModel } from '../../domain/character.ports';
import type { ITalentRepo } from '../domain/talent.ports';

@CommandHandler(AddTalentCommand)
export class AddTalentHandler implements ICommandHandler<
  AddTalentCommand,
  TalentReadModel & { characterId: string }
> {
  constructor(
    @Inject(CHARACTER_REPO) private readonly characterRepo: ICharacterRepo,
    @Inject(TALENT_REPO) private readonly talentRepo: ITalentRepo,
  ) {}

  async execute(command: AddTalentCommand): Promise<TalentReadModel & { characterId: string }> {
    const { characterId, ownerId, dto } = command;

    const ownerRow = await this.characterRepo.findOwnerIdById(characterId);
    if (!ownerRow) throw new CharacterNotFoundError(characterId);
    if (ownerRow.ownerId !== ownerId) throw new CharacterNotOwnedError(characterId);

    return this.talentRepo.create({
      characterId,
      name: dto.name,
      description: dto.description,
      rank: dto.rank ?? 1,
    });
  }
}
