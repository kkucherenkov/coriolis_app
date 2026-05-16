/**
 * WHY this file exists:
 * Shared mapper used by ChatMessageRepo so that the Prisma-row →
 * ChatMessageReadModel projection is never duplicated. Lives in domain/
 * (not infra/) because it is a pure data transformation with no I/O —
 * safe to import from either layer.
 *
 * displayName resolution follows the same pattern as membership.mapper.ts:
 * GameSessionMembership has no direct `user` relation in the schema, so
 * the repo fetches displayNames via a separate User query and passes the
 * result in here.
 */
import type { Prisma } from '@prisma/client';

import type {
  ChatBlockSummaryReadModel,
  ChatMessageKind,
  ChatMessageReadModel,
  ConversationKey,
  ConversationSummaryReadModel,
} from './chat.ports';

/**
 * Prisma select constant for ChatMessage rows.
 * Author displayName is NOT included here — the repo fetches it from the
 * User table via a separate findMany (same pattern as MembershipRepo).
 */
export const CHAT_MESSAGE_SELECT = {
  id: true,
  gameSessionId: true,
  authorMembershipId: true,
  targetMembershipId: true,
  kind: true,
  body: true,
  systemKey: true,
  systemParams: true,
  createdAt: true,
  editedAt: true,
  deletedAt: true,
} as const satisfies Prisma.ChatMessageSelect;

/** Inferred row type matching the CHAT_MESSAGE_SELECT above. */
export type ChatMessageRow = Prisma.ChatMessageGetPayload<{
  select: typeof CHAT_MESSAGE_SELECT;
}>;

/**
 * Converts a raw Prisma ChatMessage row + author displayName to the
 * domain read model. Dates are converted to ISO-8601 strings; JSON
 * systemParams are passed through as-is.
 */
export function toChatMessageReadModel(
  row: ChatMessageRow,
  authorDisplayName: string | null,
): ChatMessageReadModel {
  return {
    id: row.id,
    gameSessionId: row.gameSessionId,
    authorMembershipId: row.authorMembershipId,
    authorDisplayName,
    targetMembershipId: row.targetMembershipId,
    kind: row.kind as ChatMessageKind,
    body: row.body,
    systemKey: row.systemKey,
    systemParams: (row.systemParams as Record<string, unknown> | null) ?? null,
    createdAt: row.createdAt.toISOString(),
    editedAt: row.editedAt?.toISOString() ?? null,
    deletedAt: row.deletedAt?.toISOString() ?? null,
  };
}

/**
 * Converts raw conversation data to a ConversationSummaryReadModel.
 * This is a pure converter — no I/O.
 */
export function toConversationSummary(input: {
  conversationKey: ConversationKey;
  kind: 'broadcast' | 'whisper';
  partnerMembershipId: string | null;
  partnerDisplayName: string | null;
  partnerCharacterName: string | null;
  lastMessageAt: Date | string | null;
  unreadCount: number;
}): ConversationSummaryReadModel {
  const lastMessageAt =
    input.lastMessageAt instanceof Date
      ? input.lastMessageAt.toISOString()
      : (input.lastMessageAt ?? null);

  return {
    conversationKey: input.conversationKey,
    kind: input.kind,
    partnerMembershipId: input.partnerMembershipId,
    partnerDisplayName: input.partnerDisplayName,
    partnerCharacterName: input.partnerCharacterName,
    lastMessageAt,
    unreadCount: input.unreadCount,
  };
}
