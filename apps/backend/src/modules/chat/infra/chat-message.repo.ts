/**
 * WHY this file exists:
 * Infrastructure adapter — the only file in the chat bounded context that
 * directly queries ChatMessage rows via PrismaService. Implements IChatMessageRepo.
 *
 * Display-name resolution is a two-step join:
 *   1. Load messages → collect distinct authorMembershipIds.
 *   2. prisma.gameSessionMembership.findMany → collect distinct userIds.
 *   3. prisma.user.findMany → build Map<userId, displayName>.
 *   4. Build Map<authorMembershipId, displayName> and pass to toChatMessageReadModel.
 *
 * This is two extra round-trips per list query (acceptable for v1.1 — single-node,
 * low-traffic). TODO: replace with a view-model materializer in a follow-up.
 *
 * Cursor pagination uses (createdAt DESC, id DESC) tie-breaking. Cursor tokens are
 * base64url-encoded JSON blobs from chat-cursor.ts. Invalid inbound cursors are
 * silently treated as "no cursor" (returns the first page) — friendlier than 400.
 *
 * listConversations uses prisma.chatMessage.groupBy to derive distinct whisper
 * partners without raw SQL. unreadCount is always 0 from the repo — the query
 * handler combines read-cursor state to compute real counts.
 */
import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../../../common/prisma/prisma.service';
import { decodeCursor, encodeCursor } from '../domain/chat-cursor';
import {
  CHAT_MESSAGE_SELECT,
  toChatMessageReadModel,
  toConversationSummary,
} from '../domain/chat.mapper';

import type {
  ChatMessageReadModel,
  ConversationSummaryReadModel,
  IChatMessageRepo,
  ListMessagesArgs,
} from '../domain/chat.ports';
import type { ChatMessageKind } from '../domain/chat.ports';

@Injectable()
export class ChatMessageRepo implements IChatMessageRepo {
  constructor(private readonly prisma: PrismaService) {}

  // ---------------------------------------------------------------------------
  // insert
  // ---------------------------------------------------------------------------

  async insert(data: {
    gameSessionId: string;
    authorMembershipId: string | null;
    targetMembershipId: string | null;
    kind: ChatMessageKind;
    body: string | null;
    systemKey: string | null;
    systemParams: Record<string, unknown> | null;
  }): Promise<ChatMessageReadModel> {
    const row = await this.prisma.chatMessage.create({
      data: {
        gameSessionId: data.gameSessionId,
        authorMembershipId: data.authorMembershipId,
        targetMembershipId: data.targetMembershipId,
        kind: data.kind,
        body: data.body,
        systemKey: data.systemKey,
        systemParams:
          data.systemParams !== null
            ? (data.systemParams as Prisma.InputJsonValue)
            : Prisma.JsonNull,
      },
      select: CHAT_MESSAGE_SELECT,
    });

    const displayNames = await this.fetchDisplayNamesByMembershipIds(
      row.authorMembershipId ? [row.authorMembershipId] : [],
    );

    return toChatMessageReadModel(
      row,
      row.authorMembershipId ? (displayNames.get(row.authorMembershipId) ?? null) : null,
    );
  }

  // ---------------------------------------------------------------------------
  // findById
  // ---------------------------------------------------------------------------

  async findById(id: string): Promise<ChatMessageReadModel | null> {
    const row = await this.prisma.chatMessage.findUnique({
      where: { id },
      select: CHAT_MESSAGE_SELECT,
    });
    if (!row) return null;

    const displayNames = await this.fetchDisplayNamesByMembershipIds(
      row.authorMembershipId ? [row.authorMembershipId] : [],
    );

    return toChatMessageReadModel(
      row,
      row.authorMembershipId ? (displayNames.get(row.authorMembershipId) ?? null) : null,
    );
  }

  // ---------------------------------------------------------------------------
  // updateBody
  // ---------------------------------------------------------------------------

  async updateBody(id: string, body: string, editedAt: Date): Promise<ChatMessageReadModel> {
    const row = await this.prisma.chatMessage.update({
      where: { id },
      data: { body, editedAt },
      select: CHAT_MESSAGE_SELECT,
    });

    const displayNames = await this.fetchDisplayNamesByMembershipIds(
      row.authorMembershipId ? [row.authorMembershipId] : [],
    );

    return toChatMessageReadModel(
      row,
      row.authorMembershipId ? (displayNames.get(row.authorMembershipId) ?? null) : null,
    );
  }

  // ---------------------------------------------------------------------------
  // softDelete
  // ---------------------------------------------------------------------------

  async softDelete(id: string, deletedAt: Date): Promise<ChatMessageReadModel> {
    const row = await this.prisma.chatMessage.update({
      where: { id },
      data: { deletedAt },
      select: CHAT_MESSAGE_SELECT,
    });

    const displayNames = await this.fetchDisplayNamesByMembershipIds(
      row.authorMembershipId ? [row.authorMembershipId] : [],
    );

    return toChatMessageReadModel(
      row,
      row.authorMembershipId ? (displayNames.get(row.authorMembershipId) ?? null) : null,
    );
  }

  // ---------------------------------------------------------------------------
  // list  (cursor-paginated)
  // ---------------------------------------------------------------------------

  async list(
    args: ListMessagesArgs,
  ): Promise<{ items: ChatMessageReadModel[]; nextCursor: string | null }> {
    const { gameSessionId, callerMembershipId, conversation, cursor: cursorToken, limit } = args;

    // Base where conditions
    const andClauses: Prisma.ChatMessageWhereInput[] = [];

    let baseWhere: Prisma.ChatMessageWhereInput;
    if (conversation === 'broadcast') {
      baseWhere = { gameSessionId, targetMembershipId: null, deletedAt: null };
    } else {
      // Whisper: conversation is partnerMembershipId
      const partnerMembershipId = conversation;
      baseWhere = {
        gameSessionId,
        deletedAt: null,
        OR: [
          { authorMembershipId: callerMembershipId, targetMembershipId: partnerMembershipId },
          { authorMembershipId: partnerMembershipId, targetMembershipId: callerMembershipId },
        ],
      };
    }

    // Decode cursor — silently ignore invalid tokens (returns first page)
    if (cursorToken) {
      try {
        const decoded = decodeCursor(cursorToken);
        andClauses.push({
          OR: [
            { createdAt: { lt: new Date(decoded.createdAt) } },
            { createdAt: new Date(decoded.createdAt), id: { lt: decoded.id } },
          ],
        });
      } catch {
        // Invalid cursor → treat as no cursor, return first page
      }
    }

    const where: Prisma.ChatMessageWhereInput =
      andClauses.length > 0 ? { ...baseWhere, AND: andClauses } : baseWhere;

    const rows = await this.prisma.chatMessage.findMany({
      where,
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
      select: CHAT_MESSAGE_SELECT,
    });

    // Determine if there's a next page
    let nextCursor: string | null = null;
    const hasMore = rows.length > limit;
    const pageRows = hasMore ? rows.slice(0, limit) : rows;
    if (hasMore) {
      // rows[limit] is the (limit+1)th item — it exists because hasMore === rows.length > limit
      const last = rows[limit]!;
      nextCursor = encodeCursor({ createdAt: last.createdAt.toISOString(), id: last.id });
    }

    // Resolve display names for all author memberships in the page
    const authorMembershipIds = [
      ...new Set(
        pageRows.map((r) => r.authorMembershipId).filter((id): id is string => id !== null),
      ),
    ];
    const displayNames = await this.fetchDisplayNamesByMembershipIds(authorMembershipIds);

    const items = pageRows.map((r) =>
      toChatMessageReadModel(
        r,
        r.authorMembershipId ? (displayNames.get(r.authorMembershipId) ?? null) : null,
      ),
    );

    return { items, nextCursor };
  }

  // ---------------------------------------------------------------------------
  // listConversations (whispers only — broadcast is prepended by query handler)
  // ---------------------------------------------------------------------------

  async listConversations(args: {
    gameSessionId: string;
    callerMembershipId: string;
  }): Promise<ConversationSummaryReadModel[]> {
    const { gameSessionId, callerMembershipId } = args;

    // Step 1: Find all (author, target) pairs involving the caller where
    //         targetMembershipId is non-null (whispers only).
    // NOTE: unreadCount is always 0 here — the query handler computes real counts
    // by combining read-cursor state with per-partner message counts.
    const groups = await this.prisma.chatMessage.groupBy({
      by: ['authorMembershipId', 'targetMembershipId'],
      where: {
        gameSessionId,
        deletedAt: null,
        targetMembershipId: { not: null },
        OR: [
          { authorMembershipId: callerMembershipId },
          { targetMembershipId: callerMembershipId },
        ],
      },
      _max: { createdAt: true },
    });

    if (groups.length === 0) return [];

    // Step 2: Derive distinct partner membership IDs (the side that isn't the caller)
    const partnerIdMap = new Map<string, Date | null>(); // partnerMembershipId → latest message time
    for (const g of groups) {
      const authorId = g.authorMembershipId;
      const targetId = g.targetMembershipId;
      if (!authorId || !targetId) continue; // guard — groupBy filter ensures non-null targetId

      const partnerId = authorId === callerMembershipId ? targetId : authorId;
      const existing = partnerIdMap.get(partnerId) ?? null;
      const maxAt = g._max.createdAt;
      if (!existing || (maxAt && maxAt > existing)) {
        partnerIdMap.set(partnerId, maxAt);
      }
    }

    if (partnerIdMap.size === 0) return [];

    const partnerIds = [...partnerIdMap.keys()];

    // Step 3: Load partner membership info (userId + characterId + character name)
    const partnerMemberships = await this.prisma.gameSessionMembership.findMany({
      where: { id: { in: partnerIds } },
      select: {
        id: true,
        userId: true,
        characterId: true,
        character: { select: { name: true } },
      },
    });

    // Step 4: Fetch display names for partner userIds
    const partnerUserIds = [...new Set(partnerMemberships.map((m) => m.userId))];
    const displayNameMap = await this.fetchDisplayNames(partnerUserIds);

    // Step 5: Build read models
    const result: ConversationSummaryReadModel[] = [];
    for (const membership of partnerMemberships) {
      const lastMessageAt = partnerIdMap.get(membership.id) ?? null;
      result.push(
        toConversationSummary({
          conversationKey: membership.id,
          kind: 'whisper',
          partnerMembershipId: membership.id,
          partnerDisplayName: displayNameMap.get(membership.userId) ?? null,
          partnerCharacterName: membership.character?.name ?? null,
          lastMessageAt,
          // unreadCount is recomputed by the query handler using read-cursor state
          unreadCount: 0,
        }),
      );
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // countNewerThan  (used by ListConversationsHandler for unread counts + lastMessageAt)
  // ---------------------------------------------------------------------------

  async countNewerThan(args: {
    gameSessionId: string;
    conversation: import('../domain/chat.ports').ConversationKey;
    callerMembershipId: string;
    after: Date | null;
  }): Promise<{ count: number; lastMessageAt: Date | null }> {
    const { gameSessionId, conversation, callerMembershipId, after } = args;

    // Build the same base where clause as list()
    let baseWhere: Prisma.ChatMessageWhereInput;
    if (conversation === 'broadcast') {
      baseWhere = { gameSessionId, targetMembershipId: null, deletedAt: null };
    } else {
      const partnerMembershipId = conversation;
      baseWhere = {
        gameSessionId,
        deletedAt: null,
        OR: [
          { authorMembershipId: callerMembershipId, targetMembershipId: partnerMembershipId },
          { authorMembershipId: partnerMembershipId, targetMembershipId: callerMembershipId },
        ],
      };
    }

    const where: Prisma.ChatMessageWhereInput =
      after !== null ? { ...baseWhere, createdAt: { gt: after } } : baseWhere;

    // Run count and max in parallel
    const [count, agg] = await Promise.all([
      this.prisma.chatMessage.count({ where }),
      this.prisma.chatMessage.aggregate({
        where: after !== null ? (baseWhere as Prisma.ChatMessageWhereInput) : baseWhere,
        _max: { createdAt: true },
      }),
    ]);

    return { count, lastMessageAt: agg._max.createdAt };
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /**
   * Two-step join: membershipIds → userIds → displayNames.
   * Returns Map<authorMembershipId, displayName | null>.
   */
  private async fetchDisplayNamesByMembershipIds(
    membershipIds: string[],
  ): Promise<Map<string, string | null>> {
    if (membershipIds.length === 0) return new Map();

    const memberships = await this.prisma.gameSessionMembership.findMany({
      where: { id: { in: [...new Set(membershipIds)] } },
      select: { id: true, userId: true },
    });

    const userIds = [...new Set(memberships.map((m) => m.userId))];
    const userDisplayNames = await this.fetchDisplayNames(userIds);

    const result = new Map<string, string | null>();
    for (const m of memberships) {
      result.set(m.id, userDisplayNames.get(m.userId) ?? null);
    }
    return result;
  }

  /**
   * Fetches displayName for a set of userIds. Returns Map<userId, displayName | null>.
   * Mirrors MembershipRepo.fetchDisplayNames — uses User.displayName (nullable).
   */
  private async fetchDisplayNames(userIds: string[]): Promise<Map<string, string | null>> {
    if (userIds.length === 0) return new Map();
    const users = await this.prisma.user.findMany({
      where: { id: { in: [...new Set(userIds)] } },
      select: { id: true, displayName: true },
    });
    return new Map(users.map((u) => [u.id, u.displayName ?? null]));
  }
}
