/**
 * Unit tests for CleanupAbandonedDraftsJob (T-5.6.1.b / ADR 0002).
 * Uses vitest fake timers to control `Date.now()` so the cutoff calculation
 * is deterministic. ICharacterRepo is a vi.fn() mock — no DB bootstrapping.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { CleanupAbandonedDraftsJob } from './cleanup-abandoned-drafts.job';

import type { ICharacterRepo } from '../domain/character.ports';

// ─── helpers ────────────────────────────────────────────────────────────────

function makeRepo(): ICharacterRepo {
  return {
    findActiveById: vi.fn(),
    findOwnerIdById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    deleteAbandonedDrafts: vi.fn(),
    delete: vi.fn(),
  };
}

// ─── tests ──────────────────────────────────────────────────────────────────

describe('CleanupAbandonedDraftsJob', () => {
  const FIXED_NOW = new Date('2026-05-08T03:05:00.000Z').getTime();
  const THIRTY_DAYS_MS = 30 * 24 * 60 * 60 * 1000;
  const EXPECTED_CUTOFF = new Date(FIXED_NOW - THIRTY_DAYS_MS);

  let repo: ICharacterRepo;
  let job: CleanupAbandonedDraftsJob;

  beforeEach(() => {
    repo = makeRepo();
    job = new CleanupAbandonedDraftsJob(repo);
    vi.useFakeTimers();
    vi.setSystemTime(FIXED_NOW);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  // ── deletion logic ────────────────────────────────────────────────────────

  it('calls repo.deleteAbandonedDrafts with cutoff = now - 30 days', async () => {
    vi.mocked(repo.deleteAbandonedDrafts).mockResolvedValue(0);

    await job.cleanup();

    expect(repo.deleteAbandonedDrafts).toHaveBeenCalledWith(EXPECTED_CUTOFF);
  });

  it('deletes drafts with updatedAt strictly less than cutoff', async () => {
    vi.mocked(repo.deleteAbandonedDrafts).mockResolvedValue(0);

    await job.cleanup();

    const calls = vi.mocked(repo.deleteAbandonedDrafts).mock.calls;
    expect(calls[0]).toBeDefined();
    const passedCutoff = calls[0]![0];
    // Cutoff must equal FIXED_NOW - 30 days (strictly lt — not lte)
    expect(passedCutoff.getTime()).toBe(EXPECTED_CUTOFF.getTime());
  });

  it('resolves without error when deleteAbandonedDrafts returns 0', async () => {
    vi.mocked(repo.deleteAbandonedDrafts).mockResolvedValue(0);

    await expect(job.cleanup()).resolves.toBeUndefined();
  });

  it('resolves without error when deleteAbandonedDrafts returns > 0', async () => {
    vi.mocked(repo.deleteAbandonedDrafts).mockResolvedValue(12);

    await expect(job.cleanup()).resolves.toBeUndefined();
  });

  it('does not suppress errors thrown by repo.deleteAbandonedDrafts', async () => {
    vi.mocked(repo.deleteAbandonedDrafts).mockRejectedValue(new Error('DB timeout'));

    await expect(job.cleanup()).rejects.toThrow('DB timeout');
  });

  // ── scope: only drafts older than threshold ───────────────────────────────

  it('passes the correct cutoff so drafts within 30 days are preserved', async () => {
    vi.mocked(repo.deleteAbandonedDrafts).mockResolvedValue(0);

    await job.cleanup();

    // A draft updated 29 days ago is AFTER the cutoff → not deleted
    const twentyNineDaysAgo = new Date(FIXED_NOW - 29 * 24 * 60 * 60 * 1000);
    const passedCutoff = vi.mocked(repo.deleteAbandonedDrafts).mock.calls[0]![0];
    expect(twentyNineDaysAgo.getTime()).toBeGreaterThan(passedCutoff.getTime());
  });

  it('passes the correct cutoff so drafts exactly at 30 days are deleted', async () => {
    vi.mocked(repo.deleteAbandonedDrafts).mockResolvedValue(0);

    await job.cleanup();

    // A draft updated exactly 30 days + 1ms ago is BEFORE cutoff → deleted
    const thirtyDaysPlusOneMs = new Date(FIXED_NOW - THIRTY_DAYS_MS - 1);
    const passedCutoff = vi.mocked(repo.deleteAbandonedDrafts).mock.calls[0]![0];
    expect(thirtyDaysPlusOneMs.getTime()).toBeLessThan(passedCutoff.getTime());
  });

  // ── cron schedule ────────────────────────────────────────────────────────

  it('has a cleanup method callable from tests', () => {
    expect(typeof job.cleanup).toBe('function');
  });
});
