/**
 * WHY this file exists:
 * Routes for invite endpoints that cannot live in MembershipsController
 * (which is scoped to /game-sessions/:gameSessionId). These routes are under
 * /invites/:token — separate resource tree. The preview route is public
 * (no SessionGuard); the accept route requires auth.
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

import { SessionGuard } from '../../../common/auth/auth.guard';
import { AcceptInviteCommand } from '../commands/accept-invite.command';
import { GetInvitePreviewQuery } from '../queries/get-invite-preview.query';

import type { AuthenticatedRequest } from '../../../common/auth/auth.guard';
import type { InvitePreviewReadModel, MembershipReadModel } from '../domain/membership.ports';
import type { Request } from 'express';

interface AcceptInviteBody {
  characterId?: string | null;
}

@Controller({ path: 'invites', version: '1' })
export class InvitesController {
  constructor(
    private readonly queryBus: QueryBus,
    private readonly commandBus: CommandBus,
  ) {}

  /** GET /api/v1/invites/:token/preview — public, no auth required */
  @Get(':token/preview')
  async getPreview(
    @Param('token') token: string,
    @Req() req: Request,
  ): Promise<InvitePreviewReadModel> {
    // userId is only present when SessionGuard has run on a previous middleware.
    // Cast through unknown to avoid the strict-null lint error on a field that
    // is typed `string` on AuthenticatedRequest but absent on plain Request.
    const callerUserId = (req as unknown as Partial<AuthenticatedRequest>).userId ?? null;
    return this.queryBus.execute<GetInvitePreviewQuery, InvitePreviewReadModel>(
      new GetInvitePreviewQuery(token, callerUserId),
    );
  }

  /** POST /api/v1/invites/:token/accept — auth required */
  @Post(':token/accept')
  @UseGuards(SessionGuard)
  @HttpCode(HttpStatus.OK)
  async accept(
    @Param('token') token: string,
    @Body() body: AcceptInviteBody,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ membership: MembershipReadModel }> {
    const membership = await this.commandBus.execute<AcceptInviteCommand, MembershipReadModel>(
      new AcceptInviteCommand(token, req.userId, body.characterId ?? null),
    );
    return { membership };
  }
}
