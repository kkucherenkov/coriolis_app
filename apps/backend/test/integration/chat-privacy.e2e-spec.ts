/**
 * Chat privacy regression — Stream C / Task 9.1
 *
 * Transport: live backend container at http://localhost:3010 (same pattern as
 * realtime-dp.e2e-spec.ts). Auth: Better Auth bearer tokens obtained by
 * calling the real /api/v1/auth/sign-up/email + sign-in endpoints in
 * beforeAll — no test-mode bypass, no auth-production-code modification.
 *
 * Scenario:
 *   - GM seeds a session + invite.
 *   - Player A, Player B, Player C all accept the invite (separately rotated).
 *   - Player A sends a whisper to Player B via
 *     POST /game-sessions/{id}/chat/messages with targetMembershipId = B.
 *
 * Assertions (7):
 *   1. GET /chat/messages/{id} as A → 200.
 *   2. GET /chat/messages/{id} as B → 200.
 *   3. GET /chat/messages/{id} as C → 404 + problem+json type.
 *   4. GET /chat/messages/{id} as GM (member, not A/B) → 404.
 *   5. DELETE /chat/messages/{id} as GM → 404 (NOT 403 — privacy contract).
 *   6. GET /game-sessions/{id}/chat/messages?conversation={B_memId} as C
 *      → 200 with items: [] (no presence leak).
 *   7. GET /game-sessions/{id}/chat/messages?conversation={B_memId} as A
 *      → 200 with items containing the whisper (sanity check).
 *
 * Manual smoke recipe (plan §9.6):
 *   # 1. GM seeds invite + accepts as Player A.
 *   curl -X POST -H "Authorization: Bearer <GM>" "http://localhost:3010/api/v1/game-sessions/<S>/invite/rotate" | jq .  # → token
 *   curl -X POST -H "Authorization: Bearer <PA>" "http://localhost:3010/api/v1/invites/<TOKEN>/accept" | jq .          # → membership_A
 *
 *   # 2. Player A POSTs broadcast.
 *   curl -X POST -H "Authorization: Bearer <PA>" -H 'Content-Type: application/json' \
 *     -d '{"kind":"text","body":"hi everyone"}' \
 *     "http://localhost:3010/api/v1/game-sessions/<S>/chat/messages" | jq .
 *
 *   # 3. Player A whispers Player B.
 *   curl -X POST -H "Authorization: Bearer <PA>" -H 'Content-Type: application/json' \
 *     -d '{"kind":"text","body":"secret","targetMembershipId":"<B_id>"}' \
 *     "http://localhost:3010/api/v1/game-sessions/<S>/chat/messages" | jq .
 *
 *   # 4. GM tries DELETE on whisper id — 404.
 *   curl -X DELETE -H "Authorization: Bearer <GM>" "http://localhost:3010/api/v1/chat/messages/<W>" -w '%{http_code}\n'
 *
 *   # 5. Rate limit smoke: 31 POSTs in one minute — 30 succeed, 31st returns 429.
 *   for i in $(seq 1 31); do
 *     curl -X POST -H "Authorization: Bearer <PA>" -H 'Content-Type: application/json' \
 *       -d "{\"kind\":\"text\",\"body\":\"msg $i\"}" \
 *       "http://localhost:3010/api/v1/game-sessions/<S>/chat/messages" -w "%{http_code} "
 *   done
 *
 * Requires the Docker Compose stack to be running:
 *   docker compose -f docker/compose.yml up -d
 *   pnpm --filter @app/backend test:e2e
 */

import { beforeAll, describe, expect, it } from 'vitest';

const BACKEND_URL = process.env['INTEGRATION_BACKEND_URL'] ?? 'http://localhost:3010';
const BASE = `${BACKEND_URL}/api/v1`;

let backendUp = false;

// ─── Auth helpers ────────────────────────────────────────────────────────────

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

  if (!res.ok) {
    throw new Error(`sign-up failed for ${email}: ${res.status.toString()}`);
  }
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

async function postWhisper(
  authorToken: string,
  sessionId: string,
  targetMembershipId: string,
  body: string,
): Promise<{ id: string }> {
  const res = await fetch(`${BASE}/game-sessions/${sessionId}/chat/messages`, {
    method: 'POST',
    headers: { ...auth(authorToken), 'Content-Type': 'application/json' },
    body: JSON.stringify({ kind: 'text', body, targetMembershipId }),
  });
  if (!res.ok) throw new Error(`postWhisper failed: ${res.status.toString()}`);
  return res.json() as Promise<{ id: string }>;
}

// ─── Test state ───────────────────────────────────────────────────────────────

const run = `${Date.now().toString(36)}`;

let gmToken = '';
let paToken = '';
let pbToken = '';
let pcToken = '';

let sessionId = '';
let paMembershipId = '';
let pbMembershipId = '';
let whisperId = '';

// ─── Setup ────────────────────────────────────────────────────────────────────

beforeAll(async () => {
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

  if (!backendUp) {
    console.warn(
      '[SKIP] Backend not reachable — start the Docker stack to run chat privacy e2e tests.',
    );
    return;
  }

  // Sign up four users with unique e-mails per run to avoid conflicts with
  // previous test runs. Better Auth does not support DELETE /users in the
  // default config, so we derive uniqueness from a run-id prefix.
  const gm = await signUp(`chat-gm-${run}@e2e.test`, 'Test1234!', 'E2E GM');
  const pa = await signUp(`chat-pa-${run}@e2e.test`, 'Test1234!', 'E2E Player A');
  const pb = await signUp(`chat-pb-${run}@e2e.test`, 'Test1234!', 'E2E Player B');
  const pc = await signUp(`chat-pc-${run}@e2e.test`, 'Test1234!', 'E2E Player C');

  gmToken = gm.token;
  paToken = pa.token;
  pbToken = pb.token;
  pcToken = pc.token;

  // GM creates a session
  sessionId = await createSession(gmToken, `Chat Privacy E2E — ${run}`);

  // GM joins as member (so GM has an active membership and is NOT author/target of A→B whisper)
  const inviteGm = await rotateInvite(gmToken, sessionId);
  await acceptInvite(gmToken, inviteGm);

  // Player A joins
  const inviteA = await rotateInvite(gmToken, sessionId);
  const memberA = await acceptInvite(paToken, inviteA);
  paMembershipId = memberA.membershipId;

  // Player B joins
  const inviteB = await rotateInvite(gmToken, sessionId);
  const memberB = await acceptInvite(pbToken, inviteB);
  pbMembershipId = memberB.membershipId;

  // Player C joins (bystander)
  const inviteC = await rotateInvite(gmToken, sessionId);
  await acceptInvite(pcToken, inviteC);

  // Player A sends a whisper to Player B
  const whisper = await postWhisper(paToken, sessionId, pbMembershipId, 'secret e2e whisper');
  whisperId = whisper.id;
}, 30_000);

// ─── Tests ────────────────────────────────────────────────────────────────────

describe('Chat privacy — whisper visibility contract', () => {
  it('1 — author (A) can read own whisper → 200', async () => {
    if (!backendUp) return;

    const res = await fetch(`${BASE}/chat/messages/${whisperId}`, { headers: auth(paToken) });
    expect(res.status).toBe(200);

    const body = (await res.json()) as {
      id: string;
      targetMembershipId: string;
      body: string;
    };
    expect(body.id).toBe(whisperId);
    expect(body.targetMembershipId).toBe(pbMembershipId);
    expect(body.body).toBe('secret e2e whisper');
  });

  it('2 — target (B) can read received whisper → 200', async () => {
    if (!backendUp) return;

    const res = await fetch(`${BASE}/chat/messages/${whisperId}`, { headers: auth(pbToken) });
    expect(res.status).toBe(200);

    const body = (await res.json()) as { id: string };
    expect(body.id).toBe(whisperId);
  });

  it('3 — bystander (C, active member) gets 404 + problem+json', async () => {
    if (!backendUp) return;

    const res = await fetch(`${BASE}/chat/messages/${whisperId}`, { headers: auth(pcToken) });
    expect(res.status).toBe(404);
    expect(res.headers.get('content-type')).toMatch(/application\/problem\+json/);

    const body = (await res.json()) as { type: string; code: string; status: number };
    expect(body.type).toBe('urn:problem-type:CHAT_MESSAGE_NOT_FOUND');
    expect(body.code).toBe('CHAT_MESSAGE_NOT_FOUND');
    expect(body.status).toBe(404);
  });

  it('4 — GM (active member, not author/target) gets 404 (privacy, not 403)', async () => {
    if (!backendUp) return;

    const res = await fetch(`${BASE}/chat/messages/${whisperId}`, { headers: auth(gmToken) });
    // Privacy contract: non-party members get 404, never 403.
    expect(res.status).toBe(404);

    const body = (await res.json()) as { type: string };
    expect(body.type).toBe('urn:problem-type:CHAT_MESSAGE_NOT_FOUND');
  });

  it('5 — GM DELETE on whisper → 404 (cannot act on message it cannot see)', async () => {
    if (!backendUp) return;

    const res = await fetch(`${BASE}/chat/messages/${whisperId}`, {
      method: 'DELETE',
      headers: auth(gmToken),
    });
    // GM has no visibility of the whisper → 404, NOT 403.
    expect(res.status).toBe(404);
  });

  it('6 — C lists A↔B conversation → 200 with empty items (no presence leak)', async () => {
    if (!backendUp) return;

    // C asking for the A↔B conversation channel (using B's membershipId as key)
    const url = `${BASE}/game-sessions/${sessionId}/chat/messages?conversation=${pbMembershipId}`;
    const res = await fetch(url, { headers: auth(pcToken) });
    expect(res.status).toBe(200);

    const body = (await res.json()) as { items: unknown[]; nextCursor: string | null };
    expect(body.items).toHaveLength(0);
  });

  it('7 — author A lists own conversation with B → 200 with the whisper message', async () => {
    if (!backendUp) return;

    const url = `${BASE}/game-sessions/${sessionId}/chat/messages?conversation=${pbMembershipId}`;
    const res = await fetch(url, { headers: auth(paToken) });
    expect(res.status).toBe(200);

    const body = (await res.json()) as {
      items: Array<{ id: string }>;
      nextCursor: string | null;
    };
    expect(body.items.length).toBeGreaterThanOrEqual(1);
    const found = body.items.find((m) => m.id === whisperId);
    expect(found).toBeDefined();
  });
});
