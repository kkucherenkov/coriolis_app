/**
 * WHY this file exists:
 * Infrastructure adapter — the only file in the memberships bounded
 * context that imports PrismaService. Implements IMembershipRepo and
 * IGameSessionInviteRepo against the game_session and
 * game_session_membership tables.
 *
 * Display names and character names are joined off the User and Character
 * tables; the read-model fields are nullable to tolerate deleted users
 * or unlinked characters.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';
import {
  GameSessionNotFoundError,
  GameSessionNotOwnerError,
} from '../../game-sessions/domain/game-session.errors';

import { toMembershipReadModel } from '../domain/membership.mapper';

import type {
  IGameSessionInviteRepo,
  IMembershipRepo,
  InviteMetadataReadModel,
  MembershipReadModel,
} from '../domain/membership.ports';

const MEMBERSHIP_SELECT = {
  id: true,
  gameSessionId: true,
  userId: true,
  role: true,
  characterId: true,
  joinedAt: true,
  leftAt: true,
  character: { select: { name: true } },
} as const;

@Injectable()
export class MembershipRepo implements IMembershipRepo, IGameSessionInviteRepo {
  constructor(private readonly prisma: PrismaService) {}

  async listActive(gameSessionId: string): Promise<MembershipReadModel[]> {
    const rows = await this.prisma.gameSessionMembership.findMany({
      where: { gameSessionId, leftAt: null },
      orderBy: { joinedAt: 'asc' },
      select: MEMBERSHIP_SELECT,
    });
    const users = await this.fetchDisplayNames(rows.map((r) => r.userId));
    return rows.map((r) => toMembershipReadModel(r, users.get(r.userId) ?? null));
  }

  async findById(id: string): Promise<MembershipReadModel | null> {
    const row = await this.prisma.gameSessionMembership.findUnique({
      where: { id },
      select: MEMBERSHIP_SELECT,
    });
    if (!row) return null;
    const users = await this.fetchDisplayNames([row.userId]);
    return toMembershipReadModel(row, users.get(row.userId) ?? null);
  }

  async findActiveByUser(
    gameSessionId: string,
    userId: string,
  ): Promise<MembershipReadModel | null> {
    const row = await this.prisma.gameSessionMembership.findFirst({
      where: { gameSessionId, userId, leftAt: null },
      select: MEMBERSHIP_SELECT,
    });
    if (!row) return null;
    const users = await this.fetchDisplayNames([userId]);
    return toMembershipReadModel(row, users.get(userId) ?? null);
  }

  async softDelete(id: string): Promise<void> {
    await this.prisma.gameSessionMembership.updateMany({
      where: { id, leftAt: null },
      data: { leftAt: new Date() },
    });
  }

  async setCharacter(id: string, characterId: string | null): Promise<MembershipReadModel> {
    const row = await this.prisma.gameSessionMembership.update({
      where: { id },
      data: { characterId },
      select: MEMBERSHIP_SELECT,
    });
    const users = await this.fetchDisplayNames([row.userId]);
    return toMembershipReadModel(row, users.get(row.userId) ?? null);
  }

  async assertOwner(gameSessionId: string, userId: string): Promise<void> {
    const session = await this.prisma.gameSession.findUnique({
      where: { id: gameSessionId },
      select: { ownerId: true },
    });
    if (!session) throw new GameSessionNotFoundError(gameSessionId);
    if (session.ownerId !== userId) throw new GameSessionNotOwnerError(gameSessionId);
  }

  async getMetadata(gameSessionId: string): Promise<InviteMetadataReadModel> {
    const row = await this.prisma.gameSession.findUnique({
      where: { id: gameSessionId },
      select: { inviteTokenHash: true, inviteRotatedAt: true },
    });
    if (!row) throw new GameSessionNotFoundError(gameSessionId);
    return {
      active: row.inviteTokenHash !== null,
      rotatedAt: row.inviteRotatedAt?.toISOString() ?? null,
    };
  }

  async rotate(
    gameSessionId: string,
    tokenHash: string,
    createdByUserId: string,
  ): Promise<{ rotatedAt: string }> {
    const now = new Date();
    await this.prisma.gameSession.update({
      where: { id: gameSessionId },
      data: {
        inviteTokenHash: tokenHash,
        inviteRotatedAt: now,
        inviteCreatedById: createdByUserId,
      },
    });
    return { rotatedAt: now.toISOString() };
  }

  async revoke(gameSessionId: string): Promise<void> {
    await this.prisma.gameSession.update({
      where: { id: gameSessionId },
      data: {
        inviteTokenHash: null,
        inviteRotatedAt: null,
        inviteCreatedById: null,
      },
    });
  }

  private async fetchDisplayNames(userIds: string[]): Promise<Map<string, string | null>> {
    if (userIds.length === 0) return new Map();
    const users = await this.prisma.user.findMany({
      where: { id: { in: Array.from(new Set(userIds)) } },
      select: { id: true, name: true },
    });
    return new Map(users.map((u) => [u.id, u.name ?? null]));
  }
}
