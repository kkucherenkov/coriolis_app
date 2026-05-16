import type { ChatMessageReadModel } from '../domain/chat.ports';

/**
 * Emitted by PostChatMessageHandler and PostSystemMessageHandler after a message
 * is persisted. Consumers (Task 7): ChatRealtimePublisher — routes to
 * session.<id>.chat (broadcast) or per-member channel (whisper).
 */
export class ChatMessagePostedEvent {
  constructor(public readonly message: ChatMessageReadModel) {}
}
