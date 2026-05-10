import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import {
  CharacterNotFoundError,
  CharacterNotOwnedError,
} from '../../characters/domain/character.errors';
import { CHARACTER_REPO } from '../../characters/domain/character.ports';
import { countHits, rollPool } from '../domain/roll-engine';
import { RollBreakdownMismatchError, RollPoolOutOfRangeError } from '../domain/roll.errors';
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
    if (!Number.isInteger(dto.pool) || dto.pool < 0 || dto.pool > 20) {
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

    // Guard breakdown sum-equality when breakdown is supplied (T-016).
    if (dto.breakdown !== undefined) {
      const sum =
        dto.breakdown.attribute +
        dto.breakdown.skill +
        dto.breakdown.gear +
        dto.breakdown.modifier +
        dto.breakdown.helpers;
      if (sum !== dto.pool) {
        throw new RollBreakdownMismatchError(sum, dto.pool);
      }
    }

    // Roll the dice server-side with crypto.randomInt.
    // pool === 0 triggers Ноль кубиков (ГЛАВА 3): 2 dice rolled, success only on double 6.
    const dice = rollPool(dto.pool);
    const hits = countHits(dice, dto.pool);

    return this.rollRepo.create({
      characterId,
      gameSessionId: dto.gameSessionId ?? null,
      label: dto.label,
      pool: dto.pool,
      dice,
      hits,
      kind: dto.kind ?? 'skill',
      breakdown: dto.breakdown ?? null,
    });
  }
}
