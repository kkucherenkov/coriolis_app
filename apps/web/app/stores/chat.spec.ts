/**
 * chat.spec.ts — unit tests for useChatStore (Phase 8 Stream D, Block 7).
 *
 * Strategy:
 *   - All SDK functions from `@app/api-client-ts` are vi.mock'd so no HTTP
 *     is made. Each test configures its own return values via vi.mocked().
 *   - `createPinia` + `setActivePinia` give each test an isolated store.
 *   - Fake timers are used to test the markRead debounce.
 */

import { beforeEach, afterEach, describe, it, expect, vi } from 'vitest';
import { createPinia, setActivePinia } from 'pinia';
import { useChatStore } from './chat';

// ─── SDK mock ─────────────────────────────────────────────────────────────────

vi.mock('@app/api-client-ts', () => ({
  listChatConversations: vi.fn(),
  listChatMessages: vi.fn(),
  postChatMessage: vi.fn(),
  editChatMessage: vi.fn(),
  deleteChatMessage: vi.fn(),
  markChatConversationRead: vi.fn(),
  listBlocks: vi.fn(),
  blockMember: vi.fn(),
  unblockMember: vi.fn(),
}));

import {
  listChatConversations,
  listChatMessages,
  postChatMessage,
  editChatMessage,
  deleteChatMessage,
  markChatConversationRead,
  listBlocks,
  blockMember,
  unblockMember,
} from '@app/api-client-ts';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

const SESSION_ID = 'session-abc';
const MY_ID = 'member-me';
const PARTNER_ID = 'member-them';

function makeMessage(
  overrides: Partial<{
    id: string;
    authorMembershipId: string | null;
    targetMembershipId: string | null;
    body: string;
    editedAt: string | null;
    deletedAt: string | null;
  }> = {},
) {
  return {
    id: 'msg-1',
    gameSessionId: SESSION_ID,
    authorMembershipId: MY_ID,
    authorDisplayName: 'Me',
    targetMembershipId: null,
    kind: 'text' as const,
    body: 'hello',
    createdAt: '2026-01-01T00:00:00.000Z',
    editedAt: null,
    deletedAt: null,
    ...overrides,
  };
}

function successEmpty() {
  return { data: undefined, error: null };
}

function successMessages(items = [makeMessage()], nextCursor: string | null = null) {
  return { data: { items, nextCursor }, error: null };
}

function successConversations(items = []) {
  return { data: { items }, error: null };
}

function successBlocks(items: { targetMembershipId: string; createdAt: string }[] = []) {
  return { data: { items }, error: null };
}

function errorResult() {
  return { data: undefined, error: { status: 500, detail: 'Server error' } };
}

// ─── Setup / teardown ─────────────────────────────────────────────────────────

beforeEach(() => {
  setActivePinia(createPinia());

  // Default happy-path stubs — individual tests override as needed.
  vi.mocked(listChatConversations).mockResolvedValue(successConversations() as never);
  vi.mocked(listBlocks).mockResolvedValue(successBlocks() as never);
  vi.mocked(listChatMessages).mockResolvedValue(successMessages() as never);
  vi.mocked(postChatMessage).mockResolvedValue({ data: makeMessage(), error: null } as never);
  vi.mocked(editChatMessage).mockResolvedValue(successEmpty() as never);
  vi.mocked(deleteChatMessage).mockResolvedValue(successEmpty() as never);
  vi.mocked(markChatConversationRead).mockResolvedValue(successEmpty() as never);
  vi.mocked(blockMember).mockResolvedValue(successEmpty() as never);
  vi.mocked(unblockMember).mockResolvedValue(successEmpty() as never);
});

afterEach(() => {
  vi.clearAllMocks();
  vi.useRealTimers();
});

// ─── Tests ────────────────────────────────────────────────────────────────────

describe('useChatStore', () => {
  // 1. hydrate seeds conversationsList + blockedByMe + broadcast messages
  it('hydrate seeds conversationsList, blockedByMe and broadcast messages', async () => {
    const summary = {
      conversationKey: 'broadcast',
      kind: 'broadcast' as const,
      partnerMembershipId: null,
      partnerDisplayName: null,
      partnerCharacterName: null,
      lastMessageAt: null,
      unreadCount: 0,
    };
    const blockEntry = { targetMembershipId: PARTNER_ID, createdAt: '2026-01-01T00:00:00.000Z' };
    const msg = makeMessage();

    vi.mocked(listChatConversations).mockResolvedValue({
      data: { items: [summary] },
      error: null,
    } as never);
    vi.mocked(listBlocks).mockResolvedValue({
      data: { items: [blockEntry] },
      error: null,
    } as never);
    vi.mocked(listChatMessages).mockResolvedValue(successMessages([msg], null) as never);

    const store = useChatStore();
    await store.hydrate({ gameSessionId: SESSION_ID, myMembershipId: MY_ID });

    expect(store.conversationsList).toHaveLength(1);
    expect(store.conversationsList[0]!.conversationKey).toBe('broadcast');
    expect(store.blockedByMe.has(PARTNER_ID)).toBe(true);
    expect(store.conversations['broadcast']!.messages).toHaveLength(1);
    expect(store.conversations['broadcast']!.messages[0]!.id).toBe('msg-1');
    expect(store.initialized).toBe(true);
  });

  // 2. send('broadcast', 'hi') pushes optimistic message + calls postChatMessage
  it('send pushes an optimistic message and calls postChatMessage', async () => {
    const store = useChatStore();
    store.gameSessionId = SESSION_ID;
    store.myMembershipId = MY_ID;

    // The store removes the optimistic once postChatMessage resolves —
    // capture message count BEFORE awaiting.
    let optimisticSeen = false;
    vi.mocked(postChatMessage).mockImplementation(async () => {
      optimisticSeen = (store.conversations['broadcast']?.messages ?? []).some((m) =>
        m.id.startsWith('pending_'),
      );
      return { data: makeMessage({ id: 'server-1' }), error: null } as never;
    });

    await store.send('broadcast', 'hi');

    expect(optimisticSeen).toBe(true);
    expect(vi.mocked(postChatMessage)).toHaveBeenCalledOnce();
    const call = vi.mocked(postChatMessage).mock.calls[0]![0];
    expect(call.body.body).toBe('hi');
    expect(call.body.kind).toBe('text');
    expect(call.body.targetMembershipId).toBeNull();
  });

  // 3. send rolls back optimistic on SDK error + sets lastError
  it('send rolls back the optimistic message on SDK error and sets lastError', async () => {
    const store = useChatStore();
    store.gameSessionId = SESSION_ID;
    store.myMembershipId = MY_ID;

    vi.mocked(postChatMessage).mockResolvedValue(errorResult() as never);

    await store.send('broadcast', 'fail me');

    expect(store.conversations['broadcast']?.messages ?? []).toHaveLength(0);
    expect(store.lastError).toBe('Failed to send message');
  });

  // 4. delete(id) calls deleteChatMessage
  it('delete calls deleteChatMessage with the correct message id', async () => {
    const store = useChatStore();
    await store.delete('msg-42');

    expect(vi.mocked(deleteChatMessage)).toHaveBeenCalledWith({ path: { id: 'msg-42' } });
  });

  // 5. applyRealtime chat.message.posted (broadcast) appends to broadcast conversation
  it('applyRealtime posted (broadcast) appends message to broadcast conversation', () => {
    const store = useChatStore();
    store.myMembershipId = MY_ID;

    const msg = makeMessage({ id: 'rt-1', targetMembershipId: null });
    store.applyRealtime({ type: 'chat.message.posted', message: msg });

    expect(store.conversations['broadcast']!.messages).toHaveLength(1);
    expect(store.conversations['broadcast']!.messages[0]!.id).toBe('rt-1');
  });

  // 6. applyRealtime chat.message.edited patches the message in place
  it('applyRealtime edited patches the message body in place', () => {
    const store = useChatStore();
    store.myMembershipId = MY_ID;
    store.conversations['broadcast'] = {
      messages: [makeMessage({ id: 'msg-edit', body: 'original' })],
      nextCursor: null,
      hasLoadedInitial: true,
      pendingSendIds: new Set(),
      composerValue: '',
      isAtBottom: true,
      newMessagesCount: 0,
    };

    store.applyRealtime({
      type: 'chat.message.edited',
      message: makeMessage({
        id: 'msg-edit',
        body: 'updated',
        editedAt: '2026-01-01T00:01:00.000Z',
      }),
    });

    expect(store.conversations['broadcast']!.messages[0]!.body).toBe('updated');
    expect(store.conversations['broadcast']!.messages[0]!.editedAt).toBe(
      '2026-01-01T00:01:00.000Z',
    );
  });

  // 7. applyRealtime chat.message.deleted flips deletedAt
  it('applyRealtime deleted stamps deletedAt on the correct message', () => {
    const store = useChatStore();
    store.myMembershipId = MY_ID;
    store.conversations['broadcast'] = {
      messages: [makeMessage({ id: 'msg-del' })],
      nextCursor: null,
      hasLoadedInitial: true,
      pendingSendIds: new Set(),
      composerValue: '',
      isAtBottom: true,
      newMessagesCount: 0,
    };

    store.applyRealtime({
      type: 'chat.message.deleted',
      id: 'msg-del',
      gameSessionId: SESSION_ID,
      authorMembershipId: MY_ID,
      targetMembershipId: null,
    });

    expect(store.conversations['broadcast']!.messages[0]!.deletedAt).toBeTruthy();
  });

  // 8. block(id) adds to blockedByMe + drops conversation + closes whisper tab
  it('block adds to blockedByMe, drops the conversation summary and closes the whisper tab', async () => {
    const store = useChatStore();
    store.gameSessionId = SESSION_ID;
    store.myMembershipId = MY_ID;
    store.conversationsList = [
      {
        conversationKey: PARTNER_ID,
        kind: 'whisper',
        partnerMembershipId: PARTNER_ID,
        partnerDisplayName: 'Them',
        partnerCharacterName: null,
        lastMessageAt: null,
        unreadCount: 0,
      },
    ];
    store.openWhisperKeys = [PARTNER_ID];
    store.activeConversationKey = PARTNER_ID;

    await store.block(PARTNER_ID);

    expect(store.blockedByMe.has(PARTNER_ID)).toBe(true);
    expect(store.conversationsList).toHaveLength(0);
    expect(store.openWhisperKeys).not.toContain(PARTNER_ID);
    expect(store.activeConversationKey).toBe('broadcast');
  });

  // 9. markRead debounces (2000 ms)
  it('markRead debounces — SDK called once after 2000 ms even with rapid calls', async () => {
    vi.useFakeTimers();

    const store = useChatStore();
    store.gameSessionId = SESSION_ID;

    store.markRead('broadcast', '2026-01-01T00:00:01.000Z');
    store.markRead('broadcast', '2026-01-01T00:00:02.000Z');
    store.markRead('broadcast', '2026-01-01T00:00:03.000Z');

    // Before timeout fires — SDK should NOT have been called yet.
    expect(vi.mocked(markChatConversationRead)).not.toHaveBeenCalled();

    vi.advanceTimersByTime(2000);

    // Allow microtasks from any resolved promises inside the debouncer.
    await Promise.resolve();

    expect(vi.mocked(markChatConversationRead)).toHaveBeenCalledOnce();
  });

  // 10. openWhisper switches activeConversationKey + adds to openWhisperKeys + hydrates
  it('openWhisper switches to the whisper key and hydrates message history', async () => {
    const whisperMsg = makeMessage({ id: 'w-1', targetMembershipId: PARTNER_ID });
    vi.mocked(listChatMessages).mockResolvedValue(successMessages([whisperMsg]) as never);

    const store = useChatStore();
    store.gameSessionId = SESSION_ID;
    store.myMembershipId = MY_ID;

    await store.openWhisper(PARTNER_ID);

    expect(store.activeConversationKey).toBe(PARTNER_ID);
    expect(store.openWhisperKeys).toContain(PARTNER_ID);
    expect(store.conversations[PARTNER_ID]!.hasLoadedInitial).toBe(true);
    expect(store.conversations[PARTNER_ID]!.messages).toHaveLength(1);
  });

  // 11. closeWhisper removes from openWhisperKeys + falls back to broadcast
  it('closeWhisper removes the tab and falls back to broadcast when it was active', () => {
    const store = useChatStore();
    store.openWhisperKeys = [PARTNER_ID];
    store.activeConversationKey = PARTNER_ID;

    store.closeWhisper(PARTNER_ID);

    expect(store.openWhisperKeys).not.toContain(PARTNER_ID);
    expect(store.activeConversationKey).toBe('broadcast');
  });

  // 12. applyRealtime posted with isAtBottom === false increments newMessagesCount
  it('applyRealtime posted increments newMessagesCount when conversation is not at bottom', () => {
    const store = useChatStore();
    store.myMembershipId = MY_ID;
    store.conversations['broadcast'] = {
      messages: [],
      nextCursor: null,
      hasLoadedInitial: true,
      pendingSendIds: new Set(),
      composerValue: '',
      isAtBottom: false,
      newMessagesCount: 0,
    };

    store.applyRealtime({
      type: 'chat.message.posted',
      message: makeMessage({ id: 'bump-1', targetMembershipId: null }),
    });
    store.applyRealtime({
      type: 'chat.message.posted',
      message: makeMessage({ id: 'bump-2', targetMembershipId: null }),
    });

    expect(store.conversations['broadcast']!.newMessagesCount).toBe(2);
  });

  // 13. applyRealtime posted for unknown whisper key auto-opens whisper tab
  it('applyRealtime posted for an unknown whisper key auto-opens the whisper tab', () => {
    const store = useChatStore();
    store.myMembershipId = MY_ID;

    const msg = makeMessage({
      id: 'whisper-in',
      authorMembershipId: PARTNER_ID,
      targetMembershipId: MY_ID,
    });

    store.applyRealtime({ type: 'chat.message.posted', message: msg });

    expect(store.openWhisperKeys).toContain(PARTNER_ID);
    expect(store.conversations[PARTNER_ID]!.messages).toHaveLength(1);
  });
});
