import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import {
  CharacterNotFoundError,
  CharacterNotOwnedError,
} from '../../characters/domain/character.errors';
import { CHARACTER_REPO } from '../../characters/domain/character.ports';
import { countHits, rollPool } from '../domain/roll-engine';
import { RollPoolOutOfRangeError } from '../domain/roll.errors';
import { ROLL_REPO } from '../domain/roll.ports';

import { CreateRollCommand } from './create-roll.command';

import type { ICharacterRepo } from '../../characters/domain/character.ports';
import type { IRollRepo, RollReadModel } from '../domain/roll.ports';

@CommandHandler(CreateRollCommand)
export class CreateRollHandler implements ICommandHandler<CreateRollCommand, RollReadModel> {
  constructor(
    @Inject(CHARACTER_REPO) private readonly characterRepo: ICharacterRepo,
    @Inject(ROLL_REPO) private readonly rollRepo: IRollRepo,
  ) {}

  async execute(command: CreateRollCommand): Promise<RollReadModel> {
    const { callerId, characterId, dto } = command;

    // Validate pool bounds (belt-and-suspenders on top of class-validator DTO)
    if (dto.pool < 1 || dto.pool > 10) {
      throw new RollPoolOutOfRangeError(dto.pool);
    }

    // Verify character exists and caller owns it
    const ownership = await this.characterRepo.findOwnerIdById(characterId);
    if (!ownership) {
      throw new CharacterNotFoundError(characterId);
    }
    if (ownership.ownerId !== callerId) {
      throw new CharacterNotOwnedError(characterId);
    }

    // Roll the dice server-side with crypto.randomInt
    const dice = rollPool(dto.pool);
    const hits = countHits(dice);

    return this.rollRepo.create({
      characterId,
      gameSessionId: dto.gameSessionId ?? null,
      label: dto.label,
      pool: dto.pool,
      dice,
      hits,
    });
  }
}
