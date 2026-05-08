import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { CHARACTER_REPO } from '../../domain/character.ports';
import { TalentNotFoundError, TalentNotOwnedError } from '../domain/talent.errors';
import { TALENT_REPO } from '../domain/talent.ports';

import { DeleteTalentCommand } from './delete-talent.command';

import type { ICharacterRepo } from '../../domain/character.ports';
import type { ITalentRepo } from '../domain/talent.ports';

@CommandHandler(DeleteTalentCommand)
export class DeleteTalentHandler implements ICommandHandler<DeleteTalentCommand, void> {
  constructor(
    @Inject(TALENT_REPO) private readonly talentRepo: ITalentRepo,
    @Inject(CHARACTER_REPO) private readonly characterRepo: ICharacterRepo,
  ) {}

  async execute(command: DeleteTalentCommand): Promise<void> {
    const { talentId, ownerId } = command;

    const talent = await this.talentRepo.findById(talentId);
    if (!talent) throw new TalentNotFoundError(talentId);

    const charOwner = await this.characterRepo.findOwnerIdById(talent.characterId);
    if (charOwner?.ownerId !== ownerId) {
      throw new TalentNotOwnedError(talentId);
    }

    await this.talentRepo.delete(talentId);
  }
}
