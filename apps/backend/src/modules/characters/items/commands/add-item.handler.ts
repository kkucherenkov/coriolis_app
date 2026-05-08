import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { CharacterNotFoundError, CharacterNotOwnedError } from '../../domain/character.errors';
import { CHARACTER_REPO } from '../../domain/character.ports';
import { ITEM_REPO } from '../domain/item.ports';

import { AddItemCommand } from './add-item.command';

import type { ICharacterRepo, ItemReadModel } from '../../domain/character.ports';
import type { IItemRepo } from '../domain/item.ports';

function buildPayload(dto: AddItemCommand['dto']): Record<string, unknown> {
  const { type, ...rest } = dto;
  return rest as Record<string, unknown>;
}

@CommandHandler(AddItemCommand)
export class AddItemHandler implements ICommandHandler<AddItemCommand, ItemReadModel> {
  constructor(
    @Inject(CHARACTER_REPO) private readonly characterRepo: ICharacterRepo,
    @Inject(ITEM_REPO) private readonly itemRepo: IItemRepo,
  ) {}

  async execute(command: AddItemCommand): Promise<ItemReadModel & { characterId: string }> {
    const { characterId, ownerId, dto } = command;

    const ownerRow = await this.characterRepo.findOwnerIdById(characterId);
    if (!ownerRow) throw new CharacterNotFoundError(characterId);
    if (ownerRow.ownerId !== ownerId) throw new CharacterNotOwnedError(characterId);

    return this.itemRepo.create({
      characterId,
      type: dto.type,
      payload: buildPayload(dto),
    });
  }
}
