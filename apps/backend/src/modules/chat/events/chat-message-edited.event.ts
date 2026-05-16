import type { ChatMessageReadModel } from '../domain/chat.ports';

/**
 * Emitted by EditChatMessageHandler after the body is updated.
 * Consumers (Task 7): ChatRealtimePublisher — same routing as posted.
 */
export class ChatMessageEditedEvent {
  constructor(public readonly message: ChatMessageReadModel) {}
}
