/**
 * WHY this file exists:
 * Infrastructure adapter — the Prisma-backed implementation of IGameSessionRepo.
 * This is the only file in the game-sessions bounded context that imports
 * PrismaService. Handlers inject IGameSessionRepo by the GAME_SESSION_REPO token.
 *
 * SELECT shapes are scoped to what the use case needs.
 * The characterIds array is assembled from the join table's characterId column.
 *
 * Character-ownership for the assign endpoint is checked in a single query
 * that looks up the character's ownerId and compares it to the session's ownerId.
 * If the character does not belong to the same user, CharacterNotOwnedError is
 * thrown at the repo layer so the handler stays free of DB concerns.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';
import { CharacterNotOwnedError } from '../domain/game-session.errors';
import { toMembershipReadModel } from '../../memberships/domain/membership.mapper';

import type {
  GameSessionReadModel,
  GameSessionStatus,
  IGameSessionRepo,
  ListGameSessionsOptions,
} from '../domain/game-session.ports';
import type { MembershipReadModel } from '../../memberships/domain/membership.ports';

// --------------- Select shape ---------------

const GAME_SESSION_SELECT = {
  id: true,
  ownerId: true,
  name: true,
  description: true,
  status: true,
  dpCount: true,
  shipId: true,
  characters: {
    select: { characterId: true },
    orderBy: { assignedAt: 'asc' as const },
  },
  memberships: {
    where: { leftAt: null },
    orderBy: { joinedAt: 'asc' as const },
    select: {
      id: true,
      gameSessionId: true,
      userId: true,
      role: true,
      characterId: true,
      joinedAt: true,
      leftAt: true,
      character: { select: { name: true } },
    },
  },
  createdAt: true,
  updatedAt: true,
} as const;

// --------------- Mapper ---------------

interface PrismaGameSessionMembershipRow {
  id: string;
  gameSessionId: string;
  userId: string;
  role: string;
  characterId: string | null;
  joinedAt: Date;
  leftAt: Date | null;
  character: { name: string } | null;
}

interface PrismaGameSession {
  id: string;
  ownerId: string;
  name: string;
  description: string | null;
  status: string;
  dpCount: number;
  shipId: string | null;
  characters: { characterId: string }[];
  memberships: PrismaGameSessionMembershipRow[];
  createdAt: Date;
  updatedAt: Date;
}

function toStatus(s: string): GameSessionStatus {
  return s.toLowerCase() as GameSessionStatus;
}

function buildReadModel(
  row: PrismaGameSession,
  memberships: MembershipReadModel[],
): GameSessionReadModel {
  return {
    id: row.id,
    ownerId: row.ownerId,
    name: row.name,
    description: row.description,
    status: toStatus(row.status),
    dpCount: row.dpCount,
    characterIds: row.characters.map((c) => c.characterId),
    memberships,
    shipId: row.shipId,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

// --------------- Repo ---------------

@Injectable()
export class GameSessionRepo implements IGameSessionRepo {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string): Promise<GameSessionReadModel | null> {
    const row = await this.prisma.gameSession.findFirst({
      where: { id },
      select: GAME_SESSION_SELECT,
    });
    if (!row) return null;
    return buildReadModel(row, await this.mapMemberships(row.memberships));
  }

  async list(
    opts: ListGameSessionsOptions,
  ): Promise<{ items: GameSessionReadModel[]; nextCursor: string | null }> {
    const { ownerId, limit, cursor, status } = opts;
    const take = limit + 1;

    const statusFilter = status ? (status.toUpperCase() as 'ACTIVE' | 'ARCHIVED') : undefined;

    const rows = await this.prisma.gameSession.findMany({
      where: {
        ownerId,
        ...(statusFilter ? { status: statusFilter } : {}),
      },
      select: GAME_SESSION_SELECT,
      orderBy: { createdAt: 'desc' },
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
      take,
    });

    const hasNext = rows.length > limit;
    const items = hasNext ? rows.slice(0, limit) : rows;

    // Collect all userIds across all sessions in one batch
    const allUserIds = items.flatMap((r) => r.memberships.map((m) => m.userId));
    const displayNames = await this.fetchDisplayNames(allUserIds);

    return {
      items: items.map((r) =>
        buildReadModel(
          r,
          r.memberships.map((m) => toMembershipReadModel(m, displayNames.get(m.userId) ?? null)),
        ),
      ),
      nextCursor: hasNext ? (items.at(-1)?.id ?? null) : null,
    };
  }

  async create(data: {
    ownerId: string;
    name: string;
    description?: string | null;
    shipId?: string | null;
  }): Promise<GameSessionReadModel> {
    const row = await this.prisma.gameSession.create({
      data: {
        ownerId: data.ownerId,
        name: data.name,
        description: data.description ?? null,
        shipId: data.shipId ?? null,
      },
      select: GAME_SESSION_SELECT,
    });
    return buildReadModel(row, await this.mapMemberships(row.memberships));
  }

  async update(
    id: string,
    data: Partial<{
      name: string;
      description: string | null;
      status: GameSessionStatus;
      shipId: string | null;
    }>,
  ): Promise<GameSessionReadModel> {
    const updatePayload: Record<string, unknown> = {};
    if (data.name !== undefined) updatePayload['name'] = data.name;
    if ('description' in data) updatePayload['description'] = data.description;
    if (data.status !== undefined) updatePayload['status'] = data.status.toUpperCase();
    if ('shipId' in data) updatePayload['shipId'] = data.shipId;

    const row = await this.prisma.gameSession.update({
      where: { id },
      data: updatePayload,
      select: GAME_SESSION_SELECT,
    });
    return buildReadModel(row, await this.mapMemberships(row.memberships));
  }

  async delete(id: string): Promise<void> {
    // Prisma cascades to character_game_session rows
    await this.prisma.gameSession.delete({ where: { id } });
  }

  async assignCharacter(gameSessionId: string, characterId: string): Promise<GameSessionReadModel> {
    // Verify the character exists and belongs to the same owner as the session.
    // Done in a single query to minimise round trips.
    const [session, character] = await Promise.all([
      this.prisma.gameSession.findFirst({
        where: { id: gameSessionId },
        select: { ownerId: true },
      }),
      this.prisma.character.findFirst({ where: { id: characterId }, select: { ownerId: true } }),
    ]);

    // Session existence was already checked in the handler; guard anyway.
    if (!session) {
      throw new Error(`GameSession ${gameSessionId} not found during assignCharacter.`);
    }

    if (character?.ownerId !== session.ownerId) {
      throw new CharacterNotOwnedError(characterId);
    }

    // Upsert is idempotent — no error if already assigned.
    await this.prisma.characterGameSession.upsert({
      where: {
        characterId_gameSessionId: { characterId, gameSessionId },
      },
      create: { characterId, gameSessionId },
      update: {}, // no-op on conflict
    });

    const row = await this.prisma.gameSession.findFirstOrThrow({
      where: { id: gameSessionId },
      select: GAME_SESSION_SELECT,
    });
    return buildReadModel(row, await this.mapMemberships(row.memberships));
  }

  async unassignCharacter(gameSessionId: string, characterId: string): Promise<void> {
    // deleteMany is silent when no rows match — idempotent
    await this.prisma.characterGameSession.deleteMany({
      where: { characterId, gameSessionId },
    });
  }

  private async mapMemberships(
    rows: PrismaGameSessionMembershipRow[],
  ): Promise<MembershipReadModel[]> {
    if (rows.length === 0) return [];
    const displayNames = await this.fetchDisplayNames(rows.map((r) => r.userId));
    return rows.map((r) => toMembershipReadModel(r, displayNames.get(r.userId) ?? null));
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
