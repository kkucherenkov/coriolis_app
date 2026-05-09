/**
 * WHY this file exists:
 * HTTP entry point for the dice bounded context. Jobs:
 *   1. Authenticate via SessionGuard.
 *   2. Parse / coerce query params.
 *   3. Dispatch to CommandBus / QueryBus.
 *   4. Return the result. No Prisma, no business logic.
 *
 * The `userId` is sourced exclusively from the authenticated session via
 * req.userId — never from the request body or path params.
 */
import {
  Body,
  Controller,
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

import { CreateRollCommand, CreateRollDto } from './commands/create-roll.command';
import { PushRollCommand } from './commands/push-roll.command';
import { ListRollsQuery } from './queries/list-rolls.query';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';
import type { RollReadModel } from './domain/roll.ports';

interface RollListResponse {
  items: RollReadModel[];
}

@UseGuards(SessionGuard)
@Controller({ version: '1' })
export class DiceController {
  constructor(
    private readonly commandBus: CommandBus,
    private readonly queryBus: QueryBus,
  ) {}

  /** POST /api/v1/characters/:id/rolls */
  @Post('characters/:id/rolls')
  @HttpCode(HttpStatus.CREATED)
  async createRoll(
    @Req() req: AuthenticatedRequest,
    @Param('id') characterId: string,
    @Body() body: CreateRollDto,
  ): Promise<RollReadModel> {
    return this.commandBus.execute(new CreateRollCommand(req.userId, characterId, body));
  }

  /** GET /api/v1/characters/:id/rolls */
  @Get('characters/:id/rolls')
  async listRolls(
    @Req() req: AuthenticatedRequest,
    @Param('id') characterId: string,
    @Query('limit') limitRaw?: string,
  ): Promise<RollListResponse> {
    const limit = Math.min(Math.max(Number.parseInt(limitRaw ?? '50', 10) || 50, 1), 100);
    return this.queryBus.execute(new ListRollsQuery(req.userId, characterId, limit));
  }

  /** PATCH /api/v1/rolls/:id/push */
  @Patch('rolls/:id/push')
  @HttpCode(HttpStatus.OK)
  async pushRoll(
    @Req() req: AuthenticatedRequest,
    @Param('id') rollId: string,
  ): Promise<RollReadModel> {
    return this.commandBus.execute(new PushRollCommand(req.userId, rollId));
  }
}
