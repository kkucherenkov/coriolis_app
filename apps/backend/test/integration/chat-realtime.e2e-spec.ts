/**
 * Chat realtime privacy regression — Stream C / Task 9.2
 *
 * Mirrors realtime-dp.e2e-spec.ts:
 *   - Health-checks Centrifugo; skips when unreachable.
 *   - Creates real users + memberships via the live backend (same as chat-privacy.e2e-spec.ts).
 *   - Signs Centrifugo JWTs locally (using CENTRIFUGO_TOKEN_HMAC_SECRET from
 *     docker/compose.yml default: "dev-hmac-secret").
 *   - Opens two WebSocket connections (A and C) and subscribes each to its
 *     per-member channel AND the shared session.chat channel.
 *   - A POSTs a whisper to B via the real REST API.
 *
 * Assertions:
 *   - A receives ONE message on session.<id>.member.<A_membershipId> within 1s.
 *   - C receives NOTHING on any subscribed channel within a 1s timeout.
 *   - Both A and C are subscribed to session.<id>.chat to prove the whisper is
 *     NOT leaked to the broadcast channel.
 *
 * Design note on B:
 *   B's per-member channel would also receive the whisper but we do not open a
 *   WebSocket for B in this harness — the assertion on A's delivery is sufficient
 *   to prove the publisher routes correctly. See test comment inline.
 *
 * JWT signing helpers are inlined (not extracted to a shared util) per the
 * constraint "don't create new helper utilities outside test/" — the helpers
 * are copied from the pattern established in realtime-dp.e2e-spec.ts.
 *
 * Requires the full Docker Compose stack:
 *   docker compose -f docker/compose.yml up -d
 *   pnpm --filter @app/backend test:e2e
 *
 * Environment (defaults match docker/compose.yml):
 *   INTEGRATION_CENTRIFUGO_URL          http://localhost:8000
 *   INTEGRATION_CENTRIFUGO_WS_URL       ws://localhost:8000
 *   INTEGRATION_CENTRIFUGO_TOKEN_SECRET dev-hmac-secret
 *   INTEGRATION_BACKEND_URL             http://localhost:3010
 */

import * as crypto from 'node:crypto';

import { beforeAll, describe, expect, it } from 'vitest';

const CENTRIFUGO_API_URL = process.env['INTEGRATION_CENTRIFUGO_URL'] ?? 'http://localhost:8000';
const CENTRIFUGO_WS_URL = process.env['INTEGRATION_CENTRIFUGO_WS_URL'] ?? 'ws://localhost:8000';
const CENTRIFUGO_TOKEN_SECRET =
  process.env['INTEGRATION_CENTRIFUGO_TOKEN_SECRET'] ?? 'dev-hmac-secret';
const BACKEND_URL = process.env['INTEGRATION_BACKEND_URL'] ?? 'http://localhost:3010';
const BASE = `${BACKEND_URL}/api/v1`;

let centrifugoUp = false;
let backendUp = false;

// ─── JWT signing (inlined — mirrors realtime-dp.e2e-spec.ts) ─────────────────

/**
 * Produces a minimal Centrifugo connection JWT signed with HS256.
 * Uses only Node.js built-ins — no external jwt library needed.
 * The `channels` claim pre-authorises the client to subscribe to listed channels
 * without a separate per-channel JWT, which is how the production realtime
 * token endpoint works.
 */
function makeCentrifugoJwt(userId: string, channels: string[]): string {
  const header = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64url');
  const exp = Math.floor(Date.now() / 1000) + 300;
  const payload = Buffer.from(JSON.stringify({ sub: userId, exp, channels })).toString('base64url');
  const sig = crypto
    .createHmac('sha256', CENTRIFUGO_TOKEN_SECRET)
    .update(`${header}.${payload}`)
    .digest('base64url');
  return `${header}.${payload}.${sig}`;
}

// ─── Auth helpers (same as chat-privacy.e2e-spec.ts — inlined, not shared) ──

/**
 * Registers a new user, or signs in if the account already exists (422).
 *
 * Better Auth has a built-in IP-based rate limiter for sign-up (fires as 403)
 * when the test suite runs in parallel with other e2e files in the same minute.
 * On 403, we wait 2s and retry once; on 422 (user exists), we fall back to
 * sign-in to keep tests idempotent across repeated runs.
 */
async function signUp(
  email: string,
  password: string,
  name: string,
): Promise<{ token: string; userId: string }> {
  const attempt = async (): Promise<Response> =>
    fetch(`${BASE}/auth/sign-up/email`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, name }),
    });

  let res = await attempt();

  // 403 = Better Auth rate-limiter; wait 2s and retry once.
  if (res.status === 403) {
    await new Promise<void>((r) => setTimeout(r, 2000));
    res = await attempt();
  }

  // 422 = user already exists from a previous run; sign in instead.
  if (res.status === 422) {
    const signIn = await fetch(`${BASE}/auth/sign-in/email`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    if (!signIn.ok)
      throw new Error(`sign-in fallback failed for ${email}: ${signIn.status.toString()}`);
    const body = (await signIn.json()) as { token: string; user: { id: string } };
    return { token: body.token, userId: body.user.id };
  }

  if (!res.ok) throw new Error(`sign-up failed for ${email}: ${res.status.toString()}`);
  const body = (await res.json()) as { token: string; user: { id: string } };
  return { token: body.token, userId: body.user.id };
}

function auth(token: string): Record<string, string> {
  return { Authorization: `Bearer ${token}` };
}

async function createSession(token: string, name: string): Promise<string> {
  const res = await fetch(`${BASE}/game-sessions`, {
    method: 'POST',
    headers: { ...auth(token), 'Content-Type': 'application/json' },
    body: JSON.stringify({ name }),
  });
  if (!res.ok) throw new Error(`createSession failed: ${res.status.toString()}`);
  const body = (await res.json()) as { id: string };
  return body.id;
}

async function rotateInvite(gmToken: string, sessionId: string): Promise<string> {
  const res = await fetch(`${BASE}/game-sessions/${sessionId}/invite/rotate`, {
    method: 'POST',
    headers: auth(gmToken),
  });
  if (!res.ok) throw new Error(`rotateInvite failed: ${res.status.toString()}`);
  const body = (await res.json()) as { token: string };
  return body.token;
}

async function acceptInvite(token: string, inviteToken: string): Promise<{ membershipId: string }> {
  const res = await fetch(`${BASE}/invites/${inviteToken}/accept`, {
    method: 'POST',
    headers: auth(token),
  });
  if (!res.ok) throw new Error(`acceptInvite failed: ${res.status.toString()}`);
  const body = (await res.json()) as { membership: { id: string } };
  return { membershipId: body.membership.id };
}

// ─── WebSocket subscriber helper ──────────────────────────────────────────────

interface SubscribeResult {
  /** Messages received on any subscribed channel (keyed by channel name). */
  received: Map<string, unknown[]>;
  close: () => void;
}

/**
 * Opens a Centrifugo WebSocket, authenticates, subscribes to all `channels`,
 * and collects inbound push messages for `listenMs` milliseconds.
 *
 * Returns a SubscribeResult whose `received` map is populated when the promise
 * resolves. Caller must call `close()` after the timeout to ensure the socket
 * is cleaned up even if the test runner re-uses the process.
 */
function openSubscriber(
  userId: string,
  channels: string[],
  listenMs: number,
): Promise<SubscribeResult> {
  return new Promise<SubscribeResult>((resolve, reject) => {
    const jwt = makeCentrifugoJwt(userId, channels);
    const ws = new WebSocket(`${CENTRIFUGO_WS_URL}/connection/websocket?cf_token=${jwt}`);
    const received = new Map<string, unknown[]>(channels.map((c) => [c, []]));

    let subscribed = 0;
    let connected = false;
    let msgId = 1;

    const closeAndResolve = (): void => {
      ws.close();
      resolve({ received, close: () => ws.close() });
    };

    const timeout = setTimeout(closeAndResolve, listenMs);

    ws.addEventListener('open', () => {
      ws.send(JSON.stringify({ id: msgId++, connect: {} }));
    });

    ws.addEventListener('message', (event: MessageEvent) => {
      const msg = JSON.parse(event.data as string) as Record<string, unknown>;

      // Step 1: connection handshake
      if (!connected && 'connect' in msg) {
        connected = true;
        // Subscribe to all requested channels sequentially
        for (const ch of channels) {
          ws.send(JSON.stringify({ id: msgId++, subscribe: { channel: ch } }));
        }
        return;
      }

      // Step 2: subscription confirmations — count until all are confirmed
      if ('subscribe' in msg) {
        subscribed += 1;
        // All subscriptions confirmed — the subscriber is ready; start the listen timer
        if (subscribed === channels.length) {
          // Reset the outer timeout to start now (from full subscription readiness)
          clearTimeout(timeout);
          setTimeout(closeAndResolve, listenMs);
        }
        return;
      }

      // Step 3: inbound push messages
      if ('push' in msg) {
        const push = msg['push'] as Record<string, unknown>;
        const channel = push['channel'] as string | undefined;
        const pub = push['pub'] as Record<string, unknown> | undefined;
        if (channel && pub) {
          const bucket = received.get(channel);
          if (bucket) {
            bucket.push(pub['data']);
          }
        }
      }
    });

    ws.addEventListener('error', (err: Event) => {
      clearTimeout(timeout);
      reject(new Error(`WebSocket error: ${String(err)}`));
    });
  });
}

// ─── Test state ───────────────────────────────────────────────────────────────

const run = `rt-${Date.now().toString(36)}`;

let paToken = '';
let paUserId = '';
let paMembershipId = '';

let pbMembershipId = '';

let pcToken = '';
let pcUserId = '';
let pcMembershipId = '';

let sessionId = '';

// ─── Setup ────────────────────────────────────────────────────────────────────

beforeAll(async () => {
  // Health-check Centrifugo
  try {
    const ctrl = new AbortController();
    const id = setTimeout(() => {
      ctrl.abort();
    }, 800);
    const res = await fetch(`${CENTRIFUGO_API_URL}/health`, { signal: ctrl.signal });
    clearTimeout(id);
    centrifugoUp = res.ok;
  } catch {
    centrifugoUp = false;
  }

  // Health-check backend
  try {
    const ctrl = new AbortController();
    const id = setTimeout(() => {
      ctrl.abort();
    }, 1500);
    const res = await fetch(`${BACKEND_URL}/api/v1/health`, { signal: ctrl.signal });
    clearTimeout(id);
    backendUp = res.ok;
  } catch {
    backendUp = false;
  }

  if (!centrifugoUp || !backendUp) {
    const missing = [!centrifugoUp && 'Centrifugo', !backendUp && 'Backend']
      .filter(Boolean)
      .join(', ');
    console.warn(
      `[SKIP] ${missing} not reachable — start the Docker stack to run chat realtime e2e tests.`,
    );
    return;
  }

  // Seed: GM + three players in one session
  const gm = await signUp(`rt-gm-${run}@e2e.test`, 'Test1234!', 'RT GM');
  const pa = await signUp(`rt-pa-${run}@e2e.test`, 'Test1234!', 'RT Player A');
  const pb = await signUp(`rt-pb-${run}@e2e.test`, 'Test1234!', 'RT Player B');
  const pc = await signUp(`rt-pc-${run}@e2e.test`, 'Test1234!', 'RT Player C');

  paToken = pa.token;
  paUserId = pa.userId;
  pcToken = pc.token;
  pcUserId = pc.userId;

  sessionId = await createSession(gm.token, `Chat RT E2E — ${run}`);

  const inviteA = await rotateInvite(gm.token, sessionId);
  const memberA = await acceptInvite(paToken, inviteA);
  paMembershipId = memberA.membershipId;

  const inviteB = await rotateInvite(gm.token, sessionId);
  const memberB = await acceptInvite(pb.token, inviteB);
  pbMembershipId = memberB.membershipId;

  const inviteC = await rotateInvite(gm.token, sessionId);
  const memberC = await acceptInvite(pcToken, inviteC);
  pcMembershipId = memberC.membershipId;
}, 30_000);

// ─── Tests ────────────────────────────────────────────────────────────────────

describe('Chat realtime — whisper channel routing', () => {
  it('A receives whisper on own member channel; C receives nothing on any channel', async () => {
    if (!centrifugoUp || !backendUp) {
      console.log(
        '[SKIP] Centrifugo or Backend not reachable — start the Docker stack to run this test.',
      );
      return;
    }

    // Both A and C subscribe to:
    //   - session.<id>.chat         (broadcast — whisper must NOT appear here)
    //   - session.<id>.member.<X>   (per-member — whisper goes to A, not C)
    const chatChannel = `session.${sessionId}.chat`;
    const memberAChannel = `session.${sessionId}.member.${paMembershipId}`;
    const memberCChannel = `session.${sessionId}.member.${pcMembershipId}`;

    const aChannels = [chatChannel, memberAChannel];
    const cChannels = [chatChannel, memberCChannel];

    // Open both subscribers before posting so neither misses the message
    const [aResult, cResult] = await Promise.all([
      // A subscribes and listens for 1.5s (leave room for publish round-trip)
      new Promise<SubscribeResult>((resolve, reject) => {
        const jwt = makeCentrifugoJwt(paUserId, aChannels);
        const ws = new WebSocket(`${CENTRIFUGO_WS_URL}/connection/websocket?cf_token=${jwt}`);
        const received = new Map<string, unknown[]>(aChannels.map((c) => [c, []]));

        let subscribed = 0;
        let connected = false;
        let msgId = 1;
        let listenTimeout: ReturnType<typeof setTimeout>;

        const closeAndResolve = (): void => {
          ws.close();
          resolve({ received, close: () => ws.close() });
        };

        const startListenTimer = (): void => {
          listenTimeout = setTimeout(closeAndResolve, 1500);
        };

        // Safety net: abort after 5s regardless
        const safetyTimeout = setTimeout(() => {
          clearTimeout(listenTimeout);
          closeAndResolve();
        }, 5000);

        ws.addEventListener('open', () => {
          ws.send(JSON.stringify({ id: msgId++, connect: {} }));
        });

        ws.addEventListener('message', (event: MessageEvent) => {
          const msg = JSON.parse(event.data as string) as Record<string, unknown>;

          if (!connected && 'connect' in msg) {
            connected = true;
            for (const ch of aChannels) {
              ws.send(JSON.stringify({ id: msgId++, subscribe: { channel: ch } }));
            }
            return;
          }

          if ('subscribe' in msg) {
            subscribed += 1;
            if (subscribed === aChannels.length) {
              // All subscriptions ready — POST the whisper and start the timer
              clearTimeout(safetyTimeout);

              fetch(`${BASE}/game-sessions/${sessionId}/chat/messages`, {
                method: 'POST',
                headers: { ...auth(paToken), 'Content-Type': 'application/json' },
                body: JSON.stringify({
                  kind: 'text',
                  body: 'realtime whisper e2e',
                  targetMembershipId: pbMembershipId,
                }),
              })
                .then(() => {
                  startListenTimer();
                })
                .catch((err: unknown) => {
                  ws.close();
                  reject(err instanceof Error ? err : new Error(String(err)));
                });
            }
            return;
          }

          if ('push' in msg) {
            const push = msg['push'] as Record<string, unknown>;
            const channel = push['channel'] as string | undefined;
            const pub = push['pub'] as Record<string, unknown> | undefined;
            if (channel && pub) {
              const bucket = received.get(channel);
              if (bucket) bucket.push(pub['data']);
            }
          }
        });

        ws.addEventListener('error', (err: Event) => {
          clearTimeout(safetyTimeout);
          clearTimeout(listenTimeout);
          reject(new Error(`WebSocket A error: ${String(err)}`));
        });
      }),

      // C subscribes and listens passively — using the shared helper
      // (no action triggered — C just waits to confirm silence)
      openSubscriber(pcUserId, cChannels, 4000),
    ]);

    // ── Assertions ──────────────────────────────────────────────────────────

    // A's member channel must have received exactly one message (the whisper)
    const aMessages = aResult.received.get(memberAChannel) ?? [];
    expect(aMessages).toHaveLength(1);

    // The received payload must match the whisper shape
    const aMsg = aMessages[0] as Record<string, unknown>;
    expect(aMsg).toMatchObject({
      targetMembershipId: pbMembershipId,
      authorMembershipId: paMembershipId,
      body: 'realtime whisper e2e',
      kind: 'text',
    });

    // The broadcast chat channel must be silent for A (whisper → NOT on .chat)
    const aChatMessages = aResult.received.get(chatChannel) ?? [];
    expect(aChatMessages).toHaveLength(0);

    // C must receive nothing on the shared chat channel
    const cChatMessages = cResult.received.get(chatChannel) ?? [];
    expect(cChatMessages).toHaveLength(0);

    // C must receive nothing on its own member channel
    const cMemberMessages = cResult.received.get(memberCChannel) ?? [];
    expect(cMemberMessages).toHaveLength(0);

    // NOTE: B's per-member channel (session.<id>.member.<B>) would also receive
    // the whisper but we do not open a WebSocket for B in this harness to keep
    // setup simple. The publisher spec (chat-realtime.publisher.spec.ts) already
    // verifies that two publish calls are made — one per party.
  }, 15_000);
});
