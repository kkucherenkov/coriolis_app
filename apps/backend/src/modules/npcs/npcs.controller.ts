/**
 * WHY this file exists:
 * Thin HTTP entry point for the NPCs bounded context. Jobs:
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

import { CreateNpcCommand, CreateNpcDto } from './commands/create-npc.command';
import { DeleteNpcCommand } from './commands/delete-npc.command';
import { DuplicateNpcCommand } from './commands/duplicate-npc.command';
import { UpdateNpcCommand, UpdateNpcDto } from './commands/update-npc.command';
import { GetNpcQuery } from './queries/get-npc.query';
import { ListNpcsQuery } from './queries/list-npcs.query';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';
import type { NpcReadModel } from './domain/npc.ports';
import type { NpcListResult } from './queries/list-npcs.handler';

@UseGuards(SessionGuard)
@Controller({ path: 'npcs', version: '1' })
export class NpcsController {
  constructor(
    private readonly queryBus: QueryBus,
    private readonly commandBus: CommandBus,
  ) {}

  /** GET /api/v1/npcs */
  @Get()
  async list(
    @Req() req: AuthenticatedRequest,
    @Query('limit') limitRaw?: string,
    @Query('cursor') cursor?: string,
  ): Promise<NpcListResult> {
    const limit = Math.min(Math.max(Number.parseInt(limitRaw ?? '20', 10) || 20, 1), 100);
    return this.queryBus.execute(new ListNpcsQuery(req.userId, limit, cursor));
  }

  /** POST /api/v1/npcs */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Req() req: AuthenticatedRequest,
    @Body() body: CreateNpcDto,
  ): Promise<NpcReadModel> {
    return this.commandBus.execute(new CreateNpcCommand(req.userId, body));
  }

  /** GET /api/v1/npcs/:id */
  @Get(':id')
  async getOne(@Req() req: AuthenticatedRequest, @Param('id') id: string): Promise<NpcReadModel> {
    return this.queryBus.execute(new GetNpcQuery(id, req.userId));
  }

  /** PATCH /api/v1/npcs/:id */
  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  async update(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: UpdateNpcDto,
  ): Promise<NpcReadModel> {
    return this.commandBus.execute(new UpdateNpcCommand(id, req.userId, body));
  }

  /** DELETE /api/v1/npcs/:id */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Req() req: AuthenticatedRequest, @Param('id') id: string): Promise<void> {
    return this.commandBus.execute(new DeleteNpcCommand(id, req.userId));
  }

  /** POST /api/v1/npcs/:id/duplicate */
  @Post(':id/duplicate')
  @HttpCode(HttpStatus.CREATED)
  async duplicate(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
  ): Promise<NpcReadModel> {
    return this.commandBus.execute(new DuplicateNpcCommand(id, req.userId));
  }
}
