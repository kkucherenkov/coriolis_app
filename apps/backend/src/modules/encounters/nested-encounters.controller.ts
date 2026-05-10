/**
 * WHY this file exists:
 * Handles the two nested encounter endpoints:
 *   GET  /api/v1/game-sessions/{sessionId}/encounters  → listEncounters
 *   POST /api/v1/game-sessions/{sessionId}/encounters  → createEncounter
 *
 * The sessionId comes from the path param; userId from the authenticated session.
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
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { CommandBus, QueryBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../common/auth/auth.guard';

import { CreateEncounterCommand, CreateEncounterDto } from './commands/create-encounter.command';
import { ListEncountersQuery } from './queries/list-encounters.query';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';
import type { EncounterReadModel } from './domain/encounter.ports';
import type { EncounterListResult } from './queries/list-encounters.handler';
import type { EncounterStatus } from './domain/encounter.ports';

const VALID_STATUSES: ReadonlySet<string> = new Set(['setup', 'active', 'ended']);

@UseGuards(SessionGuard)
@Controller({ path: 'game-sessions/:sessionId/encounters', version: '1' })
export class NestedEncountersController {
  constructor(
    private readonly queryBus: QueryBus,
    private readonly commandBus: CommandBus,
  ) {}

  /** GET /api/v1/game-sessions/:sessionId/encounters */
  @Get()
  async list(
    @Req() req: AuthenticatedRequest,
    @Param('sessionId') sessionId: string,
    @Query('limit') limitRaw?: string,
    @Query('cursor') cursor?: string,
    @Query('status') statusRaw?: string,
  ): Promise<EncounterListResult> {
    const limit = Math.min(Math.max(Number.parseInt(limitRaw ?? '20', 10) || 20, 1), 100);
    const status =
      statusRaw && VALID_STATUSES.has(statusRaw) ? (statusRaw as EncounterStatus) : undefined;
    return this.queryBus.execute(
      new ListEncountersQuery(sessionId, req.userId, limit, cursor, status),
    );
  }

  /** POST /api/v1/game-sessions/:sessionId/encounters */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Req() req: AuthenticatedRequest,
    @Param('sessionId') sessionId: string,
    @Body() body: CreateEncounterDto,
  ): Promise<EncounterReadModel> {
    return this.commandBus.execute(new CreateEncounterCommand(sessionId, req.userId, body));
  }
}
