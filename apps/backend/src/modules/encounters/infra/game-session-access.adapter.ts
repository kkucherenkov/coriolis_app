/**
 * WHY this file exists:
 * Prisma-backed implementation of IGameSessionAccess.
 * Checks whether a caller is owner or member of a game session without
 * duplicating the SQL from game-sessions/infra/game-session.repo.ts.
 *
 * Since Phase 8 Stream E, `member` = active row in `GameSessionMembership`
 * for (sessionId, userId). The GM is always a member (backfilled on the
 * Stream A migration); the legacy `CharacterGameSession` join table is gone.
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
    const membership = await this.prisma.gameSessionMembership.findFirst({
      where: { gameSessionId: sessionId, userId, leftAt: null },
      select: { id: true },
    });
    return membership !== null;
  }

  async getOwnerId(sessionId: string): Promise<string | null> {
    const session = await this.prisma.gameSession.findFirst({
      where: { id: sessionId },
      select: { ownerId: true },
    });
    return session?.ownerId ?? null;
  }
}
