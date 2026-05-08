/**
 * Handles standalone item operations (PATCH /items/:id, DELETE /items/:id).
 * POST /characters/:id/items is handled by CharactersController to keep
 * character-nested resources on the characters controller.
 */
import {
  Body,
  Controller,
  Delete,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Req,
  UseGuards,
} from '@nestjs/common';
import { CommandBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../../common/auth/auth.guard';

import { DeleteItemCommand } from './commands/delete-item.command';
import { UpdateItemCommand, UpdateItemDto } from './commands/update-item.command';

import type { AuthenticatedRequest } from '../../../common/auth/auth.guard';
import type { ItemReadModel } from '../domain/character.ports';

@UseGuards(SessionGuard)
@Controller({ path: 'items', version: '1' })
export class ItemsController {
  constructor(private readonly commandBus: CommandBus) {}

  /** PATCH /api/v1/items/:id */
  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  async update(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: UpdateItemDto,
  ): Promise<ItemReadModel> {
    return this.commandBus.execute(new UpdateItemCommand(id, req.userId, body));
  }

  /** DELETE /api/v1/items/:id */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Req() req: AuthenticatedRequest, @Param('id') id: string): Promise<void> {
    return this.commandBus.execute(new DeleteItemCommand(id, req.userId));
  }
}
