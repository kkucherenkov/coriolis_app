/**
 * useSessionRealtime — Centrifugo websocket subscription for the session
 * detail page (Phase 4 Feature 7.4).
 *
 * Subscribes to `session.{gameSessionId}` and surfaces the two domain
 * messages the backend currently publishes (`dp.changed`, `roll.pushed`)
 * via Vue refs so the page can reactively patch its DP counter and toast
 * roll-pushed events without polling.
 *
 * Lifecycle:
 *   1. `start()` mints a fresh JWT via POST /api/v1/realtime/token, opens
 *      the websocket, and subscribes. The subscription is single-shot —
 *      Centrifugo limits each token's allowed channels via `Allow` /
 *      `Subs` claims set server-side (see `apps/backend/src/modules/
 *      realtime`), so we don't need to re-mint mid-connection.
 *   2. `stop()` unsubscribes and closes the socket. Always called on
 *      unmount; also called when the route param `id` changes so we
 *      don't leak a subscription to the previous session.
 *
 * The ws URL comes from `runtimeConfig.public.realtimeWsUrl` (default
 * matches the docker-compose container at ws://localhost:8000).
 *
 * Token expiry: BA's runtime token is short-lived (≤5 min per the spec
 * comments). Centrifuge handles refresh automatically when we plug a
 * `getToken` callback into the client constructor — the callback fires
 * before the current token expires and lets us re-mint without
 * dropping the connection.
 */
import { ref, type Ref } from 'vue';
import { Centrifuge, type PublicationContext } from 'centrifuge';
import { issueRealtimeToken } from '@app/api-client-ts';
import type { Problem, Combatant, EncounterStatus } from '@app/api-client-ts';

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

export interface DpChangedPayload {
  gameSessionId: string;
  dpCount: number;
  delta: number;
  source: 'gm-manual' | 'roll-push' | 'system';
  at?: string;
}

export interface RollPushedPayload {
  rollId: string;
  characterId: string;
  gameSessionId?: string | null;
  hits: number;
  at?: string;
}

/** Encounter snapshot inside a combat.updated payload (mirrors AsyncAPI CombatUpdated.encounter). */
export interface CombatUpdatedEncounterSnapshot {
  id: string;
  gameSessionId: string;
  name: string;
  status: EncounterStatus;
  round: number;
  activeCombatantId: string | null;
  notes?: string | null;
  createdAt: string;
  updatedAt: string;
}

/** Full combat.updated payload per AsyncAPI v0.11+ CombatUpdated schema. */
export interface CombatUpdatedPayload {
  gameSessionId: string;
  encounterId: string;
  encounter: CombatUpdatedEncounterSnapshot;
  /** Full combatant list in current turn order (turnOrder ascending). */
  combatants: Combatant[];
  at: string;
}

export interface SessionRealtimeHandle {
  /** True while the websocket is connected and subscribed. */
  connected: Ref<boolean>;
  /** Last error (network, token mint, server reject). Null when healthy. */
  error: Ref<string | null>;
  /** Most recent dp.changed payload (null until one arrives). */
  lastDpChanged: Ref<DpChangedPayload | null>;
  /** Most recent roll.pushed payload (null until one arrives). */
  lastRollPushed: Ref<RollPushedPayload | null>;
  /**
   * Most recent combat.updated payload (null until one arrives).
   * Consumers replace their local combatant state wholesale from
   * `payload.combatants` — no diffing.
   */
  lastCombatUpdated: Ref<CombatUpdatedPayload | null>;
  /** Open the connection and subscribe. Idempotent. */
  start(): Promise<void>;
  /** Close the subscription and the socket. Safe to call from onUnmounted. */
  stop(): Promise<void>;
}

export function useSessionRealtime(gameSessionId: string): SessionRealtimeHandle {
  const { public: pub } = useRuntimeConfig();
  const wsUrl = pub.realtimeWsUrl as string;

  const connected = ref(false);
  const error = ref<string | null>(null);
  const lastDpChanged = ref<DpChangedPayload | null>(null);
  const lastRollPushed = ref<RollPushedPayload | null>(null);
  const lastCombatUpdated = ref<CombatUpdatedPayload | null>(null);

  let centrifuge: Centrifuge | null = null;

  async function start(): Promise<void> {
    if (centrifuge) return;
    error.value = null;
    try {
      const token = await fetchRealtimeToken();
      // The Centrifuge client will call `getToken` again when the
      // current token nears expiry — `fetchRealtimeToken` re-mints via
      // the same /realtime/token endpoint without re-entering the
      // connection lifecycle.
      centrifuge = new Centrifuge(wsUrl, {
        token,
        getToken: fetchRealtimeToken,
      });

      centrifuge.on('connected', () => {
        connected.value = true;
      });
      centrifuge.on('disconnected', (ctx) => {
        connected.value = false;
        if (ctx.code >= 3500) {
          // Centrifuge marks fatal codes as ≥ 3500 (auth failure,
          // token rotation rejected, etc); surface them to the UI.
          error.value = ctx.reason || `Disconnected (code ${String(ctx.code)})`;
        }
      });
      centrifuge.on('error', (ctx) => {
        // Network / connection errors. Don't blank `error.value` on
        // a transient blip — Centrifuge will reconnect.
        error.value = ctx.error.message || 'Realtime connection error';
      });

      const channel = `session.${gameSessionId}`;
      const sub = centrifuge.newSubscription(channel);

      sub.on('publication', (ctx: PublicationContext) => {
        const data = ctx.data as Record<string, unknown> | undefined;
        if (!data || typeof data !== 'object') return;
        // Discriminate by structural shape:
        //   dp.changed    → unique field `dpCount`
        //   roll.pushed   → unique field `rollId`
        //   combat.updated → unique field `encounterId` + `combatants` array
        if ('dpCount' in data && typeof data.dpCount === 'number') {
          lastDpChanged.value = data as unknown as DpChangedPayload;
          return;
        }
        if ('rollId' in data && typeof data.rollId === 'string') {
          lastRollPushed.value = data as unknown as RollPushedPayload;
          return;
        }
        if (
          'encounterId' in data &&
          typeof data.encounterId === 'string' &&
          Array.isArray(data.combatants)
        ) {
          lastCombatUpdated.value = data as unknown as CombatUpdatedPayload;
        }
      });

      sub.subscribe();
      centrifuge.connect();
    } catch (error_) {
      error.value = error_ instanceof Error ? error_.message : String(error_);
      // Tear down anything we managed to construct so a retry starts
      // from a clean slate.
      if (centrifuge) {
        centrifuge.disconnect();
        centrifuge = null;
      }
    }
  }

  function stop(): Promise<void> {
    if (!centrifuge) return Promise.resolve();
    centrifuge.disconnect();
    centrifuge = null;
    connected.value = false;
    return Promise.resolve();
  }

  return { connected, error, lastDpChanged, lastRollPushed, lastCombatUpdated, start, stop };
}
