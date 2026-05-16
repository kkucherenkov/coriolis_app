/**
 * WHY this file exists:
 * Composition root for the chat bounded context. Wires 7 command handlers,
 * 4 query handlers, 3 event publishers, 4 infra adapters, 4 controllers,
 * and the DI token bindings for the 4 ports.
 *
 * MembershipsModule is imported so MEMBERSHIP_REPO is available to command
 * handlers and controllers that need cross-session membership resolution.
 * PrismaModule is @Global() (via AppModule), so repos can inject PrismaService
 * without a local import. RealtimeModule is imported to make CENTRIFUGO_CLIENT
 * available to the three event publishers (mirrors EncountersModule pattern).
 * AuthModule is @Global(), so SessionGuard is available on all controllers.
 */
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { MembershipsModule } from '../memberships/memberships.module';
import { RealtimeModule } from '../realtime/realtime.module';

import { BlockMemberHandler } from './commands/block-member.handler';
import { DeleteChatMessageHandler } from './commands/delete-chat-message.handler';
import { EditChatMessageHandler } from './commands/edit-chat-message.handler';
import { MarkConversationReadHandler } from './commands/mark-conversation-read.handler';
import { PostChatMessageHandler } from './commands/post-chat-message.handler';
import { PostSystemMessageHandler } from './commands/post-system-message.handler';
import { UnblockMemberHandler } from './commands/unblock-member.handler';
import {
  CHAT_BLOCK_REPO,
  CHAT_MESSAGE_REPO,
  CHAT_RATE_LIMITER,
  CHAT_READ_CURSOR_REPO,
} from './domain/chat.ports';
import {
  ChatMessageDeletedPublisher,
  ChatMessageEditedPublisher,
  ChatMessagePostedPublisher,
} from './events/chat-realtime.publisher';
import { ChatBlocksController } from './http/chat-blocks.controller';
import { ChatConversationsController } from './http/chat-conversations.controller';
import { ChatMessageController } from './http/chat-message.controller';
import { ChatMessagesController } from './http/chat-messages.controller';
import { ChatBlockRepo } from './infra/chat-block.repo';
import { ChatMessageRepo } from './infra/chat-message.repo';
import { ChatRateLimiterService } from './infra/chat-rate-limiter.service';
import { ChatReadCursorRepo } from './infra/chat-read-cursor.repo';
import { GetChatMessageHandler } from './queries/get-chat-message.handler';
import { ListBlocksHandler } from './queries/list-blocks.handler';
import { ListChatMessagesHandler } from './queries/list-chat-messages.handler';
import { ListConversationsHandler } from './queries/list-conversations.handler';

@Module({
  imports: [CqrsModule, MembershipsModule, RealtimeModule],
  controllers: [
    ChatMessagesController,
    ChatMessageController,
    ChatConversationsController,
    ChatBlocksController,
  ],
  providers: [
    // Command handlers
    PostChatMessageHandler,
    PostSystemMessageHandler,
    EditChatMessageHandler,
    DeleteChatMessageHandler,
    MarkConversationReadHandler,
    BlockMemberHandler,
    UnblockMemberHandler,

    // Query handlers
    GetChatMessageHandler,
    ListChatMessagesHandler,
    ListConversationsHandler,
    ListBlocksHandler,

    // Event publishers
    ChatMessagePostedPublisher,
    ChatMessageEditedPublisher,
    ChatMessageDeletedPublisher,

    // Infra adapters (concrete classes)
    ChatMessageRepo,
    ChatReadCursorRepo,
    ChatBlockRepo,
    ChatRateLimiterService,

    // Port bindings
    { provide: CHAT_MESSAGE_REPO, useExisting: ChatMessageRepo },
    { provide: CHAT_READ_CURSOR_REPO, useExisting: ChatReadCursorRepo },
    { provide: CHAT_BLOCK_REPO, useExisting: ChatBlockRepo },
    { provide: CHAT_RATE_LIMITER, useExisting: ChatRateLimiterService },
  ],
})
export class ChatModule {}
