import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { CHARACTER_REPO } from '../domain/character.ports';
import { CharacterRepo } from '../infra/character.repo';

import { AddItemHandler } from './commands/add-item.handler';
import { DeleteItemHandler } from './commands/delete-item.handler';
import { UpdateItemHandler } from './commands/update-item.handler';
import { ITEM_REPO } from './domain/item.ports';
import { ItemRepo } from './infra/item.repo';
import { ItemsController } from './items.controller';

@Module({
  imports: [CqrsModule],
  controllers: [ItemsController],
  providers: [
    AddItemHandler,
    UpdateItemHandler,
    DeleteItemHandler,
    { provide: ITEM_REPO, useClass: ItemRepo },
    { provide: CHARACTER_REPO, useClass: CharacterRepo },
  ],
  exports: [AddItemHandler, ITEM_REPO],
})
export class ItemsModule {}
