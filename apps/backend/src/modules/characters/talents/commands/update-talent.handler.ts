import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { CHARACTER_REPO } from '../../domain/character.ports';
import { TalentNotFoundError, TalentNotOwnedError } from '../domain/talent.errors';
import { TALENT_REPO } from '../domain/talent.ports';

import { UpdateTalentCommand } from './update-talent.command';

import type { ICharacterRepo, TalentReadModel } from '../../domain/character.ports';
import type { ITalentRepo } from '../domain/talent.ports';

@CommandHandler(UpdateTalentCommand)
export class UpdateTalentHandler
  implements ICommandHandler<UpdateTalentCommand, TalentReadModel & { characterId: string }>
{
  constructor(
    @Inject(TALENT_REPO) private readonly talentRepo: ITalentRepo,
    @Inject(CHARACTER_REPO) private readonly characterRepo: ICharacterRepo,
  ) {}

  async execute(
    command: UpdateTalentCommand,
  ): Promise<TalentReadModel & { characterId: string }> {
    const { talentId, ownerId, dto } = command;

    const talent = await this.talentRepo.findById(talentId);
    if (!talent) throw new TalentNotFoundError(talentId);

    const charOwner = await this.characterRepo.findOwnerIdById(talent.characterId);
    if (charOwner?.ownerId !== ownerId) {
      throw new TalentNotOwnedError(talentId);
    }

    return this.talentRepo.update(talentId, dto);
  }
}
