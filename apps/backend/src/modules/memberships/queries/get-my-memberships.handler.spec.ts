import { beforeEach, describe, expect, it, vi } from 'vitest';

import { GetMyMembershipsQuery } from './get-my-memberships.query';
import { GetMyMembershipsHandler } from './get-my-memberships.handler';

import type { IMembershipRepo, MyMembershipReadModel } from '../domain/membership.ports';

function makeMembershipRepo(): IMembershipRepo {
  return {
    listActive: vi.fn(),
    findById: vi.fn(),
    findActiveByUser: vi.fn(),
    softDelete: vi.fn(),
    setCharacter: vi.fn(),
    insert: vi.fn(),
    findActiveSessionsForUser: vi.fn().mockResolvedValue([]),
  };
}

function makeMembership(overrides: Partial<MyMembershipReadModel> = {}): MyMembershipReadModel {
  return {
    membershipId: 'm-1',
    gameSessionId: 'gs-1',
    sessionName: 'The Mercy of Kua',
    role: 'player',
    characterId: null,
    characterName: null,
    joinedAt: '2026-05-15T10:00:00.000Z',
    ...overrides,
  };
}

describe('GetMyMembershipsHandler', () => {
  let mRepo: IMembershipRepo;
  let handler: GetMyMembershipsHandler;

  beforeEach(() => {
    mRepo = makeMembershipRepo();
    handler = new GetMyMembershipsHandler(mRepo);
  });

  it('returns empty list when user has no active memberships', async () => {
    vi.mocked(mRepo.findActiveSessionsForUser).mockResolvedValue([]);

    const result = await handler.execute(new GetMyMembershipsQuery('user-1'));

    expect(result).toEqual([]);
    expect(mRepo.findActiveSessionsForUser).toHaveBeenCalledWith('user-1');
  });

  it('returns all active memberships including both gm and player roles', async () => {
    const gm = makeMembership({ membershipId: 'm-gm', role: 'gm', sessionName: 'Session A' });
    const player = makeMembership({
      membershipId: 'm-player',
      role: 'player',
      sessionName: 'Session B',
    });
    vi.mocked(mRepo.findActiveSessionsForUser).mockResolvedValue([gm, player]);

    const result = await handler.execute(new GetMyMembershipsQuery('user-1'));

    expect(result).toHaveLength(2);
    expect(result[0]!.role).toBe('gm');
    expect(result[1]!.role).toBe('player');
  });

  it('delegates filtering to the repo (single call, repo is the source of truth)', async () => {
    const active = makeMembership();
    vi.mocked(mRepo.findActiveSessionsForUser).mockResolvedValue([active]);

    const result = await handler.execute(new GetMyMembershipsQuery('user-1'));

    expect(result).toHaveLength(1);
    expect(mRepo.findActiveSessionsForUser).toHaveBeenCalledOnce();
  });
});
