/**
 * Unit tests for ChatBlockRepo.
 * Prisma is mocked via vi.fn() — no real DB.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { Prisma } from '@prisma/client';

import { ChatBlockRepo } from './chat-block.repo';

import type { PrismaService } from '../../../common/prisma/prisma.service';

function makePrismaMock() {
  return {
    chatBlock: {
      count: vi.fn(),
      create: vi.fn(),
      delete: vi.fn(),
      findMany: vi.fn(),
    },
    user: {
      findMany: vi.fn(),
    },
  } as unknown as PrismaService;
}

function makeP2002() {
  const err = new Prisma.PrismaClientKnownRequestError('Unique constraint violation', {
    code: 'P2002',
    clientVersion: '5.0.0',
  });
  return err;
}

function makeP2025() {
  const err = new Prisma.PrismaClientKnownRequestError('Record not found', {
    code: 'P2025',
    clientVersion: '5.0.0',
  });
  return err;
}

describe('ChatBlockRepo', () => {
  let prisma: ReturnType<typeof makePrismaMock>;
  let repo: ChatBlockRepo;

  beforeEach(() => {
    prisma = makePrismaMock();
    repo = new ChatBlockRepo(prisma);
  });

  // -------------------------------------------------------------------------
  // exists
  // -------------------------------------------------------------------------

  it('exists: returns true when count > 0', async () => {
    vi.mocked(prisma.chatBlock.count).mockResolvedValue(1);

    const result = await repo.exists({
      gameSessionId: 'gs-1',
      blockerMembershipId: 'mem-blocker',
      blockedMembershipId: 'mem-blocked',
    });

    expect(result).toBe(true);
  });

  it('exists: returns false when count === 0', async () => {
    vi.mocked(prisma.chatBlock.count).mockResolvedValue(0);

    const result = await repo.exists({
      gameSessionId: 'gs-1',
      blockerMembershipId: 'mem-blocker',
      blockedMembershipId: 'mem-blocked',
    });

    expect(result).toBe(false);
  });

  // -------------------------------------------------------------------------
  // insert — idempotent on P2002
  // -------------------------------------------------------------------------

  it('insert: resolves without error on P2002 unique violation (idempotent block)', async () => {
    vi.mocked(prisma.chatBlock.create).mockRejectedValue(makeP2002());

    await expect(
      repo.insert({
        gameSessionId: 'gs-1',
        blockerMembershipId: 'mem-blocker',
        blockedMembershipId: 'mem-blocked',
      }),
    ).resolves.toBeUndefined();
  });

  // -------------------------------------------------------------------------
  // delete — idempotent on P2025
  // -------------------------------------------------------------------------

  it('delete: resolves without error on P2025 record not found (idempotent unblock)', async () => {
    vi.mocked(prisma.chatBlock.delete).mockRejectedValue(makeP2025());

    await expect(
      repo.delete({
        gameSessionId: 'gs-1',
        blockerMembershipId: 'mem-blocker',
        blockedMembershipId: 'mem-blocked',
      }),
    ).resolves.toBeUndefined();
  });

  // -------------------------------------------------------------------------
  // listForBlocker — display names resolved
  // -------------------------------------------------------------------------

  it('listForBlocker: returns block summaries with resolved display names', async () => {
    vi.mocked(prisma.chatBlock.findMany).mockResolvedValue([
      {
        blockedMembershipId: 'mem-blocked',
        createdAt: new Date('2026-05-17T10:00:00.000Z'),
        blocked: { id: 'mem-blocked', userId: 'user-blocked' },
      },
    ] as never);
    vi.mocked(prisma.user.findMany).mockResolvedValue([
      { id: 'user-blocked', displayName: 'Tariq' },
    ] as never);

    const result = await repo.listForBlocker({
      gameSessionId: 'gs-1',
      blockerMembershipId: 'mem-blocker',
    });

    expect(result).toHaveLength(1);
    expect(result[0]!.targetMembershipId).toBe('mem-blocked');
    expect(result[0]!.targetDisplayName).toBe('Tariq');
    expect(result[0]!.createdAt).toBe('2026-05-17T10:00:00.000Z');
  });
});
