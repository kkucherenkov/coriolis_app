/**
 * WHY this file exists:
 * Infrastructure adapter — the Prisma-backed implementation of `IUserRepo`.
 * It is the only place in the users bounded context that knows about Prisma.
 * Registered by token in `users.module.ts`; never imported directly by handlers.
 *
 * SELECT shape is scoped to the use case: only the columns returned by `MeReadModel`.
 * Soft-delete filter (`deletedAt: null`) is applied on every read so the domain
 * never sees a logically-deleted user.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type { IUserRepo, MeReadModel } from '../domain/user.ports';

@Injectable()
export class UserRepo implements IUserRepo {
  constructor(private readonly prisma: PrismaService) {}

  async findActiveById(id: string): Promise<MeReadModel | null> {
    const row = await this.prisma.user.findFirst({
      where: { id, deletedAt: null },
      select: {
        id: true,
        email: true,
        displayName: true,
        createdAt: true,
      },
    });
    if (!row) return null;
    return this.toReadModel(row);
  }

  async updateDisplayName(id: string, displayName: string | null): Promise<MeReadModel> {
    const row = await this.prisma.user.update({
      where: { id },
      data: { displayName, updatedAt: new Date() },
      select: {
        id: true,
        email: true,
        displayName: true,
        createdAt: true,
      },
    });
    return this.toReadModel(row);
  }

  private toReadModel(row: {
    id: string;
    email: string;
    displayName: string | null;
    createdAt: Date;
  }): MeReadModel {
    return {
      id: row.id,
      email: row.email,
      displayName: row.displayName,
      createdAt: row.createdAt.toISOString(),
    };
  }
}
