/**
 * WHY this file exists:
 * Ships the `/api/v1/ship-modules/{id}` sub-resource endpoints (PATCH + DELETE).
 * The OpenAPI spec separates these from the ships controller because the module
 * identifier is sufficient — callers do not need the parent ship id at this level.
 *
 * Ownership is enforced inside the command handlers via findModuleById → parent ship.
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

import { SessionGuard } from '../../common/auth/auth.guard';

import { DeleteShipModuleCommand } from './commands/delete-ship-module.command';
import {
  UpdateShipModuleCommand,
  UpdateShipModuleDto,
} from './commands/update-ship-module.command';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';
import type { ShipModuleReadModel } from './domain/ship.ports';

@UseGuards(SessionGuard)
@Controller({ path: 'ship-modules', version: '1' })
export class ShipModulesController {
  constructor(private readonly commandBus: CommandBus) {}

  /** PATCH /api/v1/ship-modules/:id */
  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  async update(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: UpdateShipModuleDto,
  ): Promise<ShipModuleReadModel> {
    return this.commandBus.execute(new UpdateShipModuleCommand(id, req.userId, body));
  }

  /** DELETE /api/v1/ship-modules/:id */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Req() req: AuthenticatedRequest, @Param('id') id: string): Promise<void> {
    return this.commandBus.execute(new DeleteShipModuleCommand(id, req.userId));
  }
}
