import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import {
  CharacterNotFoundError,
  CharacterNotOwnedError,
} from '../../characters/domain/character.errors';
import { CHARACTER_REPO } from '../../characters/domain/character.ports';
import { canPush } from '../../rules-engine';
import { RollPushedEvent } from '../events/roll-pushed.event';
import { countHits, pushDice } from '../domain/roll-engine';
import { RollNotFoundError, RollNotPushableError } from '../domain/roll.errors';
import { ROLL_REPO } from '../domain/roll.ports';

import { PushRollCommand } from './push-roll.command';

import type { ICharacterRepo } from '../../characters/domain/character.ports';
import type { IRollRepo, RollReadModel } from '../domain/roll.ports';

@CommandHandler(PushRollCommand)
export class PushRollHandler implements ICommandHandler<PushRollCommand, RollReadModel> {
  constructor(
    @Inject(CHARACTER_REPO) private readonly characterRepo: ICharacterRepo,
    @Inject(ROLL_REPO) private readonly rollRepo: IRollRepo,
    private readonly eventBus: EventBus,
  ) {}

  async execute(command: PushRollCommand): Promise<RollReadModel> {
    const { callerId, rollId } = command;

    // Fetch the roll
    const roll = await this.rollRepo.findById(rollId);
    if (!roll) {
      throw new RollNotFoundError(rollId);
    }

    // Fetch the owning character (also verifies it exists)
    const character = await this.characterRepo.findActiveById(roll.characterId);
    if (!character) {
      throw new CharacterNotFoundError(roll.characterId);
    }

    // Verify ownership
    if (character.ownerId !== callerId) {
      throw new CharacterNotOwnedError(roll.characterId);
    }

    // Apply push eligibility rules (PRD §10)
    const eligibility = canPush(roll, character.conditions);
    if (!eligibility.ok) {
      throw new RollNotPushableError(eligibility.reason);
    }

    // Reroll all non-6 dice. Pool is preserved; for a Ноль кубиков roll
    // (pool === 0) we still need both post-push dice to be 6 to score a hit.
    const newDice = pushDice(roll.dice);
    const newHits = countHits(newDice, roll.pool);

    // Persist and emit event
    const updated = await this.rollRepo.push(rollId, newDice, newHits);

    this.eventBus.publish(
      new RollPushedEvent(rollId, roll.characterId, roll.gameSessionId, newHits),
    );

    return updated;
  }
}
