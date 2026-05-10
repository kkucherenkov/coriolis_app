/**
 * WHY this file exists:
 * Prisma-backed implementation of IGameSessionAccess.
 * Checks whether a caller is owner or member of a game session without
 * duplicating the SQL from game-sessions/infra/game-session.repo.ts.
 *
 * member = ownerId OR has a character assigned via CharacterGameSession join table.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type { IGameSessionAccess } from '../domain/game-session-access.ports';

@Injectable()
export class GameSessionAccessService implements IGameSessionAccess {
  constructor(private readonly prisma: PrismaService) {}

  async isOwner(sessionId: string, userId: string): Promise<boolean> {
    const session = await this.prisma.gameSession.findFirst({
      where: { id: sessionId },
      select: { ownerId: true },
    });
    return session?.ownerId === userId;
  }

  async isMember(sessionId: string, userId: string): Promise<boolean> {
    // Owner always counts as a member.
    const session = await this.prisma.gameSession.findFirst({
      where: { id: sessionId },
      select: {
        ownerId: true,
        characters: {
          where: {
            character: { ownerId: userId },
          },
          select: { characterId: true },
          take: 1,
        },
      },
    });
    if (!session) return false;
    if (session.ownerId === userId) return true;
    return session.characters.length > 0;
  }

  async getOwnerId(sessionId: string): Promise<string | null> {
    const session = await this.prisma.gameSession.findFirst({
      where: { id: sessionId },
      select: { ownerId: true },
    });
    return session?.ownerId ?? null;
  }
}
