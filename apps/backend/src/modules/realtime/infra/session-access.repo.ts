/**
 * WHY this file exists:
 * Prisma adapter for ISessionAccessRepo. Replaces SessionOwnershipRepo
 * (Stream A) which only covered GM-owned sessions.
 *
 * Now covers all active memberships: a user with role='player' and
 * leftAt IS NULL gets the same session channel access as a GM.
 * Kicked members (leftAt IS NOT NULL) are excluded by the WHERE clause.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type { ISessionAccessRepo, UserMembership } from '../domain/session-ownership.port';

@Injectable()
export class SessionAccessRepo implements ISessionAccessRepo {
  constructor(private readonly prisma: PrismaService) {}

  async findActiveSessionIdsForUser(userId: string): Promise<string[]> {
    const rows = await this.prisma.gameSessionMembership.findMany({
      where: { userId, leftAt: null },
      select: { gameSessionId: true },
    });
    return rows.map((r) => r.gameSessionId);
  }

  async findActiveMembershipsForUser(userId: string): Promise<UserMembership[]> {
    const rows = await this.prisma.gameSessionMembership.findMany({
      where: { userId, leftAt: null },
      select: { id: true, gameSessionId: true },
    });
    return rows.map((r) => ({ gameSessionId: r.gameSessionId, membershipId: r.id }));
  }
}
