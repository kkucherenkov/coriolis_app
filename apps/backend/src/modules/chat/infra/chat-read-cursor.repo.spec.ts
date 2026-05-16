/**
 * Unit tests for ChatReadCursorRepo.
 * Prisma is mocked via vi.fn() — no real DB.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ChatReadCursorRepo } from './chat-read-cursor.repo';

import type { PrismaService } from '../../../common/prisma/prisma.service';

function makePrismaMock() {
  return {
    chatReadCursor: {
      upsert: vi.fn(),
      findMany: vi.fn(),
    },
  } as unknown as PrismaService;
}

describe('ChatReadCursorRepo', () => {
  let prisma: ReturnType<typeof makePrismaMock>;
  let repo: ChatReadCursorRepo;

  beforeEach(() => {
    prisma = makePrismaMock();
    repo = new ChatReadCursorRepo(prisma);
  });

  it('upsert: calls prisma.chatReadCursor.upsert with the composite key', async () => {
    vi.mocked(prisma.chatReadCursor.upsert).mockResolvedValue(undefined as never);

    const lastReadAt = new Date('2026-05-17T10:00:00.000Z');
    await repo.upsert({ membershipId: 'mem-1', conversationKey: 'broadcast', lastReadAt });

    expect(prisma.chatReadCursor.upsert).toHaveBeenCalledWith({
      where: {
        membershipId_conversationKey: {
          membershipId: 'mem-1',
          conversationKey: 'broadcast',
        },
      },
      create: {
        membershipId: 'mem-1',
        conversationKey: 'broadcast',
        lastReadAt,
      },
      update: { lastReadAt },
    });
  });

  it('getMap: returns a Map keyed by conversationKey with Date values', async () => {
    const lastReadAt = new Date('2026-05-17T09:00:00.000Z');
    vi.mocked(prisma.chatReadCursor.findMany).mockResolvedValue([
      { membershipId: 'mem-1', conversationKey: 'broadcast', lastReadAt },
      {
        membershipId: 'mem-1',
        conversationKey: 'mem-partner',
        lastReadAt: new Date('2026-05-17T08:00:00.000Z'),
      },
    ] as never);

    const map = await repo.getMap({
      membershipId: 'mem-1',
      keys: ['broadcast', 'mem-partner'],
    });

    expect(map).toBeInstanceOf(Map);
    expect(map.size).toBe(2);
    expect(map.get('broadcast')).toEqual(lastReadAt);
    expect(map.get('mem-partner')).toEqual(new Date('2026-05-17T08:00:00.000Z'));
  });
});
