/**
 * WHY this file exists:
 * HTTP entry point for the memberships bounded context. Mounts six
 * operations under /api/v1/game-sessions/{id}. URLs match the OpenAPI
 * spec one-to-one — controller paths use the existing game-sessions
 * resource prefix so the membership/invite surface is nested under
 * the parent GameSession, mirroring the spec.
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

import { KickMemberCommand } from './commands/kick-member.command';
import { LeaveSessionCommand } from './commands/leave-session.command';
import { LinkCharacterCommand } from './commands/link-character.command';
import { RevokeInviteCommand } from './commands/revoke-invite.command';
import { RotateInviteCommand } from './commands/rotate-invite.command';
import { GetInviteMetadataQuery } from './queries/get-invite-metadata.query';
import { ListMembershipsQuery } from './queries/list-memberships.query';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';
import type { RotateInviteResult } from './commands/rotate-invite.handler';
import type { InviteMetadataReadModel, MembershipReadModel } from './domain/membership.ports';

interface LinkCharacterBody {
  characterId: string | null;
}

@UseGuards(SessionGuard)
@Controller({ path: 'game-sessions/:gameSessionId', version: '1' })
export class MembershipsController {
  constructor(
    private readonly queryBus: QueryBus,
    private readonly commandBus: CommandBus,
  ) {}

  /** GET /api/v1/game-sessions/:gameSessionId/invite */
  @Get('invite')
  async getInviteMetadata(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
  ): Promise<InviteMetadataReadModel> {
    return this.queryBus.execute(new GetInviteMetadataQuery(gameSessionId, req.userId));
  }

  /** POST /api/v1/game-sessions/:gameSessionId/invite/rotate */
  @Post('invite/rotate')
  @HttpCode(HttpStatus.OK)
  async rotateInvite(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
  ): Promise<RotateInviteResult> {
    return this.commandBus.execute(new RotateInviteCommand(gameSessionId, req.userId));
  }

  /** DELETE /api/v1/game-sessions/:gameSessionId/invite */
  @Delete('invite')
  @HttpCode(HttpStatus.NO_CONTENT)
  async revokeInvite(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
  ): Promise<void> {
    return this.commandBus.execute(new RevokeInviteCommand(gameSessionId, req.userId));
  }

  /** GET /api/v1/game-sessions/:gameSessionId/members */
  @Get('members')
  async listMembers(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
  ): Promise<MembershipReadModel[]> {
    return this.queryBus.execute(new ListMembershipsQuery(gameSessionId, req.userId));
  }

  /** PATCH /api/v1/game-sessions/:gameSessionId/members/:membershipId */
  @Patch('members/:membershipId')
  @HttpCode(HttpStatus.OK)
  async linkCharacter(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
    @Param('membershipId') membershipId: string,
    @Body() body: LinkCharacterBody,
  ): Promise<MembershipReadModel> {
    return this.commandBus.execute(
      new LinkCharacterCommand(gameSessionId, req.userId, membershipId, body.characterId),
    );
  }

  /**
   * DELETE /api/v1/game-sessions/:gameSessionId/members/:membershipId
   *
   * Self-leave or GM-kick. The handler picks the right command by
   * inspecting whether the caller owns the membership; this controller
   * dispatches both possibilities and the first one that does not throw
   * wins. To keep that simple we dispatch LeaveSessionCommand first
   * (it only succeeds for self) and fall through to KickMemberCommand
   * for the GM. Errors from the kick handler are surfaced.
   */
  @Delete('members/:membershipId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async removeMember(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
    @Param('membershipId') membershipId: string,
  ): Promise<void> {
    try {
      return await this.commandBus.execute(
        new LeaveSessionCommand(gameSessionId, req.userId, membershipId),
      );
    } catch (e) {
      // If self-leave was refused (e.g. caller is not the owning user
      // OR it's the GM trying to kick a player), fall through to the
      // GM-kick path. KickMemberHandler will throw GameSessionNotOwnerError
      // for non-GM callers, which is the right surface here.
      if (e instanceof Error && (e as { code?: string }).code === 'MEMBERSHIP_NOT_AUTHORIZED') {
        return this.commandBus.execute(
          new KickMemberCommand(gameSessionId, req.userId, membershipId),
        );
      }
      throw e;
    }
  }
}
