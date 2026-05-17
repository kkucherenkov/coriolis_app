/**
 * WHY this file exists:
 * Port interfaces and read models for the chat bounded context.
 * All interfaces are pure TypeScript — no framework or Prisma imports.
 * Adapters live in infra/ and are registered via DI tokens.
 */

// 'broadcast' or a membershipId — kept as `string` because membershipId values
// are not statically known. The 'broadcast' literal is documented intent, not
// a type constraint.
export type ConversationKey = string;

export type ChatMessageKind = 'text' | 'system';

export interface ChatMessageReadModel {
  id: string;
  gameSessionId: string;
  authorMembershipId: string | null;
  authorDisplayName: string | null;
  targetMembershipId: string | null;
  kind: ChatMessageKind;
  body: string | null;
  systemKey: string | null;
  systemParams: Record<string, unknown> | null;
  createdAt: string;
  editedAt: string | null;
  deletedAt: string | null;
}

export interface ConversationSummaryReadModel {
  conversationKey: ConversationKey;
  kind: 'broadcast' | 'whisper';
  partnerMembershipId: string | null;
  partnerDisplayName: string | null;
  partnerCharacterName: string | null;
  lastMessageAt: string | null;
  unreadCount: number;
}

export interface ChatBlockSummaryReadModel {
  targetMembershipId: string;
  targetDisplayName: string | null;
  createdAt: string;
}

export interface ListMessagesArgs {
  gameSessionId: string;
  callerMembershipId: string;
  conversation: ConversationKey;
  cursor: string | null;
  limit: number;
}

export const CHAT_MESSAGE_REPO = Symbol('CHAT_MESSAGE_REPO');
export interface IChatMessageRepo {
  insert(data: {
    gameSessionId: string;
    authorMembershipId: string | null;
    targetMembershipId: string | null;
    kind: ChatMessageKind;
    body: string | null;
    systemKey: string | null;
    systemParams: Record<string, unknown> | null;
  }): Promise<ChatMessageReadModel>;

  findById(id: string): Promise<ChatMessageReadModel | null>;
  updateBody(id: string, body: string, editedAt: Date): Promise<ChatMessageReadModel>;
  softDelete(id: string, deletedAt: Date): Promise<ChatMessageReadModel>;
  list(
    args: ListMessagesArgs,
  ): Promise<{ items: ChatMessageReadModel[]; nextCursor: string | null }>;
  listConversations(args: {
    gameSessionId: string;
    callerMembershipId: string;
  }): Promise<ConversationSummaryReadModel[]>;

  /**
   * Returns the count of non-deleted messages in a conversation that were created
   * strictly after `after`. When `after` is null, counts ALL non-deleted messages.
   *
   * Design decision: returning `{ count, lastMessageAt }` in one call avoids a
   * separate `getLastAt` round-trip when prepending the synthetic broadcast row
   * in ListConversationsHandler — both values come from the same Prisma query.
   */
  countNewerThan(args: {
    gameSessionId: string;
    conversation: ConversationKey;
    callerMembershipId: string;
    after: Date | null;
  }): Promise<{ count: number; lastMessageAt: Date | null }>;
}

export const CHAT_READ_CURSOR_REPO = Symbol('CHAT_READ_CURSOR_REPO');
export interface IChatReadCursorRepo {
  upsert(args: {
    membershipId: string;
    conversationKey: ConversationKey;
    lastReadAt: Date;
  }): Promise<void>;
  getMap(args: {
    membershipId: string;
    keys: ConversationKey[];
  }): Promise<Map<ConversationKey, Date>>;
}

export const CHAT_BLOCK_REPO = Symbol('CHAT_BLOCK_REPO');
export interface IChatBlockRepo {
  exists(args: {
    gameSessionId: string;
    blockerMembershipId: string;
    blockedMembershipId: string;
  }): Promise<boolean>;
  insert(args: {
    gameSessionId: string;
    blockerMembershipId: string;
    blockedMembershipId: string;
  }): Promise<void>;
  delete(args: {
    gameSessionId: string;
    blockerMembershipId: string;
    blockedMembershipId: string;
  }): Promise<void>;
  listForBlocker(args: {
    gameSessionId: string;
    blockerMembershipId: string;
  }): Promise<ChatBlockSummaryReadModel[]>;
}

export const CHAT_RATE_LIMITER = Symbol('CHAT_RATE_LIMITER');
export interface IChatRateLimiter {
  /** Throws ChatRateLimitedError if the user exceeded 30/min or the 5/s burst. */
  consume(userId: string, now: Date): Promise<void>;
}

// Re-export the error type so callers can reference the thrown type without
// reaching into chat.errors directly.

export { type ChatRateLimitedError } from './chat.errors';
