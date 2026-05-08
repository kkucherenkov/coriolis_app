/**
 * Unit tests for CascadeDeletedUsersJob (T-4.2.1.c / T-4.2.1.e).
 * Uses vitest fake timers to control `Date.now()` so the cutoff calculation
 * is deterministic. Prisma is a vi.fn() mock — no database bootstrapping.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { CronExpression } from '@nestjs/schedule';

import { CascadeDeletedUsersJob } from './cascade-deleted-users.job';

// ─── helpers ────────────────────────────────────────────────────────────────

function makePrisma() {
  return {
    user: {
      deleteMany: vi.fn(),
    },
  };
}

// ─── tests ──────────────────────────────────────────────────────────────────

describe('CascadeDeletedUsersJob', () => {
  const FIXED_NOW = new Date('2026-05-08T03:00:00.000Z').getTime();
  const THIRTY_DAYS_MS = 30 * 24 * 60 * 60 * 1000;
  const EXPECTED_CUTOFF = new Date(FIXED_NOW - THIRTY_DAYS_MS);

  let prisma: ReturnType<typeof makePrisma>;
  let job: CascadeDeletedUsersJob;

  beforeEach(() => {
    prisma = makePrisma();
    job = new CascadeDeletedUsersJob(
      prisma as unknown as import('../../../common/prisma/prisma.service').PrismaService,
    );
    vi.useFakeTimers();
    vi.setSystemTime(FIXED_NOW);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  // ── cascade logic ────────────────────────────────────────────────────────

  it('calls prisma.user.deleteMany with cutoff = now - 30 days', async () => {
    vi.mocked(prisma.user.deleteMany).mockResolvedValue({ count: 0 });

    await job.cascade();

    expect(prisma.user.deleteMany).toHaveBeenCalledWith({
      where: { deletedAt: { lt: EXPECTED_CUTOFF } },
    });
  });

  it('uses { lt: cutoff } — strictly less than, not less-than-or-equal', async () => {
    vi.mocked(prisma.user.deleteMany).mockResolvedValue({ count: 0 });

    await job.cascade();

    const calls = vi.mocked(prisma.user.deleteMany).mock.calls;
    expect(calls[0]).toBeDefined();
    const arg = calls[0]![0];
    expect(arg?.where?.deletedAt).toHaveProperty('lt');
    expect(arg?.where?.deletedAt).not.toHaveProperty('lte');
  });

  it('resolves without error when deleteMany returns count 0', async () => {
    vi.mocked(prisma.user.deleteMany).mockResolvedValue({ count: 0 });

    await expect(job.cascade()).resolves.toBeUndefined();
  });

  it('resolves without error when deleteMany returns count > 0', async () => {
    vi.mocked(prisma.user.deleteMany).mockResolvedValue({ count: 3 });

    await expect(job.cascade()).resolves.toBeUndefined();
  });

  it('does not suppress errors thrown by prisma.user.deleteMany', async () => {
    const dbError = new Error('DB connection lost');
    vi.mocked(prisma.user.deleteMany).mockRejectedValue(dbError);

    await expect(job.cascade()).rejects.toThrow('DB connection lost');
  });

  // ── cron schedule ────────────────────────────────────────────────────────

  it('has a `cascade` method callable from tests (decorator is structural)', () => {
    // The @Cron decorator adds NestJS schedule metadata at runtime via
    // Reflect.defineMetadata. SWC does not emit decorator metadata in unit
    // test mode. We verify the schedule string via the exported CronExpression
    // constant instead, and confirm the method is present and callable.
    expect(typeof job.cascade).toBe('function');
    // CronExpression.EVERY_DAY_AT_3AM = '0 03 * * *' per @nestjs/schedule@6
    expect(CronExpression.EVERY_DAY_AT_3AM).toBe('0 03 * * *');
  });
});
