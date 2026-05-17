/**
 * WHY this file exists:
 * Infrastructure adapter for ChatBlock — per-session block list between members.
 * Implements IChatBlockRepo.
 *
 * insert is idempotent: Prisma P2002 (unique violation) is caught and swallowed.
 * delete is idempotent: Prisma P2025 (record not found) is caught and swallowed.
 *
 * listForBlocker resolves display names via the same two-step join used by
 * ChatMessageRepo: GameSessionMembership → User.displayName.
 */
import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type { ChatBlockSummaryReadModel, IChatBlockRepo } from '../domain/chat.ports';

@Injectable()
export class ChatBlockRepo implements IChatBlockRepo {
  constructor(private readonly prisma: PrismaService) {}

  async exists(args: {
    gameSessionId: string;
    blockerMembershipId: string;
    blockedMembershipId: string;
  }): Promise<boolean> {
    const count = await this.prisma.chatBlock.count({
      where: {
        gameSessionId: args.gameSessionId,
        blockerMembershipId: args.blockerMembershipId,
        blockedMembershipId: args.blockedMembershipId,
      },
    });
    return count > 0;
  }

  async insert(args: {
    gameSessionId: string;
    blockerMembershipId: string;
    blockedMembershipId: string;
  }): Promise<void> {
    try {
      await this.prisma.chatBlock.create({
        data: {
          gameSessionId: args.gameSessionId,
          blockerMembershipId: args.blockerMembershipId,
          blockedMembershipId: args.blockedMembershipId,
        },
      });
    } catch (error) {
      // P2002: unique constraint violation → block already exists; treat as no-op
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
        return;
      }
      throw error;
    }
  }

  async delete(args: {
    gameSessionId: string;
    blockerMembershipId: string;
    blockedMembershipId: string;
  }): Promise<void> {
    try {
      await this.prisma.chatBlock.delete({
        where: {
          gameSessionId_blockerMembershipId_blockedMembershipId: {
            gameSessionId: args.gameSessionId,
            blockerMembershipId: args.blockerMembershipId,
            blockedMembershipId: args.blockedMembershipId,
          },
        },
      });
    } catch (error) {
      // P2025: record not found → block did not exist; treat as no-op (idempotent unblock)
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2025') {
        return;
      }
      throw error;
    }
  }

  async listForBlocker(args: {
    gameSessionId: string;
    blockerMembershipId: string;
  }): Promise<ChatBlockSummaryReadModel[]> {
    const rows = await this.prisma.chatBlock.findMany({
      where: {
        gameSessionId: args.gameSessionId,
        blockerMembershipId: args.blockerMembershipId,
      },
      select: {
        blockedMembershipId: true,
        createdAt: true,
        blocked: { select: { id: true, userId: true } },
      },
      orderBy: { createdAt: 'asc' },
    });

    if (rows.length === 0) return [];

    // Resolve display names: blocked membership → userId → displayName
    const userIds = [...new Set(rows.map((r) => r.blocked.userId))];
    const users = await this.prisma.user.findMany({
      where: { id: { in: userIds } },
      select: { id: true, displayName: true },
    });
    const displayNames = new Map(users.map((u) => [u.id, u.displayName ?? null]));

    return rows.map((r) => ({
      targetMembershipId: r.blockedMembershipId,
      targetDisplayName: displayNames.get(r.blocked.userId) ?? null,
      createdAt: r.createdAt.toISOString(),
    }));
  }
}
