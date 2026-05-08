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

  /**
   * Idempotent soft-delete. Uses `updateMany` (not `update`) so that a
   * not-found or already-deleted row is silently skipped rather than throwing
   * a Prisma P2025 "record not found" error. The `deletedAt: null` filter
   * ensures we never overwrite an existing timestamp.
   */
  async softDelete(id: string, deletedAt: Date): Promise<Date | null> {
    const result = await this.prisma.user.updateMany({
      where: { id, deletedAt: null },
      data: { deletedAt, updatedAt: new Date() },
    });
    return result.count > 0 ? deletedAt : null;
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
