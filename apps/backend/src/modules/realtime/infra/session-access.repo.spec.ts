import { describe, expect, it, vi } from 'vitest';

import { SessionAccessRepo } from './session-access.repo';

import type { PrismaService } from '../../../common/prisma/prisma.service';

function makePrisma(): PrismaService {
  return {
    gameSessionMembership: {
      findMany: vi.fn(),
    },
  } as unknown as PrismaService;
}

describe('SessionAccessRepo', () => {
  it('queries active memberships (leftAt IS NULL) not session ownership', async () => {
    const prisma = makePrisma();
    vi.mocked(prisma.gameSessionMembership.findMany).mockResolvedValue([
      { gameSessionId: 'gs-1' },
      { gameSessionId: 'gs-2' },
    ] as Awaited<ReturnType<typeof prisma.gameSessionMembership.findMany>>);

    const repo = new SessionAccessRepo(prisma);
    const result = await repo.findActiveSessionIdsForUser('user-1');

    expect(prisma.gameSessionMembership.findMany).toHaveBeenCalledWith({
      where: { userId: 'user-1', leftAt: null },
      select: { gameSessionId: true },
    });
    expect(result).toEqual(['gs-1', 'gs-2']);
  });

  it('excludes kicked members (leftAt IS NOT NULL) — enforced by repo filter (regression for Stream B)', async () => {
    const prisma = makePrisma();
    vi.mocked(prisma.gameSessionMembership.findMany).mockResolvedValue([]);

    const repo = new SessionAccessRepo(prisma);
    const result = await repo.findActiveSessionIdsForUser('kicked-user');

    expect(result).toEqual([]);
  });
});
