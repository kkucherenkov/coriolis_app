/**
 * WHY this file exists:
 * REST surface for managing per-session chat blocks, scoped under
 * /api/v1/game-sessions/:gameSessionId/blocks.
 *
 * POST   ''                       → block a member (204)
 * DELETE :targetMembershipId      → unblock a member (204)
 * GET    ''                       → list blocks for the caller
 *
 * Commands are self-contained: BlockMemberHandler/UnblockMemberHandler resolve
 * the caller's membership internally via MEMBERSHIP_REPO, so the controller
 * does not need a pre-flight lookup for block/unblock. ListBlocksQuery likewise
 * resolves membership internally.
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

import { SessionGuard } from '../../../common/auth/auth.guard';
import { BlockMemberCommand } from '../commands/block-member.command';
import { UnblockMemberCommand } from '../commands/unblock-member.command';
import { ListBlocksQuery } from '../queries/list-blocks.query';
import { ChatBlockDto } from './dto/chat-block.dto';

import type { AuthenticatedRequest } from '../../../common/auth/auth.guard';
import type { ChatBlockSummaryReadModel } from '../domain/chat.ports';

@UseGuards(SessionGuard)
@Controller({ path: 'game-sessions/:gameSessionId/blocks', version: '1' })
export class ChatBlocksController {
  constructor(
    private readonly commandBus: CommandBus,
    private readonly queryBus: QueryBus,
  ) {}

  /** POST /api/v1/game-sessions/:gameSessionId/blocks */
  @Post()
  @HttpCode(HttpStatus.NO_CONTENT)
  async blockMember(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
    @Body() dto: ChatBlockDto,
  ): Promise<void> {
    return this.commandBus.execute(
      new BlockMemberCommand(gameSessionId, req.userId, dto.targetMembershipId),
    );
  }

  /** DELETE /api/v1/game-sessions/:gameSessionId/blocks/:targetMembershipId */
  @Delete(':targetMembershipId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async unblockMember(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
    @Param('targetMembershipId') targetMembershipId: string,
  ): Promise<void> {
    return this.commandBus.execute(
      new UnblockMemberCommand(gameSessionId, req.userId, targetMembershipId),
    );
  }

  /** GET /api/v1/game-sessions/:gameSessionId/blocks */
  @Get()
  async listBlocks(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
  ): Promise<{ items: ChatBlockSummaryReadModel[] }> {
    const items = await this.queryBus.execute<ListBlocksQuery, ChatBlockSummaryReadModel[]>(
      new ListBlocksQuery(gameSessionId, req.userId),
    );
    return { items };
  }
}
