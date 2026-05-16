import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ChatNotMemberError } from '../domain/chat.errors';

import { ListBlocksQuery } from './list-blocks.query';
import { ListBlocksHandler } from './list-blocks.handler';

import type {
  IMembershipRepo,
  MembershipReadModel,
} from '../../memberships/domain/membership.ports';
import type { ChatBlockSummaryReadModel, IChatBlockRepo } from '../domain/chat.ports';

// ---------------------------------------------------------------------------
// Factory helpers
// ---------------------------------------------------------------------------

function makeMembershipRepo(): IMembershipRepo {
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

function makeBlockRepo(): IChatBlockRepo {
  return {
    exists: vi.fn(),
    insert: vi.fn(),
    delete: vi.fn(),
    listForBlocker: vi.fn(),
  };
}

function makeMember(overrides: Partial<MembershipReadModel> = {}): MembershipReadModel {
  return {
    id: 'mem-caller',
    gameSessionId: 'gs-1',
    userId: 'user-1',
    role: 'player',
    displayName: 'Yara',
    characterId: null,
    characterName: null,
    joinedAt: '2026-05-17T10:00:00.000Z',
    leftAt: null,
    ...overrides,
  };
}

function makeBlock(overrides: Partial<ChatBlockSummaryReadModel> = {}): ChatBlockSummaryReadModel {
  return {
    targetMembershipId: 'mem-blocked',
    targetDisplayName: 'Farid',
    createdAt: '2026-05-17T10:00:00.000Z',
    ...overrides,
  };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe('ListBlocksHandler', () => {
  let membershipRepo: IMembershipRepo;
  let blockRepo: IChatBlockRepo;
  let handler: ListBlocksHandler;

  beforeEach(() => {
    membershipRepo = makeMembershipRepo();
    blockRepo = makeBlockRepo();
    handler = new ListBlocksHandler(membershipRepo, blockRepo);
  });

  it('returns the caller own block list', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMember());
    const blocks = [makeBlock(), makeBlock({ targetMembershipId: 'mem-other' })];
    vi.mocked(blockRepo.listForBlocker).mockResolvedValue(blocks);

    const result = await handler.execute(new ListBlocksQuery('gs-1', 'user-1'));

    expect(result).toEqual(blocks);
    expect(blockRepo.listForBlocker).toHaveBeenCalledWith({
      gameSessionId: 'gs-1',
      blockerMembershipId: 'mem-caller',
    });
  });

  it('non-member caller — throws ChatNotMemberError (403)', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(null);

    await expect(handler.execute(new ListBlocksQuery('gs-1', 'user-x'))).rejects.toBeInstanceOf(
      ChatNotMemberError,
    );
    expect(blockRepo.listForBlocker).not.toHaveBeenCalled();
  });
});
