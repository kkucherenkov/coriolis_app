import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ChatNotMemberError } from '../domain/chat.errors';

import { ListChatMessagesQuery } from './list-chat-messages.query';
import { ListChatMessagesHandler } from './list-chat-messages.handler';

import type {
  IMembershipRepo,
  MembershipReadModel,
} from '../../memberships/domain/membership.ports';
import type { ChatMessageReadModel, IChatMessageRepo } from '../domain/chat.ports';

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

function makeMessageRepo(): IChatMessageRepo {
  return {
    insert: vi.fn(),
    findById: vi.fn(),
    updateBody: vi.fn(),
    softDelete: vi.fn(),
    list: vi.fn(),
    listConversations: vi.fn(),
    countNewerThan: vi.fn(),
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

function makeMessage(overrides: Partial<ChatMessageReadModel> = {}): ChatMessageReadModel {
  return {
    id: 'msg-1',
    gameSessionId: 'gs-1',
    authorMembershipId: 'mem-caller',
    authorDisplayName: 'Yara',
    targetMembershipId: null,
    kind: 'text',
    body: 'Hello broadcast',
    systemKey: null,
    systemParams: null,
    createdAt: '2026-05-17T10:00:00.000Z',
    editedAt: null,
    deletedAt: null,
    ...overrides,
  };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe('ListChatMessagesHandler', () => {
  let membershipRepo: IMembershipRepo;
  let chatRepo: IChatMessageRepo;
  let handler: ListChatMessagesHandler;

  beforeEach(() => {
    membershipRepo = makeMembershipRepo();
    chatRepo = makeMessageRepo();
    handler = new ListChatMessagesHandler(membershipRepo, chatRepo);
  });

  it('broadcast pagination — delegates to repo with conversation=broadcast and clamped limit', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMember());
    const page = { items: [makeMessage()], nextCursor: null };
    vi.mocked(chatRepo.list).mockResolvedValue(page);

    const result = await handler.execute(
      new ListChatMessagesQuery('gs-1', 'user-1', 'broadcast', null, 200),
    );

    expect(result).toEqual(page);
    expect(chatRepo.list).toHaveBeenCalledWith(
      expect.objectContaining({
        gameSessionId: 'gs-1',
        callerMembershipId: 'mem-caller',
        conversation: 'broadcast',
        cursor: null,
        limit: 100, // clamped from 200
      }),
    );
  });

  it('whisper pagination — partner is active member, delegates with partner membership id', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMember());
    const partnerMem = makeMember({ id: 'mem-partner', userId: 'user-2' });
    vi.mocked(membershipRepo.findById).mockResolvedValue(partnerMem);
    const page = { items: [makeMessage({ targetMembershipId: 'mem-partner' })], nextCursor: null };
    vi.mocked(chatRepo.list).mockResolvedValue(page);

    const result = await handler.execute(
      new ListChatMessagesQuery('gs-1', 'user-1', 'mem-partner', null, 10),
    );

    expect(result).toEqual(page);
    expect(chatRepo.list).toHaveBeenCalledWith(
      expect.objectContaining({
        conversation: 'mem-partner',
        limit: 10,
      }),
    );
  });

  it('same-ms tie-break by id — handler returns items unchanged (repo handles ordering)', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMember());
    const ts = '2026-05-17T10:00:00.000Z';
    const items = [
      makeMessage({ id: 'msg-z', createdAt: ts }),
      makeMessage({ id: 'msg-a', createdAt: ts }),
    ];
    vi.mocked(chatRepo.list).mockResolvedValue({ items, nextCursor: null });

    const result = await handler.execute(
      new ListChatMessagesQuery('gs-1', 'user-1', 'broadcast', null, 50),
    );

    // Handler trusts repo ordering — returns items as-is
    expect(result.items).toEqual(items);
    expect(result.items[0]!.id).toBe('msg-z');
    expect(result.items[1]!.id).toBe('msg-a');
  });

  it('non-member caller — throws ChatNotMemberError (403)', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(null);

    await expect(
      handler.execute(new ListChatMessagesQuery('gs-1', 'user-x', 'broadcast', null, 50)),
    ).rejects.toBeInstanceOf(ChatNotMemberError);
    expect(chatRepo.list).not.toHaveBeenCalled();
  });

  it('unknown partner — returns empty result without 404 (avoids leaking presence)', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMember());
    // findById returns null — partner doesn't exist in session
    vi.mocked(membershipRepo.findById).mockResolvedValue(null);

    const result = await handler.execute(
      new ListChatMessagesQuery('gs-1', 'user-1', 'mem-ghost', null, 50),
    );

    expect(result).toEqual({ items: [], nextCursor: null });
    expect(chatRepo.list).not.toHaveBeenCalled();
  });
});
