/**
 * WHY this file exists:
 * Handles the two nested combatant endpoints:
 *   GET  /api/v1/encounters/{id}/combatants  → listCombatants
 *   POST /api/v1/encounters/{id}/combatants  → addCombatant
 *
 * The encounterId comes from the path param; userId from the authenticated session.
 * No Prisma, no business logic — dispatch only.
 */
import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { CommandBus, QueryBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../common/auth/auth.guard';

import { AddCombatantCommand, AddCombatantDto } from './commands/add-combatant.command';
import { ListCombatantsQuery } from './queries/list-combatants.query';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';
import type { CombatantReadModel } from './domain/combatant.ports';
import type { CombatantListResult } from './queries/list-combatants.handler';

@UseGuards(SessionGuard)
@Controller({ path: 'encounters/:encounterId/combatants', version: '1' })
export class NestedCombatantsController {
  constructor(
    private readonly queryBus: QueryBus,
    private readonly commandBus: CommandBus,
  ) {}

  /** GET /api/v1/encounters/:encounterId/combatants */
  @Get()
  async list(
    @Req() req: AuthenticatedRequest,
    @Param('encounterId') encounterId: string,
  ): Promise<CombatantListResult> {
    return this.queryBus.execute(new ListCombatantsQuery(encounterId, req.userId));
  }

  /** POST /api/v1/encounters/:encounterId/combatants */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async add(
    @Req() req: AuthenticatedRequest,
    @Param('encounterId') encounterId: string,
    @Body() body: AddCombatantDto,
  ): Promise<CombatantReadModel> {
    return this.commandBus.execute(new AddCombatantCommand(encounterId, req.userId, body));
  }
}
