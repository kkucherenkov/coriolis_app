import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { CHARACTER_REPO } from '../../domain/character.ports';
import { ItemNotFoundError, ItemNotOwnedError } from '../domain/item.errors';
import { ITEM_REPO } from '../domain/item.ports';

import { DeleteItemCommand } from './delete-item.command';

import type { ICharacterRepo } from '../../domain/character.ports';
import type { IItemRepo } from '../domain/item.ports';

@CommandHandler(DeleteItemCommand)
export class DeleteItemHandler implements ICommandHandler<DeleteItemCommand, void> {
  constructor(
    @Inject(ITEM_REPO) private readonly itemRepo: IItemRepo,
    @Inject(CHARACTER_REPO) private readonly characterRepo: ICharacterRepo,
  ) {}

  async execute(command: DeleteItemCommand): Promise<void> {
    const { itemId, ownerId } = command;

    const item = await this.itemRepo.findById(itemId);
    if (!item) throw new ItemNotFoundError(itemId);

    const charOwner = await this.characterRepo.findOwnerIdById(item.characterId);
    if (charOwner?.ownerId !== ownerId) {
      throw new ItemNotOwnedError(itemId);
    }

    await this.itemRepo.delete(itemId);
  }
}
