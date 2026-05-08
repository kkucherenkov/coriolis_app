import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { CHARACTER_REPO } from '../../domain/character.ports';
import { ItemNotFoundError, ItemNotOwnedError } from '../domain/item.errors';
import { ITEM_REPO } from '../domain/item.ports';

import { UpdateItemCommand } from './update-item.command';

import type { ICharacterRepo, ItemReadModel } from '../../domain/character.ports';
import type { IItemRepo } from '../domain/item.ports';

@CommandHandler(UpdateItemCommand)
export class UpdateItemHandler
  implements ICommandHandler<UpdateItemCommand, ItemReadModel & { characterId: string }>
{
  constructor(
    @Inject(ITEM_REPO) private readonly itemRepo: IItemRepo,
    @Inject(CHARACTER_REPO) private readonly characterRepo: ICharacterRepo,
  ) {}

  async execute(
    command: UpdateItemCommand,
  ): Promise<ItemReadModel & { characterId: string }> {
    const { itemId, ownerId, dto } = command;

    const item = await this.itemRepo.findById(itemId);
    if (!item) throw new ItemNotFoundError(itemId);

    // Verify parent character is owned by the caller
    const charOwner = await this.characterRepo.findOwnerIdById(item.characterId);
    if (!charOwner || charOwner.ownerId !== ownerId) {
      throw new ItemNotOwnedError(itemId);
    }

    const { ...payload } = dto;
    return this.itemRepo.update(itemId, payload as Record<string, unknown>);
  }
}
