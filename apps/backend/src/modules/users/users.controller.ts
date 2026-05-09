/**
 * WHY this file exists:
 * Thin HTTP entry point for the users bounded context. Jobs:
 *  1. Authenticate via SessionGuard (attached at class level).
 *  2. Receive the validated DTO (ValidationPipe + class-validator).
 *  3. Dispatch the appropriate Query or Command via the bus.
 *  4. Return the result — no mapping, no Prisma, no business logic.
 *
 * The user id is sourced exclusively from the authenticated session via
 * `AuthenticatedRequest.userId`. It is never taken from the request body or
 * query string.
 */
import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Patch,
  Req,
  UseGuards,
} from '@nestjs/common';
import { CommandBus, QueryBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../common/auth/auth.guard';

import { DeleteMeCommand } from './commands/delete-me.command';
import { UpdateMeCommand, UpdateMeDto } from './commands/update-me.command';
import { GetMeQuery } from './queries/get-me.query';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';
import type { MeReadModel } from './domain/user.ports';

@UseGuards(SessionGuard)
@Controller({ path: 'me', version: '1' })
export class UsersController {
  constructor(
    private readonly queryBus: QueryBus,
    private readonly commandBus: CommandBus,
  ) {}

  /** GET /api/v1/me */
  @Get()
  async getMe(@Req() req: AuthenticatedRequest): Promise<MeReadModel> {
    return this.queryBus.execute(new GetMeQuery(req.userId));
  }

  /** PATCH /api/v1/me */
  @Patch()
  @HttpCode(HttpStatus.OK)
  async updateMe(
    @Req() req: AuthenticatedRequest,
    @Body() body: UpdateMeDto,
  ): Promise<MeReadModel> {
    return this.commandBus.execute(new UpdateMeCommand(req.userId, body.displayName, body.theme));
  }

  /**
   * DELETE /api/v1/me
   *
   * Soft-deletes the authenticated user's account. Idempotent per spec:
   * returns 204 even when the account is already deleted. Sessions are
   * revoked immediately; characters and ships are hard-deleted by the daily
   * cron after a 30-day grace window.
   */
  @Delete('me')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteMe(@Req() req: AuthenticatedRequest): Promise<void> {
    return this.commandBus.execute(new DeleteMeCommand(req.userId));
  }
}
