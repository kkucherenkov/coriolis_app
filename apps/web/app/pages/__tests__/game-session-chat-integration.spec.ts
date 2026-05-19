/**
 * Route-level integration spec for the chat surface inside the
 * `app/game-sessions/[id]` page (Phase 8.5 follow-up #8).
 *
 * Scope
 * ─────
 * The page SFC itself uses Nuxt auto-imports (`useRoute`, `useI18n` with the
 * `useScope: 'local'` block, NuxtLink, layout middleware) that require a full
 * Nuxt + happy-dom runtime — the existing sibling specs in this folder all
 * test composables / structural assertions, never `mount()` the page. The
 * approach here is **page-faithful, not page-identical**: we mount a small
 * `<HarnessPage>` SFC that composes the exact same wiring the page does
 * around the chat surface:
 *
 *   - `useChatStore()`  (Pinia) — owns conversation state.
 *   - `useSessionChatRealtime()` — Centrifugo chat subscriptions.
 *   - `useSessionPresence()` — Centrifugo presence (drives the dot).
 *   - `AppChatPanel` bound through the same `chatPanelBindings` shape from
 *     `app/pages/app/game-sessions/[id].vue:223-249` — `tabs`, `activeKey`,
 *     `messages`, `composerValue`, `composerKind`,
 *     `composerPartnerDisplayName`, `connectionStatus`,
 *     `newMessagesCount`.
 *
 * Stubs at the boundary
 * ─────────────────────
 * - `@app/api-client-ts` — every SDK function the page / store / realtime
 *   composables touch is `vi.fn()`-replaced. No HTTP.
 * - `centrifuge` — the class-based mock from
 *   `tests/unit/useSessionPresence.spec.ts` (vi.fn() constructors broken in
 *   vitest 4). One shared mock Centrifuge instance per test serves both
 *   subscriptions (chat + presence) — the spec inspects which channel was
 *   subscribed to dispatch events.
 * - `useRuntimeConfig` — global stub returns a synthetic `realtimeWsUrl`.
 *
 * Scenarios
 * ─────────
 *  1. mount — chat panel renders with broadcast tab active, no messages.
 *  2. send — composer submit calls `postChatMessage` and the broadcast tab
 *     shows the message after the realtime echo lands.
 *  3. switch — selecting a whisper tab swaps `activeConversationKey` and
 *     triggers `listChatMessages` with `conversation: <partnerId>`.
 *  4. presence — join event for a partner's membershipId flips that tab's
 *     presence dot to `online`.
 */

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { mount, flushPromises } from '@vue/test-utils';
import { createPinia, setActivePinia } from 'pinia';
import { computed, defineComponent, h, onBeforeUnmount, onMounted, ref, watch } from 'vue';

// ── 1. Global stubs ──────────────────────────────────────────────────────────

vi.stubGlobal('useRuntimeConfig', () => ({
  public: { realtimeWsUrl: 'ws://test/centrifugo' },
}));

// ── 2. SDK mock ──────────────────────────────────────────────────────────────

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
  issueRealtimeToken: vi.fn(),
}));

import {
  listChatConversations,
  listChatMessages,
  postChatMessage,
  listBlocks,
  issueRealtimeToken,
} from '@app/api-client-ts';

// ── 3. Centrifuge mock ───────────────────────────────────────────────────────
//
// Both `useSessionChatRealtime` and `useSessionPresence` `new Centrifuge(...)`.
// To keep the spec readable we share a single mock Centrifuge instance and
// store per-channel subscription handles in a map keyed by channel name. Each
// subscription captures its event listeners and exposes them via `_fire(...)`.

interface MockSubHandlers {
  subscribing?: () => void;
  subscribed?: () => void;
  unsubscribed?: (ctx: { code: number; reason?: string }) => void;
  publication?: (ctx: { data: unknown }) => void;
  join?: (ctx: unknown) => void;
  leave?: (ctx: unknown) => void;
}

interface MockSubscription {
  channel: string;
  handlers: MockSubHandlers;
  on: ReturnType<typeof vi.fn>;
  once: ReturnType<typeof vi.fn>;
  subscribe: ReturnType<typeof vi.fn>;
  unsubscribe: ReturnType<typeof vi.fn>;
  presence: ReturnType<typeof vi.fn>;
  _fire: (event: keyof MockSubHandlers, payload?: unknown) => void;
}

const subs = new Map<string, MockSubscription>();
let presenceResolvers = new Map<string, (snapshot: unknown) => void>();

function makeSub(channel: string): MockSubscription {
  const handlers: MockSubHandlers = {};
  const sub: MockSubscription = {
    channel,
    handlers,
    on: vi.fn((event: keyof MockSubHandlers, fn: (...args: unknown[]) => void) => {
      handlers[event] = fn as never;
      return sub;
    }),
    once: vi.fn((event: keyof MockSubHandlers, fn: (...args: unknown[]) => void) => {
      handlers[event] = fn as never;
      return sub;
    }),
    subscribe: vi.fn(),
    unsubscribe: vi.fn(),
    presence: vi.fn(
      () =>
        new Promise((resolve) => {
          presenceResolvers.set(channel, resolve as (s: unknown) => void);
        }),
    ),
    _fire(event, payload) {
      const fn = handlers[event] as ((p?: unknown) => void) | undefined;
      fn?.(payload);
    },
  };
  return sub;
}

const mockCentrifuge = {
  on: vi.fn(),
  newSubscription: vi.fn((channel: string) => {
    const existing = subs.get(channel);
    if (existing) return existing;
    const sub = makeSub(channel);
    subs.set(channel, sub);
    return sub;
  }),
  connect: vi.fn(),
  disconnect: vi.fn(),
};

vi.mock('centrifuge', () => ({
  // vitest 4: `vi.fn(() => obj)` does NOT honour `new`; use a class that
  // returns the singleton mock instance. Same shape as the proven mock in
  // `apps/web/tests/unit/useSessionPresence.spec.ts`.
  Centrifuge:
    // eslint-disable-next-line @typescript-eslint/no-extraneous-class -- constructor-only class is required because Vitest 4 `vi.fn()` does not honour `new`; this is the documented mock shape for Centrifuge across the suite.
    class {
      constructor() {
        return mockCentrifuge as never;
      }
    },
}));

// ── 4. Imports under test (must come after vi.mock calls) ────────────────────

import { useChatStore } from '~/stores/chat';
import { useSessionChatRealtime } from '~/composables/useSessionChatRealtime';
import { useSessionPresence } from '~/composables/useSessionPresence';
import {
  AppChatPanel,
  type AppChatPanelRow,
  type ChatTabModel,
  type WhisperPickerMember,
} from '@app/ui';

// ── 5. Fixtures ──────────────────────────────────────────────────────────────

const SESSION_ID = 'sess-abc';
const GM_MEMBER_ID = 'mem-gm';
const PLAYER_MEMBER_ID = 'mem-player';

function broadcastSummary() {
  return {
    conversationKey: 'broadcast',
    kind: 'broadcast' as const,
    partnerMembershipId: null,
    partnerDisplayName: null,
    partnerCharacterName: null,
    lastMessageAt: null,
    unreadCount: 0,
  };
}

function whisperSummary() {
  return {
    conversationKey: PLAYER_MEMBER_ID,
    kind: 'whisper' as const,
    partnerMembershipId: PLAYER_MEMBER_ID,
    partnerDisplayName: 'Sahar',
    partnerCharacterName: null,
    lastMessageAt: null,
    unreadCount: 0,
  };
}

function makeMessage(overrides: Partial<{ id: string; body: string; target: string | null }> = {}) {
  return {
    id: overrides.id ?? 'msg-1',
    gameSessionId: SESSION_ID,
    authorMembershipId: GM_MEMBER_ID,
    authorDisplayName: 'GM',
    targetMembershipId: overrides.target ?? null,
    kind: 'text' as const,
    body: overrides.body ?? 'Hello, crew.',
    createdAt: '2026-05-19T10:00:00.000Z',
    editedAt: null,
    deletedAt: null,
  };
}

// ── 6. Harness component ─────────────────────────────────────────────────────
//
// Recreates the chat-surface composition from
// `apps/web/app/pages/app/game-sessions/[id].vue` without the Nuxt-only
// scaffolding (layouts, NuxtLink, i18n inline block, page middleware, etc.).
// The bindings/event wiring around AppChatPanel match the page 1:1.

const HarnessPage = defineComponent({
  name: 'HarnessPage',
  components: { AppChatPanel },
  setup() {
    const chatStore = useChatStore();
    const sessionId = ref(SESSION_ID);
    const myMembershipId = ref(GM_MEMBER_ID);

    const chatRealtime = useSessionChatRealtime({
      gameSessionId: sessionId,
      myMembershipId,
    });
    const presence = useSessionPresence(SESSION_ID);

    // Same wiring as the page — chat realtime events flow into the store.
    watch(chatRealtime.lastPosted, (m) => {
      if (m) chatStore.applyRealtime({ type: 'chat.message.posted', message: m as never });
    });

    onMounted(async () => {
      await chatStore.hydrate({
        gameSessionId: SESSION_ID,
        myMembershipId: GM_MEMBER_ID,
      });
      await chatRealtime.start();
      void presence.start();
    });

    onBeforeUnmount(() => {
      chatRealtime.stop();
      presence.stop();
    });

    // Same `chatPanelBindings` shape as the page (id].vue:227-249).
    const tabs = computed<ChatTabModel[]>(() =>
      chatStore.panelTabs.map((tab) => {
        const dot: 'online' | 'offline' | undefined =
          tab.kind === 'whisper'
            ? presence.onlineSet.value.has(tab.key)
              ? 'online'
              : 'offline'
            : undefined;
        return { ...tab, presence: dot };
      }),
    );

    const messages = computed<AppChatPanelRow[]>(() =>
      chatStore.activeMessages.map((m) => ({
        id: m.id,
        variant: m.targetMembershipId
          ? ('whisper' as const)
          : m.authorMembershipId === GM_MEMBER_ID
            ? ('broadcast-author' as const)
            : ('broadcast-other' as const),
        payload: {
          variant: m.targetMembershipId
            ? ('whisper' as const)
            : m.authorMembershipId === GM_MEMBER_ID
              ? ('broadcast-author' as const)
              : ('broadcast-other' as const),
          authorDisplayName: m.authorDisplayName ?? undefined,
          authorAvatarSrc: null,
          authorPresence: 'offline' as const,
          body: m.body ?? null,
          createdAtIso: m.createdAt,
          editedAtIso: m.editedAt ?? null,
          deletedAtIso: m.deletedAt ?? null,
          ownByMe: m.authorMembershipId === GM_MEMBER_ID,
          ownByGm: true,
          canEdit: false,
          canDelete: false,
          canBlock: false,
        },
      })),
    );

    const activeConv = computed(() => chatStore.conversations[chatStore.activeConversationKey]);
    const composerValue = computed(() => activeConv.value?.composerValue ?? '');

    function onComposerUpdate(v: string): void {
      const conv = chatStore.conversations[chatStore.activeConversationKey];
      if (conv) conv.composerValue = v;
    }

    async function onComposerSubmit(): Promise<void> {
      const body = composerValue.value.trim();
      if (!body) return;
      const key = chatStore.activeConversationKey;
      const conv = chatStore.conversations[key];
      if (conv) conv.composerValue = '';
      await chatStore.send(key, body);
    }

    // Pickable members so the whisper picker has something to render if a
    // test opens one. Used only for shape parity with the page.
    const pickable = computed<WhisperPickerMember[]>(() => [
      {
        membershipId: PLAYER_MEMBER_ID,
        displayName: 'Sahar',
        characterName: null,
        presence: presence.onlineSet.value.has(PLAYER_MEMBER_ID) ? 'online' : 'offline',
        blockedByMe: false,
      },
    ]);

    return {
      chatStore,
      tabs,
      messages,
      composerValue,
      composerKind: computed(() =>
        chatStore.activeConversationKey === 'broadcast'
          ? ('broadcast' as const)
          : ('whisper' as const),
      ),
      composerPartnerDisplayName: computed(() => {
        if (chatStore.activeConversationKey === 'broadcast') return undefined;
        return (
          chatStore.conversationsList.find(
            (c) => c.conversationKey === chatStore.activeConversationKey,
          )?.partnerDisplayName ?? undefined
        );
      }),
      pickable,
      onComposerUpdate,
      onComposerSubmit,
      chatRealtime,
      presence,
      connectionStatus: chatRealtime.status,
    };
  },
  render() {
    return h(AppChatPanel, {
      mode: 'docked',
      connectionStatus: this.connectionStatus,
      tabs: this.tabs,
      activeKey: this.chatStore.activeConversationKey,
      messages: this.messages,
      composerValue: this.composerValue,
      composerKind: this.composerKind,
      composerPartnerDisplayName: this.composerPartnerDisplayName,
      composerDisabled: this.connectionStatus === 'unrecoverable',
      newMessagesCount: this.chatStore.activeNewMessagesCount,
      'onUpdate:composer-value': this.onComposerUpdate,
      onSubmit: this.onComposerSubmit,
      'onSelect-tab': (k: string) => this.chatStore.setActiveConversationKey(k),
    });
  },
});

// ── 7. Helpers ───────────────────────────────────────────────────────────────

/**
 * Bring all four subscriptions to `subscribed` so `start()` resolves:
 *   - session.<id>.chat        (chat broadcast)
 *   - session.<id>.member.<id> (whisper inbox)
 *   - session.<id>             (presence)
 * Presence `presence()` is then resolved with an empty snapshot.
 */
async function settleSubscriptions(snapshotClients: Record<string, unknown> = {}): Promise<void> {
  // Drain microtasks until subscriptions are created by `start()` calls.
  await flushPromises();

  const chatChannel = `session.${SESSION_ID}.chat`;
  const memberChannel = `session.${SESSION_ID}.member.${GM_MEMBER_ID}`;
  const presenceChannel = `session.${SESSION_ID}`;

  subs.get(chatChannel)?._fire('subscribed');
  subs.get(memberChannel)?._fire('subscribed');
  subs.get(presenceChannel)?._fire('subscribed');

  await flushPromises();

  // Presence composable's async IIFE calls `sub.presence()` after subscribed.
  const resolver = presenceResolvers.get(presenceChannel);
  resolver?.({ clients: snapshotClients });

  await flushPromises();
}

function makePresenceClient(clientId: string, membershipId: string) {
  return {
    client: clientId,
    user: 'user-x',
    connInfo: {
      memberships: [{ gameSessionId: SESSION_ID, membershipId }],
    },
  };
}

// ── 8. Lifecycle ─────────────────────────────────────────────────────────────

beforeEach(() => {
  setActivePinia(createPinia());

  subs.clear();
  presenceResolvers = new Map();
  mockCentrifuge.on.mockClear();
  mockCentrifuge.newSubscription.mockClear();
  mockCentrifuge.connect.mockClear();
  mockCentrifuge.disconnect.mockClear();

  vi.mocked(issueRealtimeToken).mockResolvedValue({
    data: { token: 'test-token' },
    error: undefined,
  } as never);
  vi.mocked(listChatConversations).mockResolvedValue({
    data: { items: [broadcastSummary(), whisperSummary()] },
    error: null,
  } as never);
  vi.mocked(listBlocks).mockResolvedValue({ data: { items: [] }, error: null } as never);
  vi.mocked(listChatMessages).mockResolvedValue({
    data: { items: [], nextCursor: null },
    error: null,
  } as never);
  vi.mocked(postChatMessage).mockResolvedValue({
    data: makeMessage({ id: 'srv-1' }),
    error: null,
  } as never);
});

afterEach(() => {
  vi.clearAllMocks();
});

// ── 9. Scenarios ─────────────────────────────────────────────────────────────

describe('game-session page — chat surface integration', () => {
  it('mounts and renders the broadcast tab with no messages by default', async () => {
    const wrapper = mount(HarnessPage, { attachTo: document.body });

    // Wait for hydrate + start.
    await settleSubscriptions();
    await flushPromises();

    expect(wrapper.find('[data-testid="app-chat-panel"]').exists()).toBe(true);

    // Broadcast tab is in the DOM and active.
    const broadcastTab = wrapper.find('button[role="tab"][aria-label="Everyone"]');
    expect(broadcastTab.exists()).toBe(true);
    expect(broadcastTab.attributes('aria-selected')).toBe('true');

    // No rendered message rows (each row would be an AppChatMessage child).
    expect(wrapper.findAll('[data-testid^="app-chat-message"]').length).toBe(0);

    wrapper.unmount();
  });

  it('submits a broadcast message via the SDK and renders it after the realtime echo', async () => {
    const wrapper = mount(HarnessPage, { attachTo: document.body });
    await settleSubscriptions();
    await flushPromises();

    // Drive the composer the same way the page does: update model -> submit.
    const composer = wrapper.findComponent({ name: 'AppChatComposer' });
    expect(composer.exists()).toBe(true);
    await composer.vm.$emit('update:modelValue', 'Beware the Dark.');
    await composer.vm.$emit('submit');

    // Awaiting microtasks lets the store's async `send()` resolve through
    // the mocked SDK promise.
    await flushPromises();

    expect(vi.mocked(postChatMessage)).toHaveBeenCalledOnce();
    const sendCall = vi.mocked(postChatMessage).mock.calls[0]?.[0];
    expect(sendCall?.path?.id).toBe(SESSION_ID);
    expect(sendCall?.body?.body).toBe('Beware the Dark.');
    expect(sendCall?.body?.targetMembershipId).toBeNull();

    // Simulate the realtime echo arriving via the chat broadcast channel.
    const chatSub = subs.get(`session.${SESSION_ID}.chat`);
    expect(chatSub).toBeTruthy();
    chatSub?._fire('publication', {
      data: makeMessage({ id: 'srv-1', body: 'Beware the Dark.' }),
    });

    await flushPromises();

    // The message renders in the broadcast tab.
    const rendered = wrapper.find('[data-testid="app-chat-message"]');
    expect(rendered.exists()).toBe(true);
    expect(wrapper.text()).toContain('Beware the Dark.');

    wrapper.unmount();
  });

  it('switching to a whisper tab swaps activeConversationKey and re-fetches messages for the partner', async () => {
    const wrapper = mount(HarnessPage, { attachTo: document.body });
    await settleSubscriptions();
    await flushPromises();

    // First call: hydrate loads broadcast messages.
    expect(vi.mocked(listChatMessages)).toHaveBeenCalledTimes(1);
    expect(vi.mocked(listChatMessages).mock.calls[0]?.[0]?.query?.conversation).toBe('broadcast');

    // Pre-stub the whisper fetch with a partner message so we can assert it
    // makes it into the rendered list.
    vi.mocked(listChatMessages).mockResolvedValueOnce({
      data: {
        items: [
          makeMessage({
            id: 'wsp-1',
            target: PLAYER_MEMBER_ID,
            body: 'A whisper for the GM.',
          }),
        ],
        nextCursor: null,
      },
      error: null,
    } as never);

    // The page wires AppChatPanel @select-tab → chatStore.openWhisper for a
    // previously-unopened key. We call the store action directly — same code
    // path the page uses — because `openWhisper` is the action the page maps
    // to in its `@select-tab` -> tab-strip-add flow. (See
    // `apps/web/app/pages/app/game-sessions/[id].vue:367-370`.)
    const harness = wrapper.vm as unknown as { chatStore: ReturnType<typeof useChatStore> };
    await harness.chatStore.openWhisper(PLAYER_MEMBER_ID);
    await flushPromises();

    expect(harness.chatStore.activeConversationKey).toBe(PLAYER_MEMBER_ID);

    // Second listChatMessages call — for the whisper conversation.
    expect(vi.mocked(listChatMessages)).toHaveBeenCalledTimes(2);
    const whisperCall = vi.mocked(listChatMessages).mock.calls[1]?.[0];
    expect(whisperCall?.query?.conversation).toBe(PLAYER_MEMBER_ID);

    // The whisper message now renders in the active tab.
    expect(wrapper.text()).toContain('A whisper for the GM.');

    wrapper.unmount();
  });

  it('flips the whisper tab presence dot to online when the partner joins via Centrifugo', async () => {
    const wrapper = mount(HarnessPage, { attachTo: document.body });
    await settleSubscriptions();
    await flushPromises();

    // Open the whisper tab so it appears in the tab strip.
    const harness = wrapper.vm as unknown as { chatStore: ReturnType<typeof useChatStore> };
    await harness.chatStore.openWhisper(PLAYER_MEMBER_ID);
    await flushPromises();

    const presenceSub = subs.get(`session.${SESSION_ID}`);
    expect(presenceSub).toBeTruthy();

    // Initially offline.
    let whisperTab = wrapper.find('button[role="tab"][aria-label="Sahar"]');
    expect(whisperTab.exists()).toBe(true);
    let dot = whisperTab.find('[data-testid="app-chat-presence-dot"]');
    expect(dot.exists()).toBe(true);
    expect(dot.attributes('aria-label')).toBe('offline');

    // Fire a join event for the partner's membership.
    presenceSub?._fire('join', {
      channel: `session.${SESSION_ID}`,
      info: makePresenceClient('client-sahar', PLAYER_MEMBER_ID),
    });

    await flushPromises();

    whisperTab = wrapper.find('button[role="tab"][aria-label="Sahar"]');
    dot = whisperTab.find('[data-testid="app-chat-presence-dot"]');
    expect(dot.attributes('aria-label')).toBe('online');

    wrapper.unmount();
  });
});
