/**
 * useSessionChatRealtime — Centrifugo subscription wrapper for the two
 * Stream-C chat channel families (Phase 8 Stream D, Block 7).
 *
 * Subscribes to:
 *   - `session.{gameSessionId}.chat`   — broadcast messages for everyone
 *   - `session.{gameSessionId}.member.{myMembershipId}` — whispers + own
 *
 * Lifecycle:
 *   1. `start()` mints a fresh JWT via POST /api/v1/realtime/token, opens
 *      the websocket, and subscribes to both channels. Resolves once both
 *      subscriptions reach the `subscribed` state (or rejects on error).
 *   2. `stop()` unsubscribes both channels and closes the socket. Always
 *      idempotent — safe to call from `onUnmounted` even if `start()` was
 *      never called or failed.
 *
 * Token refresh: the `getToken` callback re-mints via `fetchRealtimeToken`
 * without re-entering the connection lifecycle — Centrifuge calls it
 * automatically before the current token expires.
 *
 * Status reflects the worst state across both subscriptions:
 *   `unrecoverable > disconnected > connecting > subscribed`
 *
 * Payload discrimination: the AsyncAPI spec publishes three message types
 * on each chat channel — `ChatMessagePosted`, `ChatMessageEdited`,
 * `ChatMessageDeleted`. Because Centrifugo does not echo the message name
 * into `ctx.data`, we discriminate structurally:
 *   - `ChatMessageDeleted` has the shape `{id, gameSessionId, deletedAt}`
 *     (no `kind` / `body` fields present in channels.ts).
 *   - `ChatMessage` (posted vs edited) is distinguished by whether
 *     `editedAt` is a non-null string — an `editedAt` present → edited.
 */
import { ref, type Ref } from 'vue';
import { Centrifuge, type PublicationContext, type Subscription } from 'centrifuge';
import { issueRealtimeToken } from '@app/api-client-ts';
import type { Problem } from '@app/api-client-ts';
import type {
  RealtimeChatEvent,
  RealtimeChatPosted,
  RealtimeChatEdited,
  RealtimeChatDeleted,
} from '~/stores/chat';

// ─── Internal types ───────────────────────────────────────────────────────────

/** Subset of the channels.ts ChatMessage used for structural detection. */
interface ChatMessagePayload {
  id: string;
  gameSessionId: string;
  authorMembershipId: string | null;
  targetMembershipId: string | null;
  kind: string;
  body?: string | null;
  createdAt: string;
  editedAt?: string | null;
  deletedAt?: string | null;
}

/** Subset of the channels.ts ChatMessageDeleted. */
interface ChatMessageDeletedPayload {
  id: string;
  gameSessionId: string;
  targetMembershipId?: string | null;
  deletedAt: string;
}

type RawChatPayload = ChatMessagePayload | ChatMessageDeletedPayload;

// ─── Sub-status helpers ───────────────────────────────────────────────────────

type SubStatus = 'connecting' | 'subscribed' | 'unrecoverable' | 'disconnected';

const STATUS_RANK: Record<SubStatus, number> = {
  subscribed: 0,
  connecting: 1,
  disconnected: 2,
  unrecoverable: 3,
};

function worstStatus(a: SubStatus, b: SubStatus): SubStatus {
  return STATUS_RANK[a] >= STATUS_RANK[b] ? a : b;
}

// ─── Token helper (mirrors useSessionRealtime.ts) ─────────────────────────────

async function fetchRealtimeToken(): Promise<string> {
  const res = await issueRealtimeToken({ body: undefined });
  if (res.error) {
    const problem = res.error as Problem;
    throw new Error(problem.detail ?? 'Failed to mint realtime token');
  }
  if (!res.data.token) {
    throw new Error('Realtime token endpoint returned an empty token');
  }
  return res.data.token;
}

// ─── Payload discriminators ───────────────────────────────────────────────────

function isDeletedPayload(
  data: Record<string, unknown>,
): data is ChatMessageDeletedPayload & Record<string, unknown> {
  // ChatMessageDeleted has `deletedAt` at the top level and no `kind` field.
  return typeof data.deletedAt === 'string' && !('kind' in data);
}

function discriminate(data: Record<string, unknown>): RealtimeChatEvent | null {
  if (typeof data.id !== 'string') return null;

  if (isDeletedPayload(data)) {
    const event: RealtimeChatDeleted = {
      type: 'chat.message.deleted',
      id: data.id as string,
      gameSessionId: data.gameSessionId as string,
      authorMembershipId: null,
      targetMembershipId:
        typeof data.targetMembershipId === 'string' ? data.targetMembershipId : null,
    };
    return event;
  }

  const msg = data as unknown as ChatMessagePayload;
  if (!msg.kind) return null;

  if (typeof msg.editedAt === 'string') {
    const event: RealtimeChatEdited = {
      type: 'chat.message.edited',
      message: msg as RawChatPayload as never,
    };
    return event;
  }

  const event: RealtimeChatPosted = {
    type: 'chat.message.posted',
    message: msg as RawChatPayload as never,
  };
  return event;
}

// ─── Composable ───────────────────────────────────────────────────────────────

export interface SessionChatRealtimeHandle {
  /** Aggregated worst-case status of the two subscriptions. */
  status: Ref<SubStatus>;
  /** Most recent posted message (null until first publication). */
  lastPosted: Ref<ChatMessagePayload | null>;
  /** Most recent edited message (null until first edition). */
  lastEdited: Ref<ChatMessagePayload | null>;
  /** Most recent deleted event. */
  lastDeleted: Ref<{
    id: string;
    gameSessionId: string;
    authorMembershipId: string | null;
    targetMembershipId: string | null;
  } | null>;
  /** Open the connection and subscribe. Idempotent. */
  start(): Promise<void>;
  /** Unsubscribe and close the socket. Safe to call from onUnmounted. */
  stop(): void;
}

export function useSessionChatRealtime(opts: {
  gameSessionId: Ref<string>;
  myMembershipId: Ref<string>;
}): SessionChatRealtimeHandle {
  const { public: pub } = useRuntimeConfig();
  const wsUrl = pub.realtimeWsUrl as string;

  const status = ref<SubStatus>('disconnected');
  const lastPosted = ref<ChatMessagePayload | null>(null);
  const lastEdited = ref<ChatMessagePayload | null>(null);
  const lastDeleted = ref<{
    id: string;
    gameSessionId: string;
    authorMembershipId: string | null;
    targetMembershipId: string | null;
  } | null>(null);

  let centrifuge: Centrifuge | null = null;
  let subBroadcast: Subscription | null = null;
  let subMember: Subscription | null = null;
  let subBroadcastStatus: SubStatus = 'disconnected';
  let subMemberStatus: SubStatus = 'disconnected';

  function updateStatus(): void {
    status.value = worstStatus(subBroadcastStatus, subMemberStatus);
  }

  function handlePublication(ctx: PublicationContext): void {
    const data = ctx.data as Record<string, unknown> | undefined;
    if (!data || typeof data !== 'object') return;

    const event = discriminate(data);
    if (!event) return;

    switch (event.type) {
      case 'chat.message.posted': {
        lastPosted.value = event.message as unknown as ChatMessagePayload;

        break;
      }
      case 'chat.message.edited': {
        lastEdited.value = event.message as unknown as ChatMessagePayload;

        break;
      }
      case 'chat.message.deleted': {
        lastDeleted.value = {
          id: event.id,
          gameSessionId: event.gameSessionId,
          authorMembershipId: event.authorMembershipId,
          targetMembershipId: event.targetMembershipId,
        };

        break;
      }
      // No default
    }
  }

  function wireSubscription(sub: Subscription, onStatusChange: (s: SubStatus) => void): void {
    sub.on('subscribing', () => {
      onStatusChange('connecting');
      updateStatus();
    });
    sub.on('subscribed', () => {
      onStatusChange('subscribed');
      updateStatus();
    });
    sub.on('unsubscribed', (ctx) => {
      // code 0 = intentional unsubscribe; non-zero = server error
      if (ctx.code !== 0) {
        onStatusChange('unrecoverable');
      } else {
        onStatusChange('disconnected');
      }
      updateStatus();
    });
    sub.on('publication', handlePublication);
  }

  async function start(): Promise<void> {
    if (centrifuge) return;

    try {
      const token = await fetchRealtimeToken();

      centrifuge = new Centrifuge(wsUrl, {
        token,
        getToken: fetchRealtimeToken,
      });

      centrifuge.on('disconnected', (ctx) => {
        if (ctx.code >= 3500) {
          subBroadcastStatus = 'unrecoverable';
          subMemberStatus = 'unrecoverable';
          updateStatus();
        }
      });

      const broadcastChannel = `session.${opts.gameSessionId.value}.chat`;
      const memberChannel = `session.${opts.gameSessionId.value}.member.${opts.myMembershipId.value}`;

      subBroadcast = centrifuge.newSubscription(broadcastChannel);
      subMember = centrifuge.newSubscription(memberChannel);

      wireSubscription(subBroadcast, (s) => {
        subBroadcastStatus = s;
      });
      wireSubscription(subMember, (s) => {
        subMemberStatus = s;
      });

      // Await both subscriptions reaching `subscribed` before resolving.
      // `subBroadcast` and `subMember` are assigned two lines above and are
      // non-null for the remainder of this try block — capture them in locals
      // to avoid the non-null assertion the linter forbids.
      const capBroadcast = subBroadcast;
      const capMember = subMember;

      const broadcastReady = new Promise<void>((resolve, reject) => {
        capBroadcast.once('subscribed', () => {
          resolve();
        });
        capBroadcast.once('unsubscribed', (ctx) => {
          if (ctx.code !== 0) reject(new Error(`Chat channel unsubscribed: ${ctx.reason}`));
          else resolve();
        });
      });
      const memberReady = new Promise<void>((resolve, reject) => {
        capMember.once('subscribed', () => {
          resolve();
        });
        capMember.once('unsubscribed', (ctx) => {
          if (ctx.code !== 0) reject(new Error(`Member channel unsubscribed: ${ctx.reason}`));
          else resolve();
        });
      });

      subBroadcast.subscribe();
      subMember.subscribe();
      centrifuge.connect();

      await Promise.all([broadcastReady, memberReady]);
    } catch (error) {
      status.value = 'unrecoverable';
      if (centrifuge) {
        centrifuge.disconnect();
        centrifuge = null;
      }
      subBroadcast = null;
      subMember = null;
      throw error;
    }
  }

  function stop(): void {
    if (!centrifuge) return;

    subBroadcast?.unsubscribe();
    subMember?.unsubscribe();
    centrifuge.disconnect();
    centrifuge = null;
    subBroadcast = null;
    subMember = null;
    subBroadcastStatus = 'disconnected';
    subMemberStatus = 'disconnected';
    status.value = 'disconnected';
  }

  return { status, lastPosted, lastEdited, lastDeleted, start, stop };
}
