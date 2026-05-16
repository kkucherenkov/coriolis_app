import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  ChatMessageNotAuthorizedError,
  ChatNotMemberError,
  ChatTargetNotMemberError,
} from '../domain/chat.errors';

import { BlockMemberCommand } from './block-member.command';
import { BlockMemberHandler } from './block-member.handler';

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

describe('BlockMemberHandler', () => {
  let membershipRepo: IMembershipRepo;
  let blockRepo: IChatBlockRepo;
  let handler: BlockMemberHandler;

  beforeEach(() => {
    membershipRepo = makeMembershipRepo();
    blockRepo = makeBlockRepo();
    handler = new BlockMemberHandler(membershipRepo, blockRepo);
  });

  it('blocks a target member successfully (idempotent insert)', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMembership());
    vi.mocked(membershipRepo.findById).mockResolvedValue(
      makeMembership({ id: 'mem-target', userId: 'user-target' }),
    );
    vi.mocked(blockRepo.insert).mockResolvedValue(undefined);

    const cmd = new BlockMemberCommand('gs-1', 'user-1', 'mem-target');
    await handler.execute(cmd);

    expect(blockRepo.insert).toHaveBeenCalledWith({
      gameSessionId: 'gs-1',
      blockerMembershipId: 'mem-caller',
      blockedMembershipId: 'mem-target',
    });
  });

  it('throws ChatNotMemberError when caller is not an active member (403)', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(null);

    const cmd = new BlockMemberCommand('gs-1', 'user-outsider', 'mem-target');

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatNotMemberError);
    expect(blockRepo.insert).not.toHaveBeenCalled();
  });

  it('throws ChatMessageNotAuthorizedError when caller tries to block themselves (403)', async () => {
    // callerMembershipId === targetMembershipId
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMembership());

    const cmd = new BlockMemberCommand('gs-1', 'user-1', 'mem-caller');

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatMessageNotAuthorizedError);
    expect(blockRepo.insert).not.toHaveBeenCalled();
  });
});
