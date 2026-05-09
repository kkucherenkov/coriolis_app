/**
 * WHY this file exists:
 * Abandoned character drafts — started by the wizard but never forged — must
 * be pruned to keep the database tidy. The 30-day window gives players ample
 * time to return and complete a wizard session before the draft is discarded.
 *
 * The cron fires at 03:05 UTC daily, offset by 5 minutes from
 * CascadeDeletedUsersJob (03:00) to avoid simultaneous heavy deletes.
 *
 * The job uses ICharacterRepo.deleteAbandonedDrafts so the infrastructure
 * adapter is the single place that touches Prisma — consistent with the
 * layering rules in AGENTS.md.
 *
 * ADR reference: docs/adr/0002-character-draft-state.md
 */
import { Inject, Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';

import { CHARACTER_REPO } from '../domain/character.ports';

import type { ICharacterRepo } from '../domain/character.ports';

const THIRTY_DAYS_MS = 30 * 24 * 60 * 60 * 1000;

// 03:05 UTC — offset from CascadeDeletedUsersJob (03:00) to stagger DB load.
const CRON_EXPRESSION = '5 03 * * *';

@Injectable()
export class CleanupAbandonedDraftsJob {
  private readonly logger = new Logger(CleanupAbandonedDraftsJob.name);

  constructor(@Inject(CHARACTER_REPO) private readonly repo: ICharacterRepo) {}

  @Cron(CRON_EXPRESSION)
  async cleanup(): Promise<void> {
    const cutoff = new Date(Date.now() - THIRTY_DAYS_MS);

    const count = await this.repo.deleteAbandonedDrafts(cutoff);

    this.logger.log(
      `Deleted ${String(count)} abandoned draft characters (updatedAt < ${cutoff.toISOString()}).`,
    );
  }
}
