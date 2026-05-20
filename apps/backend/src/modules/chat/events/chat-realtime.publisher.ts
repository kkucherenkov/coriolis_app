/**
 * WHY this file exists:
 * Routes ChatMessage domain events to Centrifugo channels so connected clients
 * receive real-time updates without polling.
 *
 * Channel routing rules (Stream C/7):
 *   - Broadcast messages (targetMembershipId === null):
 *       → session.<gameSessionId>.chat
 *   - Whisper messages (targetMembershipId !== null):
 *       → session.<gameSessionId>.member.<authorMembershipId>
 *       → session.<gameSessionId>.member.<targetMembershipId>
 *       (deduplicated when author === target; whispers NEVER hit the .chat channel)
 *
 * All Centrifugo publishes are non-fatal: a failure is logged and swallowed so
 * that command handlers already returning 201/204 are unaffected. This matches
 * the pattern established in roll-pushed.handler.ts.
 *
 * Channel construction and envelope serialisation are delegated to RealtimeRouter
 * (apps/backend/src/modules/realtime/realtime-router.ts) — the single source of
 * truth for all Centrifugo channel names and payload shapes in the backend.
 */
import { Injectable } from '@nestjs/common';
import { EventsHandler, IEventHandler } from '@nestjs/cqrs';

import { RealtimeRouter } from '../../realtime/realtime-router';
import { ChatMessageDeletedEvent } from './chat-message-deleted.event';
import { ChatMessageEditedEvent } from './chat-message-edited.event';
import { ChatMessagePostedEvent } from './chat-message-posted.event';

import type { ChatMessageReadModel } from '../domain/chat.ports';

// ---------------------------------------------------------------------------
// PostedEvent handler
// ---------------------------------------------------------------------------

@Injectable()
@EventsHandler(ChatMessagePostedEvent)
export class ChatMessagePostedPublisher implements IEventHandler<ChatMessagePostedEvent> {
  constructor(private readonly realtimeRouter: RealtimeRouter) {}

  async handle(event: ChatMessagePostedEvent): Promise<void> {
    const msg: ChatMessageReadModel = event.message;
    await this.realtimeRouter.publishChatMessage(
      msg.gameSessionId,
      msg.authorMembershipId,
      msg.targetMembershipId,
      msg,
    );
  }
}

// ---------------------------------------------------------------------------
// EditedEvent handler
// ---------------------------------------------------------------------------

@Injectable()
@EventsHandler(ChatMessageEditedEvent)
export class ChatMessageEditedPublisher implements IEventHandler<ChatMessageEditedEvent> {
  constructor(private readonly realtimeRouter: RealtimeRouter) {}

  async handle(event: ChatMessageEditedEvent): Promise<void> {
    const msg: ChatMessageReadModel = event.message;
    await this.realtimeRouter.publishChatMessage(
      msg.gameSessionId,
      msg.authorMembershipId,
      msg.targetMembershipId,
      msg,
    );
  }
}

// ---------------------------------------------------------------------------
// DeletedEvent handler
// ---------------------------------------------------------------------------

@Injectable()
@EventsHandler(ChatMessageDeletedEvent)
export class ChatMessageDeletedPublisher implements IEventHandler<ChatMessageDeletedEvent> {
  constructor(private readonly realtimeRouter: RealtimeRouter) {}

  async handle(event: ChatMessageDeletedEvent): Promise<void> {
    const { id, gameSessionId, authorMembershipId, targetMembershipId, deletedAt } = event.payload;
    await this.realtimeRouter.publishChatMessageDeleted(
      gameSessionId,
      authorMembershipId,
      targetMembershipId,
      { id, gameSessionId, targetMembershipId, deletedAt },
    );
  }
}
