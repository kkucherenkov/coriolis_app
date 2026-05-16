import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ChatNotMemberError } from '../domain/chat.errors';

import { ListConversationsQuery } from './list-conversations.query';
import { ListConversationsHandler } from './list-conversations.handler';

import type {
  IMembershipRepo,
  MembershipReadModel,
} from '../../memberships/domain/membership.ports';
import type {
  ConversationSummaryReadModel,
  IChatMessageRepo,
  IChatReadCursorRepo,
} from '../domain/chat.ports';

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

function makeCursorRepo(): IChatReadCursorRepo {
  return {
    upsert: vi.fn(),
    getMap: vi.fn(),
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

function makeWhisperSummary(
  overrides: Partial<ConversationSummaryReadModel> = {},
): ConversationSummaryReadModel {
  return {
    conversationKey: 'mem-partner',
    kind: 'whisper',
    partnerMembershipId: 'mem-partner',
    partnerDisplayName: 'Farid',
    partnerCharacterName: null,
    lastMessageAt: '2026-05-17T10:00:00.000Z',
    unreadCount: 0,
    ...overrides,
  };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe('ListConversationsHandler', () => {
  let membershipRepo: IMembershipRepo;
  let chatRepo: IChatMessageRepo;
  let cursorRepo: IChatReadCursorRepo;
  let handler: ListConversationsHandler;

  beforeEach(() => {
    membershipRepo = makeMembershipRepo();
    chatRepo = makeMessageRepo();
    cursorRepo = makeCursorRepo();
    handler = new ListConversationsHandler(membershipRepo, chatRepo, cursorRepo);
  });

  it('always includes broadcast row first regardless of whisper partners', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMember());
    vi.mocked(chatRepo.listConversations).mockResolvedValue([makeWhisperSummary()]);
    vi.mocked(cursorRepo.getMap).mockResolvedValue(new Map());
    // broadcast: 2 messages newer than null cursor, lastMessageAt = some date
    const broadcastLastAt = new Date('2026-05-17T10:05:00.000Z');
    vi.mocked(chatRepo.countNewerThan).mockImplementation(async (args) => {
      if (args.conversation === 'broadcast') {
        return { count: 2, lastMessageAt: broadcastLastAt };
      }
      return { count: 0, lastMessageAt: null };
    });

    const result = await handler.execute(new ListConversationsQuery('gs-1', 'user-1'));

    expect(result.items[0]!.conversationKey).toBe('broadcast');
    expect(result.items[0]!.kind).toBe('broadcast');
    expect(result.items[0]!.partnerMembershipId).toBeNull();
    expect(result.items.length).toBeGreaterThanOrEqual(2);
  });

  it('lists distinct whisper partners returned by repo', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMember());
    const partners = [
      makeWhisperSummary({ conversationKey: 'mem-a', partnerMembershipId: 'mem-a' }),
      makeWhisperSummary({ conversationKey: 'mem-b', partnerMembershipId: 'mem-b' }),
    ];
    vi.mocked(chatRepo.listConversations).mockResolvedValue(partners);
    vi.mocked(cursorRepo.getMap).mockResolvedValue(new Map());
    vi.mocked(chatRepo.countNewerThan).mockResolvedValue({ count: 0, lastMessageAt: null });

    const result = await handler.execute(new ListConversationsQuery('gs-1', 'user-1'));

    // First item is broadcast, then the two partners
    const keys = result.items.map((i) => i.conversationKey);
    expect(keys).toContain('mem-a');
    expect(keys).toContain('mem-b');
    expect(result.items.length).toBe(3); // broadcast + 2 partners
  });

  it('respects read cursor: unread count is N when N messages newer than cursor', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMember());
    vi.mocked(chatRepo.listConversations).mockResolvedValue([makeWhisperSummary()]);

    const cursorDate = new Date('2026-05-17T09:00:00.000Z');
    vi.mocked(cursorRepo.getMap).mockResolvedValue(
      new Map([
        ['broadcast', cursorDate],
        ['mem-partner', cursorDate],
      ]),
    );

    // broadcast: 3 messages newer than cursor; whisper partner: 1 message newer than cursor
    vi.mocked(chatRepo.countNewerThan).mockImplementation(async (args) => {
      if (args.conversation === 'broadcast') {
        return { count: 3, lastMessageAt: new Date('2026-05-17T10:00:00.000Z') };
      }
      return { count: 1, lastMessageAt: new Date('2026-05-17T09:30:00.000Z') };
    });

    const result = await handler.execute(new ListConversationsQuery('gs-1', 'user-1'));

    const broadcast = result.items.find((i) => i.conversationKey === 'broadcast')!;
    const whisper = result.items.find((i) => i.conversationKey === 'mem-partner')!;
    expect(broadcast.unreadCount).toBe(3);
    expect(whisper.unreadCount).toBe(1);
  });

  it('non-member caller — throws ChatNotMemberError (403)', async () => {
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(null);

    await expect(
      handler.execute(new ListConversationsQuery('gs-1', 'user-x')),
    ).rejects.toBeInstanceOf(ChatNotMemberError);
    expect(chatRepo.listConversations).not.toHaveBeenCalled();
  });
});
