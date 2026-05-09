/**
 * WHY this file exists:
 * Infrastructure adapter — Prisma-backed implementation of IDpRepo.
 * This is the only file in the DP sub-context that imports PrismaService.
 *
 * applyDelta uses a Prisma $transaction to guarantee that the dpCount
 * increment and the DpEvent insert are committed atomically. If either
 * operation fails, both are rolled back.
 *
 * listEvents paginates DpEvent rows newest-first using cursor pagination on id.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../../common/prisma/prisma.service';

import type {
  DpEventReadModel,
  IDpRepo,
  ListDpEventsOptions,
  UpdateDpOptions,
} from '../domain/dp.ports';

// Source enum values match the Prisma DpSource enum exactly
const SOURCE_MAP = {
  GM_MANUAL: 'GM_MANUAL',
  ROLL_PUSH: 'ROLL_PUSH',
  SYSTEM: 'SYSTEM',
} as const;

function toSourceString(s: string): DpEventReadModel['source'] {
  return s as DpEventReadModel['source'];
}

function toEventReadModel(row: {
  id: string;
  gameSessionId: string;
  delta: number;
  reason: string | null;
  source: string;
  rollId: string | null;
  createdAt: Date;
}): DpEventReadModel {
  return {
    id: row.id,
    gameSessionId: row.gameSessionId,
    delta: row.delta,
    reason: row.reason,
    source: toSourceString(row.source),
    rollId: row.rollId,
    createdAt: row.createdAt.toISOString(),
  };
}

@Injectable()
export class DpRepo implements IDpRepo {
  constructor(private readonly prisma: PrismaService) {}

  async applyDelta(opts: UpdateDpOptions): Promise<number> {
    const { gameSessionId, delta, reason, source, rollId } = opts;

    const [updated] = await this.prisma.$transaction([
      this.prisma.gameSession.update({
        where: { id: gameSessionId },
        data: { dpCount: { increment: delta } },
        select: { dpCount: true },
      }),
      this.prisma.dpEvent.create({
        data: {
          gameSessionId,
          delta,
          reason: reason ?? null,
          source: SOURCE_MAP[source],
          rollId: rollId ?? null,
        },
        select: { id: true },
      }),
    ]);

    return updated.dpCount;
  }

  async listEvents(
    opts: ListDpEventsOptions,
  ): Promise<{ items: DpEventReadModel[]; nextCursor: string | null }> {
    const { gameSessionId, limit, cursor } = opts;
    const take = limit + 1;

    const rows = await this.prisma.dpEvent.findMany({
      where: { gameSessionId },
      select: {
        id: true,
        gameSessionId: true,
        delta: true,
        reason: true,
        source: true,
        rollId: true,
        createdAt: true,
      },
      orderBy: { createdAt: 'desc' },
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
      take,
    });

    const hasNext = rows.length > limit;
    const items = hasNext ? rows.slice(0, limit) : rows;

    return {
      items: items.map((r) => toEventReadModel(r)),
      nextCursor: hasNext ? (items.at(-1)?.id ?? null) : null,
    };
  }
}
