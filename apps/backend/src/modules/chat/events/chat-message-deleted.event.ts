/**
 * Emitted by DeleteChatMessageHandler after soft-delete is applied.
 * Carries a minimal payload so subscribers can tombstone the message
 * without receiving the full body.
 *
 * Consumers (Task 7): ChatRealtimePublisher — same channel routing as posted.
 */
export class ChatMessageDeletedEvent {
  constructor(
    public readonly payload: {
      id: string;
      gameSessionId: string;
      authorMembershipId: string | null;
      targetMembershipId: string | null;
      deletedAt: string;
    },
  ) {}
}
