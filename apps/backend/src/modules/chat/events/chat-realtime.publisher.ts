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
 */
import { Inject, Logger } from '@nestjs/common';
import { EventsHandler, IEventHandler } from '@nestjs/cqrs';

import { CENTRIFUGO_CLIENT, type ICentrifugoClient } from '../../realtime/centrifugo.client';
import { ChatMessageDeletedEvent } from './chat-message-deleted.event';
import { ChatMessageEditedEvent } from './chat-message-edited.event';
import { ChatMessagePostedEvent } from './chat-message-posted.event';

import type { ChatMessageReadModel } from '../domain/chat.ports';

// ---------------------------------------------------------------------------
// Shared routing helpers
// ---------------------------------------------------------------------------

function buildChannels(
  gameSessionId: string,
  authorMembershipId: string | null,
  targetMembershipId: string | null,
): string[] {
  if (targetMembershipId === null) {
    return [`session.${gameSessionId}.chat`];
  }

  // Whisper — publish to both member channels; dedupe when author === target.
  const channels: string[] = [`session.${gameSessionId}.member.${targetMembershipId}`];
  if (authorMembershipId !== null && authorMembershipId !== targetMembershipId) {
    channels.push(`session.${gameSessionId}.member.${authorMembershipId}`);
  } else if (authorMembershipId !== null && authorMembershipId === targetMembershipId) {
    // Self-whisper: only the single member channel is needed (already added above).
  }
  return channels;
}

async function publishToChannels(
  centrifugo: ICentrifugoClient,
  logger: Logger,
  channels: string[],
  payload: Record<string, unknown>,
  context: string,
): Promise<void> {
  for (const channel of channels) {
    try {
      await centrifugo.publish(channel, payload);
    } catch (error) {
      logger.error(`Failed to publish ${context} to ${channel}: ${String(error)}`);
    }
  }
}

// ---------------------------------------------------------------------------
// PostedEvent handler
// ---------------------------------------------------------------------------

@EventsHandler(ChatMessagePostedEvent)
export class ChatMessagePostedPublisher implements IEventHandler<ChatMessagePostedEvent> {
  private readonly logger = new Logger(ChatMessagePostedPublisher.name);

  constructor(@Inject(CENTRIFUGO_CLIENT) private readonly centrifugo: ICentrifugoClient) {}

  async handle(event: ChatMessagePostedEvent): Promise<void> {
    const msg: ChatMessageReadModel = event.message;
    const channels = buildChannels(
      msg.gameSessionId,
      msg.authorMembershipId,
      msg.targetMembershipId,
    );
    const payload = msg as unknown as Record<string, unknown>;
    await publishToChannels(this.centrifugo, this.logger, channels, payload, 'chat.message.posted');
  }
}

// ---------------------------------------------------------------------------
// EditedEvent handler
// ---------------------------------------------------------------------------

@EventsHandler(ChatMessageEditedEvent)
export class ChatMessageEditedPublisher implements IEventHandler<ChatMessageEditedEvent> {
  private readonly logger = new Logger(ChatMessageEditedPublisher.name);

  constructor(@Inject(CENTRIFUGO_CLIENT) private readonly centrifugo: ICentrifugoClient) {}

  async handle(event: ChatMessageEditedEvent): Promise<void> {
    const msg: ChatMessageReadModel = event.message;
    const channels = buildChannels(
      msg.gameSessionId,
      msg.authorMembershipId,
      msg.targetMembershipId,
    );
    const payload = msg as unknown as Record<string, unknown>;
    await publishToChannels(this.centrifugo, this.logger, channels, payload, 'chat.message.edited');
  }
}

// ---------------------------------------------------------------------------
// DeletedEvent handler
// ---------------------------------------------------------------------------

@EventsHandler(ChatMessageDeletedEvent)
export class ChatMessageDeletedPublisher implements IEventHandler<ChatMessageDeletedEvent> {
  private readonly logger = new Logger(ChatMessageDeletedPublisher.name);

  constructor(@Inject(CENTRIFUGO_CLIENT) private readonly centrifugo: ICentrifugoClient) {}

  async handle(event: ChatMessageDeletedEvent): Promise<void> {
    const { id, gameSessionId, authorMembershipId, targetMembershipId, deletedAt } = event.payload;
    const channels = buildChannels(gameSessionId, authorMembershipId, targetMembershipId);
    const payload: Record<string, unknown> = { id, gameSessionId, targetMembershipId, deletedAt };
    await publishToChannels(
      this.centrifugo,
      this.logger,
      channels,
      payload,
      'chat.message.deleted',
    );
  }
}
