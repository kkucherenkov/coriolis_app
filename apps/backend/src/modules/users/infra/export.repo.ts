/**
 * WHY this file exists:
 * Infrastructure adapter for the User half of the export bundle. The
 * domain-resource data (characters / ships / npcs / game sessions) is
 * delegated to each context's list handler via the QueryBus — see
 * ExportMeHandler. This file only loads the minimal user envelope.
 *
 * Mirrors UserRepo.findActiveById: filters out soft-deleted rows.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type { IExportRepo, MeExportUserDto } from '../domain/user.ports';

@Injectable()
export class ExportRepo implements IExportRepo {
  constructor(private readonly prisma: PrismaService) {}

  async loadUserFor(userId: string): Promise<MeExportUserDto | null> {
    const user = await this.prisma.user.findFirst({
      where: { id: userId, deletedAt: null },
      select: { id: true, displayName: true },
    });
    return user ? { id: user.id, displayName: user.displayName } : null;
  }
}
