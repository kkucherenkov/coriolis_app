/**
 * WHY this file exists:
 * After the 30-day grace window, users who requested account deletion must be
 * hard-deleted along with all child records. Prisma FK cascades (Character →
 * Item / Talent / Relationship / CriticalInjury, Session → User, etc.) handle
 * the child cleanup in a single database round-trip.
 *
 * The cron runs at 03:00 UTC daily to minimise overlap with peak traffic.
 * The 30-day window is anchored to the exact `deletedAt` timestamp (not a
 * calendar day boundary) per the spec-writer's recommendation in done.md.
 *
 * TODO (Epic 7+): Before deletion, publish Centrifugo channel cleanup events
 * so subscribers are gracefully disconnected.
 * TODO (Epic 7+): Invalidate share-slug cache entries keyed to expired users.
 */
import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';

import { PrismaService } from '../../../common/prisma/prisma.service';

const THIRTY_DAYS_MS = 30 * 24 * 60 * 60 * 1000;

@Injectable()
export class CascadeDeletedUsersJob {
  private readonly logger = new Logger(CascadeDeletedUsersJob.name);

  constructor(private readonly prisma: PrismaService) {}

  @Cron(CronExpression.EVERY_DAY_AT_3AM)
  async cascade(): Promise<void> {
    const cutoff = new Date(Date.now() - THIRTY_DAYS_MS);

    const result = await this.prisma.user.deleteMany({
      where: { deletedAt: { lt: cutoff } },
    });

    this.logger.log(`Cascade-deleted ${String(result.count)} expired users (cutoff=${cutoff.toISOString()}).`);

    // TODO: Centrifugo channel cleanup + share-slug cache invalidation hooks
    // when those systems land (Epic 7+).
  }
}
