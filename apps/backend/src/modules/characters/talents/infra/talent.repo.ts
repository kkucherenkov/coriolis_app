import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../../common/prisma/prisma.service';

import type { TalentReadModel } from '../../domain/character.ports';
import type { ITalentRepo } from '../domain/talent.ports';

@Injectable()
export class TalentRepo implements ITalentRepo {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string): Promise<(TalentReadModel & { characterId: string }) | null> {
    const row = await this.prisma.talent.findFirst({
      where: { id },
      select: {
        id: true,
        name: true,
        description: true,
        rank: true,
        acquiredAt: true,
        characterId: true,
      },
    });
    if (!row) return null;
    return {
      id: row.id,
      name: row.name,
      description: row.description,
      rank: row.rank,
      acquiredAt: row.acquiredAt.toISOString(),
      characterId: row.characterId,
    };
  }

  async create(data: {
    characterId: string;
    name: string;
    description: string;
    rank: number;
  }): Promise<TalentReadModel & { characterId: string }> {
    const row = await this.prisma.talent.create({
      data,
      select: {
        id: true,
        name: true,
        description: true,
        rank: true,
        acquiredAt: true,
        characterId: true,
      },
    });
    return {
      id: row.id,
      name: row.name,
      description: row.description,
      rank: row.rank,
      acquiredAt: row.acquiredAt.toISOString(),
      characterId: row.characterId,
    };
  }

  async update(
    id: string,
    data: Partial<{ name: string; description: string; rank: number }>,
  ): Promise<TalentReadModel & { characterId: string }> {
    const row = await this.prisma.talent.update({
      where: { id },
      data,
      select: {
        id: true,
        name: true,
        description: true,
        rank: true,
        acquiredAt: true,
        characterId: true,
      },
    });
    return {
      id: row.id,
      name: row.name,
      description: row.description,
      rank: row.rank,
      acquiredAt: row.acquiredAt.toISOString(),
      characterId: row.characterId,
    };
  }

  async delete(id: string): Promise<void> {
    await this.prisma.talent.delete({ where: { id } });
  }
}
