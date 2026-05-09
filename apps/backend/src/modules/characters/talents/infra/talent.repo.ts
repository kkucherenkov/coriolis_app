import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../../common/prisma/prisma.service';

import type { TalentKind, TalentReadModel } from '../../domain/character.ports';
import type { ITalentRepo } from '../domain/talent.ports';

const TALENT_SELECT = {
  id: true,
  kind: true,
  name: true,
  description: true,
  rank: true,
  acquiredAt: true,
  characterId: true,
} as const;

interface TalentRow {
  id: string;
  kind: TalentKind;
  name: string;
  description: string;
  rank: number;
  acquiredAt: Date;
  characterId: string;
}

function toReadModel(row: TalentRow): TalentReadModel & { characterId: string } {
  return {
    id: row.id,
    kind: row.kind,
    name: row.name,
    description: row.description,
    rank: row.rank,
    acquiredAt: row.acquiredAt.toISOString(),
    characterId: row.characterId,
  };
}

@Injectable()
export class TalentRepo implements ITalentRepo {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string): Promise<(TalentReadModel & { characterId: string }) | null> {
    const row = await this.prisma.talent.findFirst({
      where: { id },
      select: TALENT_SELECT,
    });
    if (!row) return null;
    return toReadModel(row);
  }

  async listByCharacterId(characterId: string): Promise<TalentReadModel[]> {
    const rows = await this.prisma.talent.findMany({
      where: { characterId },
      select: TALENT_SELECT,
      orderBy: { acquiredAt: 'asc' },
    });
    return rows.map((row) => {
      const { characterId: _ignored, ...rest } = toReadModel(row);
      void _ignored;
      return rest;
    });
  }

  async create(data: {
    characterId: string;
    kind: TalentKind;
    name: string;
    description: string;
    rank: number;
  }): Promise<TalentReadModel & { characterId: string }> {
    const row = await this.prisma.talent.create({
      data,
      select: TALENT_SELECT,
    });
    return toReadModel(row);
  }

  async update(
    id: string,
    data: Partial<{ name: string; description: string; rank: number }>,
  ): Promise<TalentReadModel & { characterId: string }> {
    const row = await this.prisma.talent.update({
      where: { id },
      data,
      select: TALENT_SELECT,
    });
    return toReadModel(row);
  }

  async delete(id: string): Promise<void> {
    await this.prisma.talent.delete({ where: { id } });
  }
}
