/**
 * Unit tests for DeleteMeHandler (T-4.2.1.b / T-4.2.1.e).
 * All ports and services are vi.fn() mocks — no NestJS, no Prisma, no BA.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { UserDeletedEvent } from '../events/user-deleted.event';

import { DeleteMeCommand } from './delete-me.command';
import { DeleteMeHandler } from './delete-me.handler';

import type { IUserRepo } from '../domain/user.ports';

// ─── helpers ────────────────────────────────────────────────────────────────

function makeRepo(): IUserRepo {
  return {
    findActiveById: vi.fn(),
    updateDisplayName: vi.fn(),
    updateProfile: vi.fn(),
    softDelete: vi.fn(),
  };
}

function makeAuth() {
  return { revokeAllSessions: vi.fn().mockResolvedValue(undefined) };
}

function makeEventBus() {
  return { publish: vi.fn() };
}

// ─── tests ──────────────────────────────────────────────────────────────────

describe('DeleteMeHandler', () => {
  let repo: ReturnType<typeof makeRepo>;
  let auth: ReturnType<typeof makeAuth>;
  let eventBus: ReturnType<typeof makeEventBus>;
  let handler: DeleteMeHandler;

  const FIXED_DATE = new Date('2026-05-08T03:00:00.000Z');

  beforeEach(() => {
    repo = makeRepo();
    auth = makeAuth();
    eventBus = makeEventBus();
    // Inject mocks — handler constructor accepts the interfaces directly.
    handler = new DeleteMeHandler(
      repo,
      auth as unknown as import('../../../common/auth/auth.service').AuthService,
      eventBus as unknown as import('@nestjs/cqrs').EventBus,
    );
    vi.useFakeTimers();
    vi.setSystemTime(FIXED_DATE);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  // ── happy path ──────────────────────────────────────────────────────────

  it('stamps deletedAt on the user row', async () => {
    vi.mocked(repo.softDelete).mockResolvedValue(FIXED_DATE);

    await handler.execute(new DeleteMeCommand('user-1'));

    expect(repo.softDelete).toHaveBeenCalledWith('user-1', FIXED_DATE);
  });

  it('revokes all sessions after a successful soft-delete', async () => {
    vi.mocked(repo.softDelete).mockResolvedValue(FIXED_DATE);

    await handler.execute(new DeleteMeCommand('user-1'));

    expect(auth.revokeAllSessions).toHaveBeenCalledWith('user-1');
  });

  it('publishes UserDeletedEvent with userId and deletedAt', async () => {
    vi.mocked(repo.softDelete).mockResolvedValue(FIXED_DATE);

    await handler.execute(new DeleteMeCommand('user-1'));

    expect(eventBus.publish).toHaveBeenCalledWith(
      expect.objectContaining({
        userId: 'user-1',
        deletedAt: FIXED_DATE,
      }),
    );
    const firstCall = vi.mocked(eventBus.publish).mock.calls[0];
    expect(firstCall).toBeDefined();
    expect(firstCall![0]).toBeInstanceOf(UserDeletedEvent);
  });

  it('resolves without error (returns void) on happy path', async () => {
    vi.mocked(repo.softDelete).mockResolvedValue(FIXED_DATE);

    await expect(handler.execute(new DeleteMeCommand('user-1'))).resolves.toBeUndefined();
  });

  // ── idempotent paths ────────────────────────────────────────────────────

  it('is idempotent when user is already soft-deleted (repo returns null)', async () => {
    vi.mocked(repo.softDelete).mockResolvedValue(null);

    await expect(handler.execute(new DeleteMeCommand('user-1'))).resolves.toBeUndefined();
  });

  it('does NOT call revokeAllSessions when user was already deleted', async () => {
    vi.mocked(repo.softDelete).mockResolvedValue(null);

    await handler.execute(new DeleteMeCommand('user-1'));

    expect(auth.revokeAllSessions).not.toHaveBeenCalled();
  });

  it('does NOT publish UserDeletedEvent when user was already deleted', async () => {
    vi.mocked(repo.softDelete).mockResolvedValue(null);

    await handler.execute(new DeleteMeCommand('user-1'));

    expect(eventBus.publish).not.toHaveBeenCalled();
  });

  it('is idempotent when user row does not exist (repo returns null)', async () => {
    // Same path as already-deleted — softDelete with deletedAt filter returns null
    vi.mocked(repo.softDelete).mockResolvedValue(null);

    await expect(handler.execute(new DeleteMeCommand('ghost-user'))).resolves.toBeUndefined();
    expect(auth.revokeAllSessions).not.toHaveBeenCalled();
    expect(eventBus.publish).not.toHaveBeenCalled();
  });

  // ── deletedAt timestamp precision ───────────────────────────────────────

  it('passes the exact new Date() timestamp to softDelete', async () => {
    vi.mocked(repo.softDelete).mockResolvedValue(FIXED_DATE);

    await handler.execute(new DeleteMeCommand('user-1'));

    const callArgs = vi.mocked(repo.softDelete).mock.calls[0];
    expect(callArgs).toBeDefined();
    expect(callArgs![1]).toEqual(FIXED_DATE);
  });

  it('embeds the stamped timestamp (from repo) in UserDeletedEvent, not a re-computed one', async () => {
    // Simulate repo returning a slightly different object (same value, different reference)
    const repoTimestamp = new Date(FIXED_DATE);
    vi.mocked(repo.softDelete).mockResolvedValue(repoTimestamp);

    await handler.execute(new DeleteMeCommand('user-1'));

    const publishCall = vi.mocked(eventBus.publish).mock.calls[0];
    expect(publishCall).toBeDefined();
    const event = publishCall![0] as UserDeletedEvent;
    expect(event.deletedAt).toBe(repoTimestamp); // exact same reference from repo
  });
});
