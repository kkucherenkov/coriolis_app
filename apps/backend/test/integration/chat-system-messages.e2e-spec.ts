/**
 * Chat system-message regression — Stream D / Task 2.4
 *
 * Requires the Docker Compose stack to be running:
 *   docker compose -f docker/compose.yml up -d
 *   pnpm --filter @app/backend test:e2e
 *
 * Scenarios:
 *   1. Player accepts invite → chat_message row with kind=system,
 *      systemKey='chat.system.member_joined', systemParams.displayName === player name.
 *   2. Player leaves session → second system row, key='chat.system.member_left'.
 *   3. Player rolls (kind=skill) + pushes → third row, key='chat.system.roll_pushed',
 *      systemParams.characterName + systemParams.hits present.
 *
 * Auth: Better Auth bearer tokens from real /auth/sign-up/email + sign-in.
 * Isolation: unique run-id prefix on emails to avoid conflicts with prior runs.
 */

import { beforeAll, describe, expect, it } from 'vitest';

const BACKEND_URL = process.env['INTEGRATION_BACKEND_URL'] ?? 'http://localhost:3010';
const BASE = `${BACKEND_URL}/api/v1`;

let backendUp = false;

// ─── Shared auth helpers (mirrors chat-privacy.e2e-spec.ts) ──────────────────

// Better Auth v1.6.8 requires an Origin header on all auth endpoints to
// validate against trustedOrigins. Node.js native fetch does not add Origin
// automatically for same-host requests, causing a 403 MISSING_OR_NULL_ORIGIN
// response. We pin to the default trusted origin (CORS_ORIGINS default).
const AUTH_ORIGIN = 'http://localhost:3001';

async function signUp(
  email: string,
  password: string,
  name: string,
): Promise<{ token: string; userId: string }> {
  const attempt = async (): Promise<Response> =>
    fetch(`${BASE}/auth/sign-up/email`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Origin: AUTH_ORIGIN },
      body: JSON.stringify({ email, password, name }),
    });

  let res = await attempt();

  // 403 can still occur from the Better Auth IP rate-limiter (window=10s, max=3).
  // On 403, wait 12s and retry once.
  if (res.status === 403) {
    await new Promise<void>((r) => setTimeout(r, 12_000));
    res = await attempt();
  }

  if (res.status === 422) {
    const signIn = await fetch(`${BASE}/auth/sign-in/email`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Origin: AUTH_ORIGIN },
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

async function leaveSession(
  token: string,
  gameSessionId: string,
  membershipId: string,
): Promise<void> {
  const res = await fetch(`${BASE}/game-sessions/${gameSessionId}/members/${membershipId}`, {
    method: 'DELETE',
    headers: auth(token),
  });
  // 204 No Content on success
  if (!res.ok && res.status !== 204)
    throw new Error(`leaveSession failed: ${res.status.toString()}`);
}

async function createCharacter(token: string, name: string): Promise<string> {
  const res = await fetch(`${BASE}/characters`, {
    method: 'POST',
    headers: { ...auth(token), 'Content-Type': 'application/json' },
    body: JSON.stringify({
      name,
      upbringing: 'plebeian',
      attributes: { strength: 3, agility: 3, wits: 3, empathy: 3 },
      skills: {
        dexterity: 0,
        force: 0,
        infiltration: 0,
        manipulation: 0,
        meleeCombat: 0,
        observation: 0,
        rangedCombat: 0,
        survival: 0,
        command: 0,
        culture: 0,
        dataDjinn: 0,
        medicurgy: 0,
        mysticPowers: 0,
        pilot: 0,
        science: 0,
        technology: 0,
      },
    }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`createCharacter failed: ${res.status.toString()} — ${body}`);
  }
  const body = (await res.json()) as { id: string };
  return body.id;
}

async function createRoll(token: string, characterId: string, sessionId: string): Promise<string> {
  const res = await fetch(`${BASE}/characters/${characterId}/rolls`, {
    method: 'POST',
    headers: { ...auth(token), 'Content-Type': 'application/json' },
    body: JSON.stringify({
      label: 'System message e2e roll',
      pool: 3,
      kind: 'skill',
      gameSessionId: sessionId,
    }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`createRoll failed: ${res.status.toString()} — ${body}`);
  }
  const body = (await res.json()) as { id: string };
  return body.id;
}

async function pushRoll(token: string, rollId: string): Promise<void> {
  const res = await fetch(`${BASE}/rolls/${rollId}/push`, {
    method: 'PATCH',
    headers: auth(token),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`pushRoll failed: ${res.status.toString()} — ${body}`);
  }
}

/**
 * Polls GET /game-sessions/:id/chat/messages (broadcast conversation)
 * until `predicate` is satisfied or `timeoutMs` elapses.
 * Returns the matched row or throws.
 */
async function pollForSystemMessage(
  gmToken: string,
  sessionId: string,
  predicate: (msg: Record<string, unknown>) => boolean,
  timeoutMs = 4000,
): Promise<Record<string, unknown>> {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    const res = await fetch(
      `${BASE}/game-sessions/${sessionId}/chat/messages?conversation=broadcast`,
      {
        headers: auth(gmToken),
      },
    );
    if (res.ok) {
      const body = (await res.json()) as { items: Record<string, unknown>[] };
      const found = body.items.find(predicate);
      if (found) return found;
    }
    await new Promise<void>((r) => setTimeout(r, 300));
  }
  throw new Error(`pollForSystemMessage timed out after ${timeoutMs.toString()}ms`);
}

// ─── Encounter helpers ────────────────────────────────────────────────────────

async function createEncounter(token: string, gameSessionId: string): Promise<string> {
  const res = await fetch(`${BASE}/game-sessions/${gameSessionId}/encounters`, {
    method: 'POST',
    headers: { ...auth(token), 'Content-Type': 'application/json' },
    body: JSON.stringify({ name: 'System message e2e encounter' }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`createEncounter failed: ${res.status.toString()} — ${body}`);
  }
  const body = (await res.json()) as { id: string };
  return body.id;
}

async function addCombatant(token: string, encounterId: string): Promise<void> {
  const res = await fetch(`${BASE}/encounters/${encounterId}/combatants`, {
    method: 'POST',
    headers: { ...auth(token), 'Content-Type': 'application/json' },
    body: JSON.stringify({
      combatantType: 'npc',
      displayName: 'Test Guard',
      hpMax: 4,
      initiative: 5,
    }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`addCombatant failed: ${res.status.toString()} — ${body}`);
  }
}

async function updateEncounterStatus(
  token: string,
  encounterId: string,
  status: 'setup' | 'active' | 'ended',
): Promise<void> {
  const res = await fetch(`${BASE}/encounters/${encounterId}`, {
    method: 'PATCH',
    headers: { ...auth(token), 'Content-Type': 'application/json' },
    body: JSON.stringify({ status }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`updateEncounterStatus(${status}) failed: ${res.status.toString()} — ${body}`);
  }
}

async function rollInitiative(token: string, encounterId: string): Promise<void> {
  const res = await fetch(`${BASE}/encounters/${encounterId}/initiative/roll`, {
    method: 'POST',
    headers: auth(token),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`rollInitiative failed: ${res.status.toString()} — ${body}`);
  }
}

async function advanceRound(token: string, encounterId: string): Promise<number> {
  const res = await fetch(`${BASE}/encounters/${encounterId}/round/advance`, {
    method: 'POST',
    headers: auth(token),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`advanceRound failed: ${res.status.toString()} — ${body}`);
  }
  const body = (await res.json()) as { round: number };
  return body.round;
}

// ─── Test state ───────────────────────────────────────────────────────────────

const run = `${Date.now().toString(36)}`;

let gmToken = '';
let paToken = '';
let sessionId = '';
let paMembershipId = '';
let characterId = '';
let playerDisplayName = '';

// ─── Setup ────────────────────────────────────────────────────────────────────

beforeAll(async () => {
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
      '[SKIP] Backend not reachable — start the Docker stack to run chat system-message e2e tests.',
    );
    return;
  }

  playerDisplayName = `SysMsgPlayer-${run}`;

  const gm = await signUp(`sysmsg-gm-${run}@e2e.test`, 'Test1234!', `SysMsgGM-${run}`);
  const pa = await signUp(`sysmsg-pa-${run}@e2e.test`, 'Test1234!', playerDisplayName);

  gmToken = gm.token;
  paToken = pa.token;

  // GM creates session and joins it
  sessionId = await createSession(gmToken, `SysMsg E2E — ${run}`);
  const inviteGm = await rotateInvite(gmToken, sessionId);
  await acceptInvite(gmToken, inviteGm);

  // Player joins — triggers MemberJoinedEvent
  const invitePa = await rotateInvite(gmToken, sessionId);
  const memberPa = await acceptInvite(paToken, invitePa);
  paMembershipId = memberPa.membershipId;

  // Player creates a character for rolling
  characterId = await createCharacter(paToken, `Tariq-${run}`);
}, 45_000);

// ─── Tests ────────────────────────────────────────────────────────────────────

describe('Chat system messages — join / leave / roll-pushed', () => {
  it('1 — member_joined system message created when player accepts invite', async () => {
    if (!backendUp) return;

    // The event fires synchronously in the NestJS event bus during acceptInvite,
    // but PostSystemMessageCommand is async. Poll briefly to let it settle.
    const msg = await pollForSystemMessage(
      gmToken,
      sessionId,
      (m) =>
        m['kind'] === 'system' &&
        m['systemKey'] === 'chat.system.member_joined' &&
        (m['systemParams'] as Record<string, unknown>)?.['displayName'] === playerDisplayName,
    );

    expect(msg['kind']).toBe('system');
    expect(msg['systemKey']).toBe('chat.system.member_joined');
    expect((msg['systemParams'] as Record<string, unknown>)?.['displayName']).toBe(
      playerDisplayName,
    );
    expect(msg['body']).toBeNull();
    expect(msg['authorMembershipId']).toBeNull();
    expect(msg['targetMembershipId']).toBeNull();
  });

  it('2 — roll_pushed system message created when player creates and pushes a roll', async () => {
    if (!backendUp) return;

    // Player is still an active member from beforeAll — no re-join needed.
    // Create a skill roll linked to the session, then push it.
    const rollId = await createRoll(paToken, characterId, sessionId);
    await pushRoll(paToken, rollId);

    const msg = await pollForSystemMessage(
      gmToken,
      sessionId,
      (m) => m['kind'] === 'system' && m['systemKey'] === 'chat.system.roll_pushed',
    );

    expect(msg['kind']).toBe('system');
    expect(msg['systemKey']).toBe('chat.system.roll_pushed');

    const params = msg['systemParams'] as Record<string, unknown>;
    expect(typeof params?.['characterName']).toBe('string');
    expect(typeof params?.['hits']).toBe('number');
    // characterName should match the character we created
    expect(params?.['characterName']).toContain(`Tariq-${run}`);
  });

  it('3 — member_left system message created when player leaves session', async () => {
    if (!backendUp) return;

    // Leave runs last so the player is still active for the roll test above.
    await leaveSession(paToken, sessionId, paMembershipId);

    const msg = await pollForSystemMessage(
      gmToken,
      sessionId,
      (m) =>
        m['kind'] === 'system' &&
        m['systemKey'] === 'chat.system.member_left' &&
        (m['systemParams'] as Record<string, unknown>)?.['displayName'] === playerDisplayName,
    );

    expect(msg['kind']).toBe('system');
    expect(msg['systemKey']).toBe('chat.system.member_left');
    expect((msg['systemParams'] as Record<string, unknown>)?.['displayName']).toBe(
      playerDisplayName,
    );
  });
});

// ─── Encounter lifecycle system messages ─────────────────────────────────────

/**
 * These tests share a fresh game session (GM-only — no player invite needed)
 * and a single encounter that progresses: setup → active → round 2 → ended.
 * Each transition produces one system message in the broadcast channel.
 *
 * The encounter tests are isolated from the join/leave suite above to avoid
 * ordering dependencies (the beforeAll there finishes with a left player).
 */

let encounterGmToken = '';
let encounterSessionId = '';
let encounterId = '';
let encounterBackendUp = false;

beforeAll(async () => {
  encounterBackendUp = backendUp;
  if (!encounterBackendUp) return;

  const gm = await signUp(`sysmsg-enc-gm-${run}@e2e.test`, 'Test1234!', `EncSysMsgGM-${run}`);
  encounterGmToken = gm.token;

  encounterSessionId = await createSession(encounterGmToken, `EncSysMsg E2E — ${run}`);
  const inv = await rotateInvite(encounterGmToken, encounterSessionId);
  await acceptInvite(encounterGmToken, inv);

  encounterId = await createEncounter(encounterGmToken, encounterSessionId);
  await addCombatant(encounterGmToken, encounterId);
}, 30_000);

describe('Chat system messages — encounter lifecycle (follow-up #11)', () => {
  it('4 — encounter_started system message created when encounter transitions setup → active', async () => {
    if (!encounterBackendUp) return;

    await updateEncounterStatus(encounterGmToken, encounterId, 'active');

    const msg = await pollForSystemMessage(
      encounterGmToken,
      encounterSessionId,
      (m) => m['kind'] === 'system' && m['systemKey'] === 'chat.system.encounter_started',
    );

    expect(msg['kind']).toBe('system');
    expect(msg['systemKey']).toBe('chat.system.encounter_started');
    expect(msg['body']).toBeNull();
    expect(msg['authorMembershipId']).toBeNull();
    expect(msg['targetMembershipId']).toBeNull();
  });

  it('5 — round_advanced system message created when GM advances round', async () => {
    if (!encounterBackendUp) return;

    // Roll initiative first so activeCombatantId is set (required by AdvanceRoundHandler)
    await rollInitiative(encounterGmToken, encounterId);
    const newRound = await advanceRound(encounterGmToken, encounterId);

    const msg = await pollForSystemMessage(
      encounterGmToken,
      encounterSessionId,
      (m) =>
        m['kind'] === 'system' &&
        m['systemKey'] === 'chat.system.round_advanced' &&
        (m['systemParams'] as Record<string, unknown>)?.['round'] === newRound,
    );

    expect(msg['kind']).toBe('system');
    expect(msg['systemKey']).toBe('chat.system.round_advanced');
    expect((msg['systemParams'] as Record<string, unknown>)?.['round']).toBe(newRound);
  });

  it('6 — encounter_ended system message created when encounter transitions active → ended', async () => {
    if (!encounterBackendUp) return;

    await updateEncounterStatus(encounterGmToken, encounterId, 'ended');

    const msg = await pollForSystemMessage(
      encounterGmToken,
      encounterSessionId,
      (m) => m['kind'] === 'system' && m['systemKey'] === 'chat.system.encounter_ended',
    );

    expect(msg['kind']).toBe('system');
    expect(msg['systemKey']).toBe('chat.system.encounter_ended');
    expect(msg['body']).toBeNull();
    expect(msg['authorMembershipId']).toBeNull();
    expect(msg['targetMembershipId']).toBeNull();
  });
});
