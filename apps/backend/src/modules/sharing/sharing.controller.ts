/**
 * WHY this file exists:
 * Owner-side HTTP entry point for the sharing bounded context.
 * Authenticated endpoints only — requires SessionGuard on all routes.
 * Job: validate → dispatch CommandBus/QueryBus → return. No Prisma, no business logic.
 *
 * The `userId` is sourced exclusively from the authenticated session via
 * req.userId — never from the request body or path params.
 */
import {
  Body,
  Controller,
  Delete,
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

import { CreateShareLinkCommand, CreateShareLinkDto } from './commands/create-share-link.command';
import { RevokeShareLinkCommand } from './commands/revoke-share-link.command';
import { ListShareLinksQuery } from './queries/list-share-links.query';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';
import type { ShareLinkReadModel } from './domain/share-link.ports';

interface ShareLinkListResponse {
  items: ShareLinkReadModel[];
}

@UseGuards(SessionGuard)
@Controller({ version: '1' })
export class SharingController {
  constructor(
    private readonly commandBus: CommandBus,
    private readonly queryBus: QueryBus,
  ) {}

  /** POST /api/v1/characters/:id/share */
  @Post('characters/:id/share')
  @HttpCode(HttpStatus.CREATED)
  async createShareLink(
    @Req() req: AuthenticatedRequest,
    @Param('id') characterId: string,
    @Body() body: CreateShareLinkDto,
  ): Promise<ShareLinkReadModel> {
    return this.commandBus.execute(new CreateShareLinkCommand(req.userId, characterId, body));
  }

  /** GET /api/v1/characters/:id/shares */
  @Get('characters/:id/shares')
  async listShareLinks(
    @Req() req: AuthenticatedRequest,
    @Param('id') characterId: string,
  ): Promise<ShareLinkListResponse> {
    return this.queryBus.execute(new ListShareLinksQuery(req.userId, characterId));
  }

  /** DELETE /api/v1/share-links/:id */
  @Delete('share-links/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async revokeShareLink(
    @Req() req: AuthenticatedRequest,
    @Param('id') shareLinkId: string,
  ): Promise<void> {
    return this.commandBus.execute(new RevokeShareLinkCommand(req.userId, shareLinkId));
  }
}
