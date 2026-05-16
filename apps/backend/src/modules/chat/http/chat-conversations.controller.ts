/**
 * WHY this file exists:
 * REST surface for conversation listing and read-cursor management, scoped
 * under /api/v1/game-sessions/:gameSessionId/chat/conversations.
 *
 * GET  ''                    → list all conversations the caller participates in
 * POST :conversationKey/read → advance the last-read cursor for a conversation
 *
 * The conversationKey is either the literal string "broadcast" or a
 * membershipId (whisper partner). NestJS decodes URL-encoded path params by
 * default — no special handling required.
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
  Req,
  UseGuards,
} from '@nestjs/common';
import { CommandBus, QueryBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../../common/auth/auth.guard';
import { MEMBERSHIP_REPO } from '../../memberships/domain/membership.ports';
import { MarkConversationReadCommand } from '../commands/mark-conversation-read.command';
import { ChatNotMemberError } from '../domain/chat.errors';
import { ListConversationsQuery } from '../queries/list-conversations.query';
import { MarkReadDto } from './dto/mark-read.dto';

import type { AuthenticatedRequest } from '../../../common/auth/auth.guard';
import type { IMembershipRepo } from '../../memberships/domain/membership.ports';
import type { ConversationSummaryReadModel } from '../domain/chat.ports';

@UseGuards(SessionGuard)
@Controller({ path: 'game-sessions/:gameSessionId/chat/conversations', version: '1' })
export class ChatConversationsController {
  constructor(
    private readonly commandBus: CommandBus,
    private readonly queryBus: QueryBus,
    @Inject(MEMBERSHIP_REPO) private readonly memberships: IMembershipRepo,
  ) {}

  /** GET /api/v1/game-sessions/:gameSessionId/chat/conversations */
  @Get()
  async listConversations(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
  ): Promise<{ items: ConversationSummaryReadModel[] }> {
    const items = await this.queryBus.execute<
      ListConversationsQuery,
      ConversationSummaryReadModel[]
    >(new ListConversationsQuery(gameSessionId, req.userId));
    return { items };
  }

  /** POST /api/v1/game-sessions/:gameSessionId/chat/conversations/:conversationKey/read */
  @Post(':conversationKey/read')
  @HttpCode(HttpStatus.NO_CONTENT)
  async markRead(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
    @Param('conversationKey') conversationKey: string,
    @Body() dto: MarkReadDto,
  ): Promise<void> {
    const callerMembership = await this.memberships.findActiveByUser(gameSessionId, req.userId);
    if (!callerMembership) throw new ChatNotMemberError();

    return this.commandBus.execute(
      new MarkConversationReadCommand(
        gameSessionId,
        req.userId,
        conversationKey,
        new Date(dto.lastReadAt),
      ),
    );
  }
}
