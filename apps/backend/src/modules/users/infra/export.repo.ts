/**
 * WHY this file exists:
 * Infrastructure adapter — the Prisma-backed implementation of
 * IExportRepo. The only place in the users bounded context that
 * cross-reads Characters / Ships / Npcs / GameSessions. Every model
 * uses `ownerId` as the user FK (verified against
 * prisma/schema.prisma at design time). NPCs are user-owned and load
 * as a separate top-level read because they are not session-scoped at
 * the DB level.
 *
 * Reads execute in parallel via Promise.all — bundle assembly does not
 * depend on read ordering, and for v1 user scale (under 1 MB
 * bundles) the latency win is real. Revisit only if real-user
 * bundles cause connection-pool pressure.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type { IExportRepo, MeExportBundle, MeExportUserDto } from '../domain/user.ports';

@Injectable()
export class ExportRepo implements IExportRepo {
  constructor(private readonly prisma: PrismaService) {}

  async loadBundleFor(userId: string): Promise<MeExportBundle> {
    const [user, characters, ships, npcs, gameSessions] = await Promise.all([
      this.prisma.user.findUniqueOrThrow({
        where: { id: userId },
        select: { id: true, displayName: true, locale: true },
      }),
      this.prisma.character.findMany({
        where: { ownerId: userId },
        include: { items: true, talents: true },
      }),
      this.prisma.ship.findMany({
        where: { ownerId: userId },
        include: { modules: true, crew: true },
      }),
      this.prisma.npc.findMany({
        where: { ownerId: userId },
      }),
      this.prisma.gameSession.findMany({
        where: { ownerId: userId },
        include: { encounters: { include: { combatants: true } } },
      }),
    ]);

    const userDto: MeExportUserDto = {
      id: user.id,
      displayName: user.displayName,
      locale: user.locale,
    };

    return {
      $schemaVersion: '1',
      exportedAt: new Date().toISOString(),
      user: userDto,
      characters,
      ships,
      npcs,
      gameSessions,
    };
  }
}
