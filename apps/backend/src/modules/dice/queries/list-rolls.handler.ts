import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import {
  CharacterNotFoundError,
  CharacterNotOwnedError,
} from '../../characters/domain/character.errors';
import { CHARACTER_REPO } from '../../characters/domain/character.ports';
import { ROLL_REPO } from '../domain/roll.ports';

import { ListRollsQuery } from './list-rolls.query';

import type { ICharacterRepo } from '../../characters/domain/character.ports';
import type { IRollRepo, RollReadModel } from '../domain/roll.ports';

interface RollListResult {
  items: RollReadModel[];
}

@QueryHandler(ListRollsQuery)
export class ListRollsHandler implements IQueryHandler<ListRollsQuery, RollListResult> {
  constructor(
    @Inject(CHARACTER_REPO) private readonly characterRepo: ICharacterRepo,
    @Inject(ROLL_REPO) private readonly rollRepo: IRollRepo,
  ) {}

  async execute(query: ListRollsQuery): Promise<RollListResult> {
    const { callerId, characterId, limit } = query;

    const ownership = await this.characterRepo.findOwnerIdById(characterId);
    if (!ownership) {
      throw new CharacterNotFoundError(characterId);
    }
    if (ownership.ownerId !== callerId) {
      throw new CharacterNotOwnedError(characterId);
    }

    const items = await this.rollRepo.listByCharacterId(characterId, limit);
    return { items };
  }
}
