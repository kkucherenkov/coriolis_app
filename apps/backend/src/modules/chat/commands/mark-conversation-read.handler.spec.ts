import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ChatNotMemberError, ChatTargetNotMemberError } from '../domain/chat.errors';

import { MarkConversationReadCommand } from './mark-conversation-read.command';
import { MarkConversationReadHandler } from './mark-conversation-read.handler';

import type {
  IMembershipRepo,
  MembershipReadModel,
} from '../../memberships/domain/membership.ports';
import type { IChatReadCursorRepo } from '../domain/chat.ports';

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

function makeReadCursorRepo(): IChatReadCursorRepo {
  return {
    upsert: vi.fn(),
    getMap: vi.fn(),
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

describe('MarkConversationReadHandler', () => {
  let membershipRepo: IMembershipRepo;
  let readCursorRepo: IChatReadCursorRepo;
  let handler: MarkConversationReadHandler;
  const lastReadAt = new Date('2026-05-17T10:05:00.000Z');

  beforeEach(() => {
    membershipRepo = makeMembershipRepo();
    readCursorRepo = makeReadCursorRepo();
    handler = new MarkConversationReadHandler(membershipRepo, readCursorRepo);
  });

  it('marks broadcast conversation as read successfully', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMembership());
    vi.mocked(readCursorRepo.upsert).mockResolvedValue(undefined);

    const cmd = new MarkConversationReadCommand('gs-1', 'user-1', 'broadcast', lastReadAt);
    await handler.execute(cmd);

    expect(membershipRepo.findActiveByUser).toHaveBeenCalledWith('gs-1', 'user-1');
    expect(readCursorRepo.upsert).toHaveBeenCalledWith({
      membershipId: 'mem-caller',
      conversationKey: 'broadcast',
      lastReadAt,
    });
  });

  it('marks whisper conversation as read successfully when partner membership is valid', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMembership());
    // findById for partner membership
    vi.mocked(membershipRepo.findById).mockResolvedValue(
      makeMembership({ id: 'mem-partner', userId: 'user-partner' }),
    );
    vi.mocked(readCursorRepo.upsert).mockResolvedValue(undefined);

    const cmd = new MarkConversationReadCommand('gs-1', 'user-1', 'mem-partner', lastReadAt);
    await handler.execute(cmd);

    expect(membershipRepo.findById).toHaveBeenCalledWith('mem-partner');
    expect(readCursorRepo.upsert).toHaveBeenCalledWith({
      membershipId: 'mem-caller',
      conversationKey: 'mem-partner',
      lastReadAt,
    });
  });

  it('throws ChatNotMemberError when caller is not an active member (403)', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(null);

    const cmd = new MarkConversationReadCommand('gs-1', 'user-outsider', 'broadcast', lastReadAt);

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatNotMemberError);
    expect(readCursorRepo.upsert).not.toHaveBeenCalled();
  });

  it('throws ChatTargetNotMemberError when conversation key is not a valid membership in session (404)', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMembership());
    // Partner membership belongs to a different session
    vi.mocked(membershipRepo.findById).mockResolvedValue(
      makeMembership({ id: 'mem-other', gameSessionId: 'gs-OTHER', userId: 'user-other' }),
    );

    const cmd = new MarkConversationReadCommand('gs-1', 'user-1', 'mem-other', lastReadAt);

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatTargetNotMemberError);
    expect(readCursorRepo.upsert).not.toHaveBeenCalled();
  });
});
