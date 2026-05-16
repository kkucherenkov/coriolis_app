/**
 * WHY this file exists:
 * Thin HTTP entry point for the game-sessions bounded context. Jobs:
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

import {
  CreateGameSessionCommand,
  CreateGameSessionDto,
} from './commands/create-game-session.command';
import { DeleteGameSessionCommand } from './commands/delete-game-session.command';
import {
  UpdateGameSessionCommand,
  UpdateGameSessionDto,
} from './commands/update-game-session.command';
import { UpdateDpCommand, UpdateDpDto } from './dp/commands/update-dp.command';
import { ListDpEventsQuery } from './dp/queries/list-dp-events.query';
import { GetGameSessionQuery } from './queries/get-game-session.query';
import { ListGameSessionsQuery } from './queries/list-game-sessions.query';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';
import type { GameSessionReadModel } from './domain/game-session.ports';
import type { DpEventListResult } from './dp/queries/list-dp-events.handler';
import type { GameSessionListResult } from './queries/list-game-sessions.handler';

@UseGuards(SessionGuard)
@Controller({ path: 'game-sessions', version: '1' })
export class GameSessionsController {
  constructor(
    private readonly queryBus: QueryBus,
    private readonly commandBus: CommandBus,
  ) {}

  /** GET /api/v1/game-sessions */
  @Get()
  async list(
    @Req() req: AuthenticatedRequest,
    @Query('limit') limitRaw?: string,
    @Query('cursor') cursor?: string,
    @Query('status') statusRaw?: string,
  ): Promise<GameSessionListResult> {
    const limit = Math.min(Math.max(Number.parseInt(limitRaw ?? '20', 10) || 20, 1), 100);
    const status = statusRaw === 'active' || statusRaw === 'archived' ? statusRaw : undefined;
    return this.queryBus.execute(new ListGameSessionsQuery(req.userId, limit, cursor, status));
  }

  /** POST /api/v1/game-sessions */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Req() req: AuthenticatedRequest,
    @Body() body: CreateGameSessionDto,
  ): Promise<GameSessionReadModel> {
    return this.commandBus.execute(new CreateGameSessionCommand(req.userId, body));
  }

  /** GET /api/v1/game-sessions/:id */
  @Get(':id')
  async getOne(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
  ): Promise<GameSessionReadModel> {
    return this.queryBus.execute(new GetGameSessionQuery(id, req.userId));
  }

  /** PATCH /api/v1/game-sessions/:id */
  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  async update(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: UpdateGameSessionDto,
  ): Promise<GameSessionReadModel> {
    return this.commandBus.execute(new UpdateGameSessionCommand(id, req.userId, body));
  }

  /** DELETE /api/v1/game-sessions/:id */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Req() req: AuthenticatedRequest, @Param('id') id: string): Promise<void> {
    return this.commandBus.execute(new DeleteGameSessionCommand(id, req.userId));
  }

  /** POST /api/v1/game-sessions/:id/dp */
  @Post(':id/dp')
  @HttpCode(HttpStatus.OK)
  async adjustDp(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: UpdateDpDto,
  ): Promise<GameSessionReadModel> {
    return this.commandBus.execute(
      new UpdateDpCommand(id, req.userId, body.delta, 'GM_MANUAL', body.reason ?? null),
    );
  }

  /** GET /api/v1/game-sessions/:id/dp/events */
  @Get(':id/dp/events')
  async listDpEvents(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Query('limit') limitRaw?: string,
    @Query('cursor') cursor?: string,
  ): Promise<DpEventListResult> {
    const limit = Math.min(Math.max(Number.parseInt(limitRaw ?? '20', 10) || 20, 1), 100);
    return this.queryBus.execute(new ListDpEventsQuery(id, req.userId, limit, cursor));
  }
}
