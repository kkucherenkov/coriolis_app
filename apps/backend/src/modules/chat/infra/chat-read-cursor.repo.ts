/**
 * WHY this file exists:
 * Infrastructure adapter for ChatReadCursor — tracks the last-read position
 * per (membership, conversation) pair. Implements IChatReadCursorRepo.
 *
 * upsert uses the composite unique key (membershipId, conversationKey).
 * getMap returns a Map so the query handler can look up cursors in O(1).
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type { ConversationKey, IChatReadCursorRepo } from '../domain/chat.ports';

@Injectable()
export class ChatReadCursorRepo implements IChatReadCursorRepo {
  constructor(private readonly prisma: PrismaService) {}

  async upsert(args: {
    membershipId: string;
    conversationKey: ConversationKey;
    lastReadAt: Date;
  }): Promise<void> {
    await this.prisma.chatReadCursor.upsert({
      where: {
        membershipId_conversationKey: {
          membershipId: args.membershipId,
          conversationKey: args.conversationKey,
        },
      },
      create: {
        membershipId: args.membershipId,
        conversationKey: args.conversationKey,
        lastReadAt: args.lastReadAt,
      },
      update: {
        lastReadAt: args.lastReadAt,
      },
    });
  }

  async getMap(args: {
    membershipId: string;
    keys: ConversationKey[];
  }): Promise<Map<ConversationKey, Date>> {
    if (args.keys.length === 0) return new Map();

    const rows = await this.prisma.chatReadCursor.findMany({
      where: {
        membershipId: args.membershipId,
        conversationKey: { in: args.keys },
      },
    });

    return new Map(rows.map((r) => [r.conversationKey, r.lastReadAt]));
  }
}
