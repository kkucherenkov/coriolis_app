import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import {
  CharacterNotFoundError,
  CharacterNotOwnedError,
  StigmaRequiresMutantError,
  TalentKindDuplicateError,
} from '../../domain/character.errors';
import { CHARACTER_REPO } from '../../domain/character.ports';
import { TALENT_REPO } from '../domain/talent.ports';

import { AddTalentCommand } from './add-talent.command';

import type { ICharacterRepo, TalentKind, TalentReadModel } from '../../domain/character.ports';
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

    const kind: TalentKind = dto.kind ?? 'personal';

    // Per ST3001 ch.4 only mutants (`пасынки`) carry stigma talents. We need
    // the full character to read the `mutant` flag — `findOwnerIdById` would
    // be cheaper but doesn't include it.
    const character =
      kind === 'stigma' ? await this.characterRepo.findActiveById(characterId) : null;

    if (kind === 'stigma') {
      if (!character) throw new CharacterNotFoundError(characterId);
      if (character.ownerId !== ownerId) throw new CharacterNotOwnedError(characterId);
      if (!character.mutant) throw new StigmaRequiresMutantError();
    } else {
      const ownerRow = await this.characterRepo.findOwnerIdById(characterId);
      if (!ownerRow) throw new CharacterNotFoundError(characterId);
      if (ownerRow.ownerId !== ownerId) throw new CharacterNotOwnedError(characterId);
    }

    // Per ST3001 ch.2 each character has at most one of each non-`personal`
    // kind (crew / iconGift / stigma) at character creation; further talents
    // acquired during play are always `personal` (so personal is unbounded).
    if (kind !== 'personal') {
      const existing = await this.talentRepo.listByCharacterId(characterId);
      if (existing.some((t) => t.kind === kind)) {
        throw new TalentKindDuplicateError(kind);
      }
    }

    return this.talentRepo.create({
      characterId,
      kind,
      name: dto.name,
      description: dto.description,
      rank: dto.rank ?? 1,
    });
  }
}
