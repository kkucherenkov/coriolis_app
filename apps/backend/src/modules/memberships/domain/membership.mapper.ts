/**
 * WHY this file exists:
 * Shared mapper used by both MembershipRepo and GameSessionRepo so that
 * the Prisma-row → MembershipReadModel projection is never duplicated.
 * Lives in domain/ (not infra/) because it is a pure data transformation
 * with no I/O — safe to import from either layer.
 */

import type { MembershipReadModel, MembershipRole } from './membership.ports';

export interface PrismaMembershipRow {
  id: string;
  gameSessionId: string;
  userId: string;
  role: string;
  characterId: string | null;
  joinedAt: Date;
  leftAt: Date | null;
  character: { name: string } | null;
}

export function toMembershipReadModel(
  row: PrismaMembershipRow,
  displayName: string | null,
): MembershipReadModel {
  return {
    id: row.id,
    gameSessionId: row.gameSessionId,
    userId: row.userId,
    role: row.role as MembershipRole,
    displayName,
    characterId: row.characterId,
    characterName: row.character?.name ?? null,
    joinedAt: row.joinedAt.toISOString(),
    leftAt: row.leftAt?.toISOString() ?? null,
  };
}
