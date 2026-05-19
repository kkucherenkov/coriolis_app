/**
 * useSessionPresence — Centrifugo presence tracking for `session.{gameSessionId}`.
 *
 * Design choice — separate composable vs extending useSessionRealtime:
 *   `useSessionRealtime` already subscribes to `session.{gameSessionId}` for
 *   DP / combat updates but does not expose the underlying `Subscription`
 *   object or call `subscription.presence()`. Extending it to add presence
 *   handling would conflate two orthogonal concerns (domain events vs. presence
 *   bookkeeping) in a single file that is already ~200 lines. A sibling
 *   composable with its own Centrifuge client is a small overhead (one extra
 *   WebSocket connection per page) but keeps both composables focused and
 *   independently testable. The same pattern is already used by
 *   `useSessionChatRealtime`, which opens a third client for the chat
 *   channels. Future work can consolidate all three into a shared client if
 *   connection count becomes a concern.
 *
 * Presence model:
 *   Centrifugo presence is keyed by `client_id` (a UUID minted per connection).
 *   Each `ClientInfo` carries a `connInfo` field whose shape mirrors the JWT
 *   `info` claim emitted by `RealtimeService.issueToken` (AsyncAPI 0.13.0):
 *
 *     { memberships: [{ gameSessionId: string; membershipId: string }] }
 *
 *   A single user may have open tabs on multiple devices — each tab is a
 *   distinct `client_id`. We count a membership as online if at least one
 *   `client_id` with that `membershipId` is present on the channel.
 *
 * Lifecycle:
 *   1. `start()` — mints a fresh JWT, opens a Centrifuge client, subscribes
 *      to `session.{gameSessionId}`, and on `subscribed` calls
 *      `subscription.presence()` to populate the initial snapshot.
 *   2. Subsequent `join` / `leave` events update the set in real time.
 *   3. `stop()` — unsubscribes, disconnects, and clears the reactive set.
 *
 * The composable is idempotent: calling `start()` a second time is a no-op
 * until `stop()` is called.
 */
import { ref, type Ref } from 'vue';
import { Centrifuge, type JoinContext, type LeaveContext } from 'centrifuge';
import { issueRealtimeToken } from '@app/api-client-ts';
import type { Problem } from '@app/api-client-ts';

// ─── Local type — mirrors AsyncAPI 0.13.0 RealtimeConnectInfo schema ─────────
// Do NOT import from `packages/api-client-ts/src/generated/` — the AsyncAPI
// codegen does not emit a TS type for JWT info claims (they document the shape
// but do not appear in generated SDK types).

interface RealtimeMembership {
  gameSessionId: string;
  membershipId: string;
}

export interface RealtimeConnectInfo {
  memberships: RealtimeMembership[];
}

// ─── Guard helpers ────────────────────────────────────────────────────────────

function isRealtimeConnectInfo(v: unknown): v is RealtimeConnectInfo {
  if (!v || typeof v !== 'object') return false;
  const obj = v as Record<string, unknown>;
  if (!Array.isArray(obj.memberships)) return false;
  return obj.memberships.every(
    (m) =>
      m !== null &&
      typeof m === 'object' &&
      typeof (m as Record<string, unknown>).gameSessionId === 'string' &&
      typeof (m as Record<string, unknown>).membershipId === 'string',
  );
}

// ─── Token helper ─────────────────────────────────────────────────────────────

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

// ─── Public handle ────────────────────────────────────────────────────────────

export interface SessionPresenceHandle {
  /**
   * Set of membershipIds that are currently online on this session channel.
   * A membership is online if ≥1 client_id with that membershipId is present.
   */
  onlineSet: Ref<ReadonlySet<string>>;
  /** Last error (token mint, server reject). Null when healthy. */
  error: Ref<string | null>;
  /** Open the connection and subscribe. Idempotent until stop() is called. */
  start(): Promise<void>;
  /** Unsubscribe and close the connection. Clears onlineSet. */
  stop(): void;
}

// ─── Composable ───────────────────────────────────────────────────────────────

export function useSessionPresence(gameSessionId: string): SessionPresenceHandle {
  const { public: pub } = useRuntimeConfig();
  const wsUrl = pub.realtimeWsUrl as string;

  /**
   * client_id → membershipId map for the current session channel.
   * Presence is keyed by client_id; multiple client_ids may map to the same
   * membershipId (same user on phone + laptop). The Set is derived from this
   * map on every mutation — we never expose the map directly.
   */
  const clientToMembership = new Map<string, string>();

  const _onlineSet = ref<Set<string>>(new Set<string>());
  // Expose as ReadonlySet — mutability is internal only.
  const onlineSet = _onlineSet as Ref<ReadonlySet<string>>;
  const error = ref<string | null>(null);

  let centrifuge: Centrifuge | null = null;

  function rebuildSet(): void {
    _onlineSet.value = new Set(clientToMembership.values());
  }

  /**
   * Extract a membershipId from a ClientInfo.connInfo for the current
   * gameSessionId. Returns null if the connInfo is malformed or does not
   * contain a membership for this session.
   */
  function resolveMembershipId(connInfo: unknown): string | null {
    if (!isRealtimeConnectInfo(connInfo)) return null;
    const match = connInfo.memberships.find((m) => m.gameSessionId === gameSessionId);
    return match?.membershipId ?? null;
  }

  function handleJoin(ctx: JoinContext): void {
    const membershipId = resolveMembershipId(ctx.info.connInfo);
    if (!membershipId) return;
    clientToMembership.set(ctx.info.client, membershipId);
    rebuildSet();
  }

  function handleLeave(ctx: LeaveContext): void {
    clientToMembership.delete(ctx.info.client);
    rebuildSet();
  }

  async function start(): Promise<void> {
    if (centrifuge) return;
    error.value = null;

    try {
      const token = await fetchRealtimeToken();
      centrifuge = new Centrifuge(wsUrl, {
        token,
        getToken: fetchRealtimeToken,
      });

      centrifuge.on('disconnected', (ctx) => {
        if (ctx.code >= 3500) {
          error.value = ctx.reason || `Disconnected (code ${String(ctx.code)})`;
        }
      });
      centrifuge.on('error', (ctx) => {
        error.value = ctx.error.message || 'Presence connection error';
      });

      const channel = `session.${gameSessionId}`;
      const sub = centrifuge.newSubscription(channel);

      sub.on('subscribed', () => {
        // Fetch the initial presence snapshot after subscribing.
        // Using an async IIFE so we can await + suppress without a bare
        // .then()/.catch() chain (avoids the promise/always-return lint rule).
        void (async () => {
          try {
            const result = await sub.presence();
            clientToMembership.clear();
            for (const [clientId, clientInfo] of Object.entries(result.clients)) {
              const membershipId = resolveMembershipId(clientInfo.connInfo);
              if (membershipId) {
                clientToMembership.set(clientId, membershipId);
              }
            }
            rebuildSet();
          } catch {
            // Non-fatal — presence() can fail if the subscription is lost
            // before the response arrives. The join/leave stream will still
            // keep the set consistent going forward.
          }
        })();
      });

      sub.on('join', handleJoin);
      sub.on('leave', handleLeave);

      sub.subscribe();
      centrifuge.connect();
    } catch (err) {
      error.value = err instanceof Error ? err.message : String(err);
      if (centrifuge) {
        centrifuge.disconnect();
        centrifuge = null;
      }
    }
  }

  function stop(): void {
    if (!centrifuge) return;
    centrifuge.disconnect();
    centrifuge = null;
    clientToMembership.clear();
    _onlineSet.value = new Set<string>();
  }

  return { onlineSet, error, start, stop };
}
