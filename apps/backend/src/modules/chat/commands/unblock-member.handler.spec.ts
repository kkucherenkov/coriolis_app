import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ChatNotMemberError } from '../domain/chat.errors';

import { UnblockMemberCommand } from './unblock-member.command';
import { UnblockMemberHandler } from './unblock-member.handler';

import type {
  IMembershipRepo,
  MembershipReadModel,
} from '../../memberships/domain/membership.ports';
import type { IChatBlockRepo } from '../domain/chat.ports';

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

function makeMembership(overrides: Partial<MembershipReadModel> = {}): MembershipReadModel {
  return {
    id: 'mem-caller',
    gameSessionId: 'gs-1',
    userId: 'user-1',
    role: 'player',
    displayName: 'Caller',
    characterId: null,
    characterName: null,
    joinedAt: '2026-01-01T00:00:00.000Z',
    leftAt: null,
    ...overrides,
  };
}

describe('UnblockMemberHandler', () => {
  let membershipRepo: IMembershipRepo;
  let blockRepo: IChatBlockRepo;
  let handler: UnblockMemberHandler;

  beforeEach(() => {
    membershipRepo = makeMembershipRepo();
    blockRepo = makeBlockRepo();
    handler = new UnblockMemberHandler(membershipRepo, blockRepo);
  });

  it('unblocks a target member successfully by calling blockRepo.delete with correct args', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMembership());
    vi.mocked(blockRepo.delete).mockResolvedValue(undefined);

    const cmd = new UnblockMemberCommand('gs-1', 'user-1', 'mem-target');
    await handler.execute(cmd);

    expect(blockRepo.delete).toHaveBeenCalledWith({
      gameSessionId: 'gs-1',
      blockerMembershipId: 'mem-caller',
      blockedMembershipId: 'mem-target',
    });
  });

  it('throws ChatNotMemberError when caller is not an active member (403)', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(null);

    const cmd = new UnblockMemberCommand('gs-1', 'user-outsider', 'mem-target');

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatNotMemberError);
    expect(blockRepo.delete).not.toHaveBeenCalled();
  });

  it('completes successfully when block row is missing (idempotent — repo swallows P2025)', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMembership());
    // Repo already handles P2025 internally and resolves — handler must not re-throw
    vi.mocked(blockRepo.delete).mockResolvedValue(undefined);

    const cmd = new UnblockMemberCommand('gs-1', 'user-1', 'mem-never-blocked');
    await expect(handler.execute(cmd)).resolves.toBeUndefined();

    expect(blockRepo.delete).toHaveBeenCalledOnce();
  });
});
