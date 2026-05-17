/**
 * WHY this file exists:
 * REST surface for posting and listing chat messages within a game session.
 * Scoped under /api/v1/game-sessions/:gameSessionId/chat — mirrors the
 * membership controller convention of nesting resources under the parent
 * session route.
 *
 * Pre-flight membership resolution ensures only active members of the session
 * can post or read chat messages. Throws ChatNotMemberError (403) when the
 * caller is not an active member.
 */
import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Inject,
  Param,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { CommandBus, QueryBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../../common/auth/auth.guard';
import { MEMBERSHIP_REPO } from '../../memberships/domain/membership.ports';
import { PostChatMessageCommand } from '../commands/post-chat-message.command';
import { ChatNotMemberError } from '../domain/chat.errors';
import { ListChatMessagesQuery } from '../queries/list-chat-messages.query';
import { PostChatMessageDto } from './dto/post-chat-message.dto';

import type { AuthenticatedRequest } from '../../../common/auth/auth.guard';
import type { IMembershipRepo } from '../../memberships/domain/membership.ports';
import type { ChatMessageReadModel } from '../domain/chat.ports';

@UseGuards(SessionGuard)
@Controller({ path: 'game-sessions/:gameSessionId/chat', version: '1' })
export class ChatMessagesController {
  constructor(
    private readonly commandBus: CommandBus,
    private readonly queryBus: QueryBus,
    @Inject(MEMBERSHIP_REPO) private readonly memberships: IMembershipRepo,
  ) {}

  /** POST /api/v1/game-sessions/:gameSessionId/chat/messages */
  @Post('messages')
  @HttpCode(HttpStatus.CREATED)
  async postMessage(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
    @Body() dto: PostChatMessageDto,
  ): Promise<ChatMessageReadModel> {
    const callerMembership = await this.memberships.findActiveByUser(gameSessionId, req.userId);
    if (!callerMembership) throw new ChatNotMemberError();

    return this.commandBus.execute(
      new PostChatMessageCommand(
        gameSessionId,
        req.userId,
        callerMembership.id,
        dto.targetMembershipId ?? null,
        dto.body,
      ),
    );
  }

  /** GET /api/v1/game-sessions/:gameSessionId/chat/messages */
  @Get('messages')
  async listMessages(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
    @Query('conversation') conversation?: string,
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: string,
  ): Promise<{ items: ChatMessageReadModel[]; nextCursor: string | null }> {
    return this.queryBus.execute(
      new ListChatMessagesQuery(
        gameSessionId,
        req.userId,
        conversation ?? 'broadcast',
        cursor ?? null,
        Number.parseInt(limit ?? '50', 10),
      ),
    );
  }
}
