import { beforeEach, describe, expect, it, vi } from 'vitest';

import { MembershipNotAuthorizedError } from '../domain/membership.errors';

import { ListMembershipsQuery } from './list-memberships.query';
import { ListMembershipsHandler } from './list-memberships.handler';

import type { IMembershipRepo, MembershipReadModel } from '../domain/membership.ports';

function makeRepo(): IMembershipRepo {
  return {
    listActive: vi.fn(),
    findById: vi.fn(),
    findActiveByUser: vi.fn(),
    softDelete: vi.fn(),
    setCharacter: vi.fn(),
    insert: vi.fn(),
    findActiveSessionsForUser: vi.fn(),
  };
}

function makeMember(overrides: Partial<MembershipReadModel> = {}): MembershipReadModel {
  return {
    id: 'm-1',
    gameSessionId: 'gs-1',
    userId: 'user-1',
    role: 'player',
    displayName: 'Yara',
    characterId: null,
    characterName: null,
    joinedAt: '2026-05-15T10:00:00.000Z',
    leftAt: null,
    ...overrides,
  };
}

describe('ListMembershipsHandler', () => {
  let repo: IMembershipRepo;
  let handler: ListMembershipsHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new ListMembershipsHandler(repo);
  });

  it('returns the active member list to the GM', async () => {
    vi.mocked(repo.listActive).mockResolvedValue([
      makeMember({ role: 'gm', userId: 'user-gm' }),
      makeMember(),
    ]);
    vi.mocked(repo.findActiveByUser).mockResolvedValue(
      makeMember({ role: 'gm', userId: 'user-gm' }),
    );
    const result = await handler.execute(new ListMembershipsQuery('gs-1', 'user-gm'));
    expect(result).toHaveLength(2);
  });

  it('returns the active member list to any active member', async () => {
    vi.mocked(repo.listActive).mockResolvedValue([makeMember()]);
    vi.mocked(repo.findActiveByUser).mockResolvedValue(makeMember());
    const result = await handler.execute(new ListMembershipsQuery('gs-1', 'user-1'));
    expect(result).toHaveLength(1);
  });

  it('refuses callers who are neither GM nor active member', async () => {
    vi.mocked(repo.findActiveByUser).mockResolvedValue(null);
    await expect(
      handler.execute(new ListMembershipsQuery('gs-1', 'user-X')),
    ).rejects.toBeInstanceOf(MembershipNotAuthorizedError);
    expect(repo.listActive).not.toHaveBeenCalled();
  });
});
