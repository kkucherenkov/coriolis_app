import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../../common/prisma/prisma.service';

import type { ItemReadModel, ItemType } from '../../domain/character.ports';
import type { IItemRepo } from '../domain/item.ports';

@Injectable()
export class ItemRepo implements IItemRepo {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string): Promise<(ItemReadModel & { characterId: string }) | null> {
    const row = await this.prisma.item.findFirst({
      where: { id },
      select: { id: true, type: true, data: true, characterId: true },
    });
    if (!row) return null;
    const data = row.data as Record<string, unknown>;
    return { id: row.id, type: row.type as ItemType, characterId: row.characterId, ...data };
  }

  async findOwnerCharacterId(itemId: string): Promise<{ characterId: string } | null> {
    const row = await this.prisma.item.findFirst({
      where: { id: itemId },
      select: { characterId: true },
    });
    return row ?? null;
  }

  async create(data: {
    characterId: string;
    type: ItemType;
    payload: Record<string, unknown>;
  }): Promise<ItemReadModel & { characterId: string }> {
    const payload = data.payload as unknown as import('@prisma/client').Prisma.InputJsonValue;
    const row = await this.prisma.item.create({
      data: {
        characterId: data.characterId,
        type: data.type,
        data: payload,
      },
      select: { id: true, type: true, data: true, characterId: true },
    });
    const rowData = row.data as Record<string, unknown>;
    return { id: row.id, type: row.type as ItemType, characterId: row.characterId, ...rowData };
  }

  async update(
    id: string,
    payload: Record<string, unknown>,
  ): Promise<ItemReadModel & { characterId: string }> {
    // Merge payload into existing data JSON
    const existing = await this.prisma.item.findFirstOrThrow({
      where: { id },
      select: { data: true, type: true, characterId: true },
    });
    const merged = {
      ...(existing.data as Record<string, unknown>),
      ...payload,
    } as unknown as import('@prisma/client').Prisma.InputJsonValue;

    const row = await this.prisma.item.update({
      where: { id },
      data: { data: merged },
      select: { id: true, type: true, data: true, characterId: true },
    });
    const rowData = row.data as Record<string, unknown>;
    return { id: row.id, type: row.type as ItemType, characterId: row.characterId, ...rowData };
  }

  async delete(id: string): Promise<void> {
    await this.prisma.item.delete({ where: { id } });
  }
}
