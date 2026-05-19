/**
 * useChatStore — Pinia store owning all chat conversation state for a
 * game session (Phase 8 Stream D, Block 7).
 *
 * Responsibilities:
 *   - Hydrate conversation list + block list + initial broadcast messages.
 *   - Track per-conversation message history, cursor pagination, optimistic
 *     sends, and scroll position.
 *   - Apply realtime events (posted / edited / deleted) dispatched by
 *     `useSessionChatRealtime`.
 *   - Manage whisper tabs (open / close / active key).
 *   - Block / unblock members.
 *   - Debounced read-cursor updates per conversation.
 *
 * Conventions:
 *   - All HTTP goes through the generated SDK (`@app/api-client-ts`).
 *   - Block functions use `blockMember` / `unblockMember` (the actual SDK
 *     exports — not `postBlock` / `deleteBlock`).
 *   - Debounce is implemented with plain `setTimeout`; no lodash dependency.
 *   - This file has no Vue imports — pure Pinia + SDK.
 */
import { defineStore } from 'pinia';
import {
  listChatMessages,
  postChatMessage,
  editChatMessage,
  deleteChatMessage,
  listChatConversations,
  markChatConversationRead,
  listBlocks,
  blockMember,
  unblockMember,
} from '@app/api-client-ts';
import type { ChatMessage, ChatConversationSummary } from '@app/api-client-ts';

// ─── Internal types ──────────────────────────────────────────────────────────

interface ConversationState {
  /** Messages in chronological order — newest at the end. */
  messages: ChatMessage[];
  /** Cursor for the next `loadOlder` call; null = no more history. */
  nextCursor: string | null;
  /** True after the first page has been fetched for this conversation. */
  hasLoadedInitial: boolean;
  /**
   * Optimistic message ids currently in flight. On server success, the
   * realtime echo delivers the canonical row and we remove the synthetic.
   * On error, we roll back.
   */
  pendingSendIds: Set<string>;
  /** Draft body preserved while the composer is open. */
  composerValue: string;
  /** True when the scroll container is pinned to the bottom. */
  isAtBottom: boolean;
  /** Unread messages received while `isAtBottom === false`. */
  newMessagesCount: number;
}

interface ChatState {
  gameSessionId: string | null;
  myMembershipId: string | null;
  /** 'broadcast' | membershipId of the whisper partner */
  activeConversationKey: string;
  conversations: Partial<Record<string, ConversationState>>;
  conversationsList: ChatConversationSummary[];
  /** MembershipIds of open whisper tabs (order = tab order). */
  openWhisperKeys: string[];
  /** MembershipIds of members blocked by me in this session. */
  blockedByMe: Set<string>;
  initialized: boolean;
  lastError: string | null;
}

// ─── Public model consumed by the UI ─────────────────────────────────────────

export interface ChatTabModel {
  /** 'broadcast' or a membershipId */
  key: string;
  /** Display label shown in the tab strip. */
  label: string;
  /** Tab kind — drives icon / styling. */
  kind: 'broadcast' | 'whisper';
  /** Unread message count from the conversation summary. */
  unreadCount: number;
  /**
   * Live presence indicator for whisper tabs. Mirrors the same field on
   * `@app/ui`'s `ChatTabModel` (packages/ui/src/components/AppChatTabStrip/types.ts).
   * Not set by the store itself — injected by the page layer after merging
   * with the online set from `useSessionPresence`.
   */
  presence?: 'online' | 'idle' | 'offline';
}

// ─── Realtime event shape (discriminated union) ───────────────────────────────

export interface RealtimeChatPosted {
  type: 'chat.message.posted';
  message: ChatMessage;
}

export interface RealtimeChatEdited {
  type: 'chat.message.edited';
  message: ChatMessage;
}

export interface RealtimeChatDeleted {
  type: 'chat.message.deleted';
  id: string;
  gameSessionId: string;
  authorMembershipId: string | null;
  targetMembershipId: string | null;
}

export type RealtimeChatEvent = RealtimeChatPosted | RealtimeChatEdited | RealtimeChatDeleted;

// ─── Debounce helpers ────────────────────────────────────────────────────────

type DebouncedMarkRead = (lastReadAt: string) => void;

/** Module-level map so debouncers survive Pinia action calls. */
const markReadDebouncers = new Map<
  string,
  { fn: DebouncedMarkRead; timer: ReturnType<typeof setTimeout> | null }
>();

function getMarkReadDebouncer(
  conversationKey: string,
  impl: (lastReadAt: string) => void,
): DebouncedMarkRead {
  if (!markReadDebouncers.has(conversationKey)) {
    let timer: ReturnType<typeof setTimeout> | null = null;
    let pending: string | null = null;

    const fn: DebouncedMarkRead = (lastReadAt: string) => {
      pending = lastReadAt;
      if (timer !== null) clearTimeout(timer);
      timer = setTimeout(() => {
        timer = null;
        if (pending !== null) {
          impl(pending);
          pending = null;
        }
      }, 2000);
    };

    markReadDebouncers.set(conversationKey, { fn, timer: null });
    return fn;
  }
  const existing = markReadDebouncers.get(conversationKey);
  if (!existing) throw new Error('Debouncer missing after set — unreachable');
  return existing.fn;
}

// ─── Default conversation state factory ──────────────────────────────────────

function makeConversation(): ConversationState {
  return {
    messages: [],
    nextCursor: null,
    hasLoadedInitial: false,
    pendingSendIds: new Set(),
    composerValue: '',
    isAtBottom: true,
    newMessagesCount: 0,
  };
}

// ─── Store ───────────────────────────────────────────────────────────────────

export const useChatStore = defineStore('chat', {
  state: (): ChatState => ({
    gameSessionId: null,
    myMembershipId: null,
    activeConversationKey: 'broadcast',
    conversations: {},
    conversationsList: [],
    openWhisperKeys: [],
    blockedByMe: new Set(),
    initialized: false,
    lastError: null,
  }),

  getters: {
    /** Messages for the currently active conversation (chronological). */
    activeMessages(state): ChatMessage[] {
      return state.conversations[state.activeConversationKey]?.messages ?? [];
    },

    /** Unread count for the currently active conversation. */
    activeNewMessagesCount(state): number {
      return state.conversations[state.activeConversationKey]?.newMessagesCount ?? 0;
    },

    /**
     * Tab model list for the chat panel.
     *
     * Broadcast is always first; open whisper tabs follow in open order.
     * Partner display names are resolved from `conversationsList`.
     */
    panelTabs(state): ChatTabModel[] {
      const summaryMap = new Map<string, ChatConversationSummary>(
        state.conversationsList.map((s) => [s.conversationKey, s]),
      );

      const broadcastSummary = summaryMap.get('broadcast');
      const tabs: ChatTabModel[] = [
        {
          key: 'broadcast',
          label: 'Everyone',
          kind: 'broadcast',
          unreadCount: broadcastSummary?.unreadCount ?? 0,
        },
      ];

      for (const key of state.openWhisperKeys) {
        const summary = summaryMap.get(key);
        tabs.push({
          key,
          label: summary?.partnerDisplayName ?? summary?.partnerCharacterName ?? key,
          kind: 'whisper',
          unreadCount: summary?.unreadCount ?? 0,
        });
      }

      return tabs;
    },
  },

  actions: {
    // ── Hydration ──────────────────────────────────────────────────────────

    /**
     * Initialise the store for a session.
     *
     * Fetches conversation list + block list in parallel, then fetches the
     * initial page of broadcast messages.
     */
    async hydrate(opts: { gameSessionId: string; myMembershipId: string }): Promise<void> {
      this.gameSessionId = opts.gameSessionId;
      this.myMembershipId = opts.myMembershipId;
      this.lastError = null;

      const [convRes, blockRes] = await Promise.all([
        listChatConversations({ path: { id: opts.gameSessionId } }),
        listBlocks({ path: { id: opts.gameSessionId } }),
      ]);

      if (convRes.error) {
        this.lastError = 'Failed to load conversations';
        return;
      }
      if (blockRes.error) {
        this.lastError = 'Failed to load block list';
        return;
      }

      this.conversationsList = convRes.data.items;
      this.blockedByMe = new Set(blockRes.data.items.map((b) => b.targetMembershipId));

      // Seed the broadcast conversation.
      this.conversations.broadcast ??= makeConversation();
      const msgRes = await listChatMessages({
        path: { id: opts.gameSessionId },
        query: { conversation: 'broadcast' },
      });
      if (!msgRes.error) {
        const conv = this.conversations.broadcast;
        conv.messages = msgRes.data.items.toReversed();
        conv.nextCursor = msgRes.data.nextCursor;
        conv.hasLoadedInitial = true;
      }

      this.initialized = true;
    },

    // ── Pagination ──────────────────────────────────────────────────────────

    /** Load older messages for a conversation (cursor pagination). */
    async loadOlder(conversationKey: string): Promise<void> {
      const conv = this.conversations[conversationKey];
      if (conv?.nextCursor == null) return;
      if (!this.gameSessionId) return;

      const res = await listChatMessages({
        path: { id: this.gameSessionId },
        query: { conversation: conversationKey, cursor: conv.nextCursor },
      });
      if (res.error) {
        this.lastError = 'Failed to load older messages';
        return;
      }

      // Prepend (older messages go at the front).
      conv.messages = [...res.data.items.toReversed(), ...conv.messages];
      conv.nextCursor = res.data.nextCursor;
    },

    // ── Send / edit / delete ───────────────────────────────────────────────

    /** Post a message with optimistic UI. */
    async send(conversationKey: string, body: string): Promise<void> {
      if (!this.gameSessionId || !this.myMembershipId) return;

      this.conversations[conversationKey] ??= makeConversation();
      const conv = this.conversations[conversationKey];

      // Optimistic message.
      const pendingId = `pending_${Date.now().toString()}_${Math.random().toString(36).slice(2)}`;
      const optimistic: ChatMessage = {
        id: pendingId,
        gameSessionId: this.gameSessionId,
        authorMembershipId: this.myMembershipId,
        authorDisplayName: null,
        targetMembershipId: conversationKey === 'broadcast' ? null : conversationKey,
        kind: 'text',
        body,
        createdAt: new Date().toISOString(),
        editedAt: null,
        deletedAt: null,
      };
      conv.messages.push(optimistic);
      conv.pendingSendIds.add(pendingId);

      const res = await postChatMessage({
        path: { id: this.gameSessionId },
        body: {
          kind: 'text',
          body,
          targetMembershipId: conversationKey === 'broadcast' ? null : conversationKey,
        },
      });

      if (res.error) {
        // Roll back optimistic.
        conv.messages = conv.messages.filter((m) => m.id !== pendingId);
        conv.pendingSendIds.delete(pendingId);
        this.lastError = 'Failed to send message';
        return;
      }

      // The realtime echo will append the canonical row. Remove the pending
      // marker so `applyRealtime` doesn't double-insert.
      conv.pendingSendIds.delete(pendingId);
      // Remove the synthetic optimistic row — the echo will bring the real one.
      conv.messages = conv.messages.filter((m) => m.id !== pendingId);
    },

    /** Edit a message body. The realtime echo will update the row. */
    async edit(messageId: string, body: string): Promise<void> {
      const res = await editChatMessage({
        path: { id: messageId },
        body: { body },
      });
      if (res.error) {
        this.lastError = 'Failed to edit message';
      }
    },

    /** Soft-delete a message. The realtime echo will flip `deletedAt`. */
    async delete(messageId: string): Promise<void> {
      const res = await deleteChatMessage({ path: { id: messageId } });
      if (res.error) {
        this.lastError = 'Failed to delete message';
      }
    },

    // ── Read cursors ────────────────────────────────────────────────────────

    /**
     * Update the read cursor for a conversation.
     *
     * Calls are debounced at 2 s per conversation key — a `Map` of
     * per-key debouncers lives at module level so they are not torn down
     * between action invocations.
     */
    markRead(conversationKey: string, lastReadAt: string): void {
      if (!this.gameSessionId) return;
      const gameSessionId = this.gameSessionId;

      const debounced = getMarkReadDebouncer(conversationKey, (ts: string) => {
        void markChatConversationRead({
          path: { id: gameSessionId, conversationKey },
          body: { lastReadAt: ts },
        });
      });
      debounced(lastReadAt);
    },

    // ── Block / unblock ────────────────────────────────────────────────────

    /** Block a member. Removes the whisper tab and conversation summary. */
    async block(targetMembershipId: string): Promise<void> {
      if (!this.gameSessionId) return;
      const res = await blockMember({
        path: { id: this.gameSessionId },
        body: { targetMembershipId },
      });
      if (res.error) {
        this.lastError = 'Failed to block member';
        return;
      }
      this.blockedByMe.add(targetMembershipId);
      this.conversationsList = this.conversationsList.filter(
        (c) => c.partnerMembershipId !== targetMembershipId,
      );
      this.closeWhisper(targetMembershipId);
    },

    /** Unblock a member. */
    async unblock(targetMembershipId: string): Promise<void> {
      if (!this.gameSessionId) return;
      const res = await unblockMember({
        path: { id: this.gameSessionId, targetMembershipId },
      });
      if (res.error) {
        this.lastError = 'Failed to unblock member';
        return;
      }
      this.blockedByMe.delete(targetMembershipId);
    },

    // ── Whisper tabs ────────────────────────────────────────────────────────

    /**
     * Open a whisper conversation.
     *
     * Lazy-hydrates message history if not yet loaded.
     */
    async openWhisper(membershipId: string): Promise<void> {
      if (!this.openWhisperKeys.includes(membershipId)) {
        this.openWhisperKeys.push(membershipId);
      }
      this.activeConversationKey = membershipId;

      this.conversations[membershipId] ??= makeConversation();

      const conv = this.conversations[membershipId];
      if (!conv.hasLoadedInitial && this.gameSessionId) {
        const res = await listChatMessages({
          path: { id: this.gameSessionId },
          query: { conversation: membershipId },
        });
        if (!res.error) {
          conv.messages = res.data.items.toReversed();
          conv.nextCursor = res.data.nextCursor;
          conv.hasLoadedInitial = true;
        }
      }
    },

    /**
     * Close a whisper tab.
     *
     * History is kept in `conversations` cache — it is NOT dropped.
     * Falls back to broadcast if the closed tab was active.
     */
    closeWhisper(membershipId: string): void {
      this.openWhisperKeys = this.openWhisperKeys.filter((k) => k !== membershipId);
      if (this.activeConversationKey === membershipId) {
        this.activeConversationKey = 'broadcast';
      }
    },

    // ── Active conversation ────────────────────────────────────────────────

    /** Switch the active tab and reset its unread counter. */
    setActiveConversationKey(key: string): void {
      this.activeConversationKey = key;
      const conv = this.conversations[key];
      if (conv) conv.newMessagesCount = 0;
    },

    // ── Scroll state ────────────────────────────────────────────────────────

    /** Called by the scroll container when pinned to the bottom. */
    markAsAtBottom(conversationKey: string): void {
      const conv = this.conversations[conversationKey];
      if (!conv) return;
      conv.isAtBottom = true;
      conv.newMessagesCount = 0;
    },

    /** Called by the scroll container when the user has scrolled up. */
    markAsScrolledAway(conversationKey: string): void {
      const conv = this.conversations[conversationKey];
      if (!conv) return;
      conv.isAtBottom = false;
    },

    // ── Realtime ─────────────────────────────────────────────────────────

    /**
     * Integrate a realtime event from `useSessionChatRealtime`.
     *
     * Routing logic:
     *   - `posted`: conversation key = `broadcast` when
     *     `targetMembershipId === null`, else the membership id that is NOT
     *     me (i.e. the whisper partner).
     *   - `edited`: find by id across all conversations.
     *   - `deleted`: find by id across all conversations, stamp `deletedAt`.
     */
    applyRealtime(event: RealtimeChatEvent): void {
      switch (event.type) {
        case 'chat.message.posted': {
          const msg = event.message;
          let convKey: string;

          if (msg.targetMembershipId === null) {
            convKey = 'broadcast';
          } else {
            // Whisper — pick the partner side (not my own membershipId).
            convKey =
              msg.authorMembershipId === this.myMembershipId
                ? msg.targetMembershipId
                : (msg.authorMembershipId ?? msg.targetMembershipId);
          }

          // Auto-open whisper tab if new.
          if (convKey !== 'broadcast' && !this.openWhisperKeys.includes(convKey)) {
            this.openWhisperKeys.push(convKey);
          }

          this.conversations[convKey] ??= makeConversation();
          const postedConv = this.conversations[convKey];
          if (postedConv) {
            postedConv.messages.push(msg);
            if (!postedConv.isAtBottom) {
              postedConv.newMessagesCount += 1;
            }
          }
          break;
        }

        case 'chat.message.edited': {
          const msg = event.message;
          for (const conv of Object.values(this.conversations)) {
            if (!conv) continue;
            const idx = conv.messages.findIndex((m) => m.id === msg.id);
            if (idx !== -1) {
              const existing = conv.messages[idx];
              if (existing) {
                conv.messages[idx] = { ...existing, ...msg };
              }
              break;
            }
          }
          break;
        }

        case 'chat.message.deleted': {
          const { id } = event;
          for (const conv of Object.values(this.conversations)) {
            if (!conv) continue;
            const idx = conv.messages.findIndex((m) => m.id === id);
            if (idx !== -1) {
              const existing = conv.messages[idx];
              if (existing) {
                conv.messages[idx] = {
                  ...existing,
                  deletedAt: new Date().toISOString(),
                };
              }
              break;
            }
          }
          break;
        }

        // No default — union is exhaustive
      }
    },
  },
});
