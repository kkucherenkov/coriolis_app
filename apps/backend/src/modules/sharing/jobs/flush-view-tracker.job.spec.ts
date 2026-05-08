import { describe, it, expect, vi, beforeEach } from 'vitest';

import { ViewTracker } from '../infra/view-tracker';
import { FlushViewTrackerJob } from './flush-view-tracker.job';

import type { IShareLinkRepo } from '../domain/share-link.ports';

function makeJob(): { job: FlushViewTrackerJob; tracker: ViewTracker; repo: IShareLinkRepo } {
  const tracker = new ViewTracker();

  const repo = {
    create: vi.fn(),
    findBySlug: vi.fn(),
    findById: vi.fn(),
    findOwnerIdByShareLinkId: vi.fn(),
    listByCharacterId: vi.fn(),
    revoke: vi.fn(),
    findCharacterBySlug: vi.fn(),
    flushViewCounts: vi.fn().mockResolvedValue(undefined),
  } as unknown as IShareLinkRepo;

  const job = new FlushViewTrackerJob(tracker, repo);
  return { job, tracker, repo };
}

describe('FlushViewTrackerJob', () => {
  let job: FlushViewTrackerJob;
  let tracker: ViewTracker;
  let repo: IShareLinkRepo;

  beforeEach(() => {
    ({ job, tracker, repo } = makeJob());
  });

  it('does nothing when the buffer is empty', async () => {
    await job.flush();
    expect(repo.flushViewCounts).not.toHaveBeenCalled();
  });

  it('flushes accumulated views to the repo', async () => {
    tracker.recordView('slug_aaa');
    tracker.recordView('slug_aaa');
    tracker.recordView('slug_bbb');

    await job.flush();

    expect(repo.flushViewCounts).toHaveBeenCalledOnce();
    const entries = vi.mocked(repo.flushViewCounts).mock.calls[0]?.[0];
    const aEntry = entries?.find((e) => e.slug === 'slug_aaa');
    const bEntry = entries?.find((e) => e.slug === 'slug_bbb');
    expect(aEntry?.count).toBe(2);
    expect(bEntry?.count).toBe(1);
  });

  it('drains the buffer after a successful flush', async () => {
    tracker.recordView('slug_aaa');
    await job.flush();

    expect(tracker.pendingSize).toBe(0);
  });

  it('swallows repo errors and does not rethrow', async () => {
    tracker.recordView('slug_aaa');
    vi.mocked(repo.flushViewCounts).mockRejectedValue(new Error('DB error'));

    await expect(job.flush()).resolves.toBeUndefined();
  });
});
