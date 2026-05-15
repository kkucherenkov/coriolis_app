/**
 * WHY this file exists:
 * Bridge between the memberships bounded context and the characters table.
 * Implements ICharacterOwnership with a single SELECT against
 * character.ownerId. Keeps LinkCharacterHandler free of Prisma.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type { ICharacterOwnership } from '../commands/link-character.handler';

@Injectable()
export class CharacterOwnershipAdapter implements ICharacterOwnership {
  constructor(private readonly prisma: PrismaService) {}

  async isOwnedBy(characterId: string, userId: string): Promise<boolean> {
    const row = await this.prisma.character.findUnique({
      where: { id: characterId },
      select: { ownerId: true },
    });
    return row !== null && row.ownerId === userId;
  }
}
