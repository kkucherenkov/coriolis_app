/**
 * WHY this file exists:
 * Prisma adapter for ISessionOwnershipRepo. Used exclusively by
 * RealtimeService to determine which Centrifugo session channels a user
 * may subscribe to.
 *
 * PrismaService is @Global() so no additional module import is needed.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type { ISessionOwnershipRepo } from '../domain/session-ownership.port';

@Injectable()
export class SessionOwnershipRepo implements ISessionOwnershipRepo {
  constructor(private readonly prisma: PrismaService) {}

  async findOwnedSessionIds(userId: string): Promise<string[]> {
    const rows = await this.prisma.gameSession.findMany({
      where: { ownerId: userId },
      select: { id: true },
    });
    return rows.map((r) => r.id);
  }
}
