/**
 * WHY this file exists:
 * REST surface for single-message operations: GET, PATCH, DELETE under
 * /api/v1/chat/messages/:id. These routes are NOT nested under a game-session
 * because the caller knows the message id but may not know which session it
 * belongs to. The controller resolves the session from the message itself.
 *
 * Cross-session pre-flight pattern:
 *   1. chatRepo.findById(messageId) → if null, throw ChatMessageNotFoundError (404).
 *   2. memberships.findActiveByUser(msg.gameSessionId, userId) → if null, throw
 *      ChatMessageNotFoundError (404) — privacy contract: non-members must not
 *      know the message exists.
 *   3. Dispatch the command, which re-validates visibility internally.
 *
 * NestJS DI resolves CHAT_MESSAGE_REPO from ChatModule providers directly.
 */
import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Inject,
  Param,
  Patch,
  Req,
  UseGuards,
} from '@nestjs/common';
import { CommandBus, QueryBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../../common/auth/auth.guard';
import { MEMBERSHIP_REPO } from '../../memberships/domain/membership.ports';
import { DeleteChatMessageCommand } from '../commands/delete-chat-message.command';
import { EditChatMessageCommand } from '../commands/edit-chat-message.command';
import { ChatMessageNotFoundError } from '../domain/chat.errors';
import { CHAT_MESSAGE_REPO } from '../domain/chat.ports';
import { GetChatMessageQuery } from '../queries/get-chat-message.query';
import { EditChatMessageDto } from './dto/edit-chat-message.dto';

import type { AuthenticatedRequest } from '../../../common/auth/auth.guard';
import type { IMembershipRepo } from '../../memberships/domain/membership.ports';
import type { ChatMessageReadModel, IChatMessageRepo } from '../domain/chat.ports';

@UseGuards(SessionGuard)
@Controller({ path: 'chat/messages', version: '1' })
export class ChatMessageController {
  constructor(
    private readonly commandBus: CommandBus,
    private readonly queryBus: QueryBus,
    @Inject(MEMBERSHIP_REPO) private readonly memberships: IMembershipRepo,
    @Inject(CHAT_MESSAGE_REPO) private readonly chatRepo: IChatMessageRepo,
  ) {}

  /** GET /api/v1/chat/messages/:id */
  @Get(':id')
  async getMessage(
    @Req() req: AuthenticatedRequest,
    @Param('id') messageId: string,
  ): Promise<ChatMessageReadModel> {
    return this.queryBus.execute(new GetChatMessageQuery(messageId, req.userId));
  }

  /** PATCH /api/v1/chat/messages/:id */
  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  async editMessage(
    @Req() req: AuthenticatedRequest,
    @Param('id') messageId: string,
    @Body() dto: EditChatMessageDto,
  ): Promise<ChatMessageReadModel> {
    const message = await this.chatRepo.findById(messageId);
    if (!message) throw new ChatMessageNotFoundError();

    const callerMembership = await this.memberships.findActiveByUser(
      message.gameSessionId,
      req.userId,
    );
    if (!callerMembership) throw new ChatMessageNotFoundError();

    return this.commandBus.execute(
      new EditChatMessageCommand(messageId, req.userId, callerMembership.id, dto.body),
    );
  }

  /** DELETE /api/v1/chat/messages/:id */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteMessage(
    @Req() req: AuthenticatedRequest,
    @Param('id') messageId: string,
  ): Promise<void> {
    const message = await this.chatRepo.findById(messageId);
    if (!message) throw new ChatMessageNotFoundError();

    const callerMembership = await this.memberships.findActiveByUser(
      message.gameSessionId,
      req.userId,
    );
    if (!callerMembership) throw new ChatMessageNotFoundError();

    const isCallerGm = callerMembership.role === 'gm';

    return this.commandBus.execute(
      new DeleteChatMessageCommand(messageId, req.userId, callerMembership.id, isCallerGm),
    );
  }
}
