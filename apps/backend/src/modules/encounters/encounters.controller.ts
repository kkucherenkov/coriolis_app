/**
 * WHY this file exists:
 * Handles the flat encounter endpoints:
 *   GET    /api/v1/encounters/{id}                → getEncounter
 *   PATCH  /api/v1/encounters/{id}                → updateEncounter
 *   DELETE /api/v1/encounters/{id}                → deleteEncounter
 *   POST   /api/v1/encounters/{id}/initiative/roll → rollInitiative
 *   PATCH  /api/v1/encounters/{id}/initiative      → reorderInitiative
 *   POST   /api/v1/encounters/{id}/turn/advance    → advanceTurn
 *
 * The userId comes from the authenticated session.
 * No Prisma, no business logic — dispatch only.
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
  Req,
  UseGuards,
} from '@nestjs/common';
import { CommandBus, QueryBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../common/auth/auth.guard';

import { UpdateEncounterCommand, UpdateEncounterDto } from './commands/update-encounter.command';
import { DeleteEncounterCommand } from './commands/delete-encounter.command';
import { GetEncounterQuery } from './queries/get-encounter.query';
import { RollInitiativeCommand } from './commands/roll-initiative.command';
import {
  ReorderInitiativeCommand,
  ReorderInitiativeDto,
} from './commands/reorder-initiative.command';
import { AdvanceTurnCommand } from './commands/advance-turn.command';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';
import type { EncounterReadModel } from './domain/encounter.ports';
import type { InitiativeRollResult, TurnAdvanceResult } from './domain/encounter.ports';

@UseGuards(SessionGuard)
@Controller({ path: 'encounters', version: '1' })
export class EncountersController {
  constructor(
    private readonly queryBus: QueryBus,
    private readonly commandBus: CommandBus,
  ) {}

  /** GET /api/v1/encounters/:id */
  @Get(':id')
  async getOne(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
  ): Promise<EncounterReadModel> {
    return this.queryBus.execute(new GetEncounterQuery(id, req.userId));
  }

  /** PATCH /api/v1/encounters/:id */
  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  async update(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: UpdateEncounterDto,
  ): Promise<EncounterReadModel> {
    return this.commandBus.execute(new UpdateEncounterCommand(id, req.userId, body));
  }

  /** DELETE /api/v1/encounters/:id */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Req() req: AuthenticatedRequest, @Param('id') id: string): Promise<void> {
    return this.commandBus.execute(new DeleteEncounterCommand(id, req.userId));
  }

  /** POST /api/v1/encounters/:id/initiative/roll */
  @Post(':id/initiative/roll')
  @HttpCode(HttpStatus.OK)
  async rollInitiative(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
  ): Promise<InitiativeRollResult> {
    return this.commandBus.execute(new RollInitiativeCommand(id, req.userId));
  }

  /** PATCH /api/v1/encounters/:id/initiative */
  @Patch(':id/initiative')
  @HttpCode(HttpStatus.OK)
  async reorderInitiative(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: ReorderInitiativeDto,
  ): Promise<InitiativeRollResult> {
    return this.commandBus.execute(new ReorderInitiativeCommand(id, req.userId, body));
  }

  /** POST /api/v1/encounters/:id/turn/advance */
  @Post(':id/turn/advance')
  @HttpCode(HttpStatus.OK)
  async advanceTurn(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
  ): Promise<TurnAdvanceResult> {
    return this.commandBus.execute(new AdvanceTurnCommand(id, req.userId));
  }
}
