/**
 * WHY this file exists:
 * Applied on every parameterized character route (those with :id in the path).
 * Resolves the character ownerId from the DB and compares to req.userId.
 * Returns 404 (not found, no info leak) if the character does not exist,
 * 403 if it exists but is owned by someone else.
 *
 * SessionGuard must run before this guard so req.userId is populated.
 */
import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../../common/prisma/prisma.service';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';

@Injectable()
export class CharacterOwnershipGuard implements CanActivate {
  constructor(private readonly prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context
      .switchToHttp()
      .getRequest<AuthenticatedRequest & { params: { id?: string } }>();
    const characterId = req.params.id;

    if (!characterId) return true; // no :id param — guard is a no-op

    const row = await this.prisma.character.findFirst({
      where: { id: characterId },
      select: { ownerId: true },
    });

    if (!row) {
      throw new NotFoundException(`Character ${characterId} does not exist.`);
    }

    if (row.ownerId !== req.userId) {
      throw new ForbiddenException(`Character ${characterId} does not belong to the current user.`);
    }

    return true;
  }
}
