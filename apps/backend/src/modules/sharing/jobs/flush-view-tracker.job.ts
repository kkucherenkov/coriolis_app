/**
 * WHY this file exists:
 * Drains the ViewTracker's in-memory pending buffer once every minute and
 * persists the accumulated view counts to the database in a single batched
 * Prisma transaction (ADR 0003).
 *
 * The cron runs at `* * * * *` (every minute). This is a different cadence
 * than the 03:00/03:05 UTC daily jobs registered in UsersModule and
 * CharactersModule — NestJS Schedule handles all registrations independently.
 *
 * Logging channel: FlushViewTrackerJob — distinct from other job channels.
 */
import { Inject, Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';

import { ViewTracker } from '../infra/view-tracker';
import { SHARE_LINK_REPO } from '../domain/share-link.ports';

import type { IShareLinkRepo } from '../domain/share-link.ports';

@Injectable()
export class FlushViewTrackerJob {
  private readonly logger = new Logger(FlushViewTrackerJob.name);

  constructor(
    private readonly viewTracker: ViewTracker,
    @Inject(SHARE_LINK_REPO) private readonly repo: IShareLinkRepo,
  ) {}

  @Cron('* * * * *')
  async flush(): Promise<void> {
    const entries = this.viewTracker.drain();
    if (entries.length === 0) return;

    let totalViews = 0;
    for (const e of entries) totalViews += e.count;

    try {
      await this.repo.flushViewCounts(entries);
      this.logger.log(
        `Flushed view counts: ${String(entries.length)} slug(s), ${String(totalViews)} total view(s).`,
      );
    } catch (error) {
      // Log and swallow — view count loss on flush failure is acceptable per ADR 0003.
      this.logger.error('Failed to flush view counts', error);
    }
  }
}
