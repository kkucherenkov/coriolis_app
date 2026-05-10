/**
 * WHY this file exists:
 * Thin HTTP entry point for the ships bounded context. Jobs:
 *  1. Authenticate via SessionGuard.
 *  2. Receive validated DTO (ValidationPipe + class-validator).
 *  3. Dispatch the appropriate Query or Command via the bus.
 *  4. Return the result — no mapping, no Prisma, no business logic.
 *
 * The user id is sourced exclusively from the authenticated session via
 * req.userId. It is never taken from the request body or path params.
 */
import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { CommandBus, QueryBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../common/auth/auth.guard';

import { AddShipModuleCommand, AddShipModuleDto } from './commands/add-ship-module.command';
import { AssignCrewCommand, AssignCrewDto } from './commands/assign-crew.command';
import { CreateShipCommand, CreateShipDto } from './commands/create-ship.command';
import { DeleteShipCommand } from './commands/delete-ship.command';
import { DuplicateShipCommand } from './commands/duplicate-ship.command';
import { UnassignCrewCommand } from './commands/unassign-crew.command';
import { UpdateShipCommand, UpdateShipDto } from './commands/update-ship.command';
import { GetShipExportQuery } from './queries/get-ship-export.query';
import { GetShipQuery } from './queries/get-ship.query';
import { ListShipsQuery } from './queries/list-ships.query';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';
import type { CrewSlotReadModel, ShipModuleReadModel, ShipReadModel } from './domain/ship.ports';
import type { ShipListResult } from './queries/list-ships.handler';

@UseGuards(SessionGuard)
@Controller({ path: 'ships', version: '1' })
export class ShipsController {
  constructor(
    private readonly queryBus: QueryBus,
    private readonly commandBus: CommandBus,
  ) {}

  /** GET /api/v1/ships */
  @Get()
  async list(
    @Req() req: AuthenticatedRequest,
    @Query('limit') limitRaw?: string,
    @Query('cursor') cursor?: string,
  ): Promise<ShipListResult> {
    const limit = Math.min(Math.max(Number.parseInt(limitRaw ?? '20', 10) || 20, 1), 100);
    return this.queryBus.execute(new ListShipsQuery(req.userId, limit, cursor));
  }

  /** POST /api/v1/ships */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Req() req: AuthenticatedRequest, @Body() body: CreateShipDto): Promise<ShipReadModel> {
    return this.commandBus.execute(new CreateShipCommand(req.userId, body));
  }

  /** GET /api/v1/ships/:id */
  @Get(':id')
  async getOne(@Req() req: AuthenticatedRequest, @Param('id') id: string): Promise<ShipReadModel> {
    return this.queryBus.execute(new GetShipQuery(id, req.userId));
  }

  /** PATCH /api/v1/ships/:id */
  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  async update(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: UpdateShipDto,
  ): Promise<ShipReadModel> {
    return this.commandBus.execute(new UpdateShipCommand(id, req.userId, body));
  }

  /** DELETE /api/v1/ships/:id */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Req() req: AuthenticatedRequest, @Param('id') id: string): Promise<void> {
    return this.commandBus.execute(new DeleteShipCommand(id, req.userId));
  }

  /** POST /api/v1/ships/:id/modules */
  @Post(':id/modules')
  @HttpCode(HttpStatus.CREATED)
  async addModule(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: AddShipModuleDto,
  ): Promise<ShipModuleReadModel> {
    return this.commandBus.execute(new AddShipModuleCommand(id, req.userId, body));
  }

  /** POST /api/v1/ships/:id/crew */
  @Post(':id/crew')
  @HttpCode(HttpStatus.CREATED)
  async assignCrew(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: AssignCrewDto,
  ): Promise<CrewSlotReadModel> {
    return this.commandBus.execute(new AssignCrewCommand(id, req.userId, body));
  }

  /** DELETE /api/v1/ships/:id/crew/:characterId */
  @Delete(':id/crew/:characterId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async unassignCrew(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Param('characterId') characterId: string,
  ): Promise<void> {
    return this.commandBus.execute(new UnassignCrewCommand(id, req.userId, characterId));
  }

  /** POST /api/v1/ships/:id/duplicate — STUB: Block 5 */
  @Post(':id/duplicate')
  @HttpCode(HttpStatus.CREATED)
  async duplicate(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
  ): Promise<ShipReadModel> {
    return this.commandBus.execute(new DuplicateShipCommand(id, req.userId));
  }

  /** GET /api/v1/ships/:id/export — STUB: Block 5 */
  @Get(':id/export')
  async export(@Req() req: AuthenticatedRequest, @Param('id') id: string): Promise<never> {
    return this.queryBus.execute(new GetShipExportQuery(id, req.userId));
  }
}
