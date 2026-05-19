/**
 * useSessionPresence.spec.ts
 *
 * Tests for the Centrifugo presence composable.
 *
 * Strategy:
 *   - Centrifuge (the WebSocket client) is vi.mock'd so no real socket is
 *     opened. The mock captures the event handlers registered via
 *     `subscription.on(...)` so tests can fire them programmatically.
 *   - `issueRealtimeToken` is also mocked to return a fixed token string.
 *   - `useRuntimeConfig` is stubbed via Nuxt's auto-import mechanism; since
 *     we're in a plain Vitest env (no Nuxt context) we stub it globally.
 *
 * Covers:
 *   1. Initial `presence()` snapshot — only matching-session membershipId added.
 *   2. `join` event — membershipId added.
 *   3. `leave` event — membershipId removed once all client_ids for it leave.
 *   4. Multi-client: same membershipId from two client_ids — still online after
 *      first client leaves; offline only after second client leaves.
 *   5. Malformed connInfo variants → entry skipped silently, no throw.
 *   6. `stop()` clears the set.
 */

import { beforeEach, afterEach, describe, it, expect, vi } from 'vitest';

// ─── Stubs for Nuxt auto-imports ──────────────────────────────────────────────

vi.stubGlobal('useRuntimeConfig', () => ({
  public: { realtimeWsUrl: 'ws://localhost:8000' },
}));

// ─── SDK mock ─────────────────────────────────────────────────────────────────

vi.mock('@app/api-client-ts', () => ({
  issueRealtimeToken: vi.fn(),
}));

import { issueRealtimeToken } from '@app/api-client-ts';

// ─── Centrifuge mock ──────────────────────────────────────────────────────────
//
// We need fine-grained control over:
//   - `sub.on('subscribed', handler)` — triggered in tests to initiate presence fetch
//   - `sub.on('join', handler)` — triggered to simulate joins
//   - `sub.on('leave', handler)` — triggered to simulate leaves
//   - `sub.presence()` — returns a Promise we resolve in tests

interface SubscriptionHandlers {
  subscribed?: () => void;
  join?: (ctx: unknown) => void;
  leave?: (ctx: unknown) => void;
}

let capturedHandlers: SubscriptionHandlers = {};
let presenceResolve: ((r: { clients: Record<string, unknown> }) => void) | null = null;
let presenceReject: ((reason?: unknown) => void) | null = null;

const mockSubscription = {
  on: vi.fn((event: string, handler: (...args: unknown[]) => void) => {
    if (event === 'subscribed') capturedHandlers.subscribed = handler as () => void;
    if (event === 'join') capturedHandlers.join = handler as (ctx: unknown) => void;
    if (event === 'leave') capturedHandlers.leave = handler as (ctx: unknown) => void;
    return mockSubscription;
  }),
  subscribe: vi.fn(),
  presence: vi.fn(() => {
    return new Promise<{ clients: Record<string, unknown> }>((resolve, reject) => {
      presenceResolve = resolve;
      presenceReject = reject;
    });
  }),
};

const mockCentrifuge = {
  on: vi.fn(),
  newSubscription: vi.fn(() => mockSubscription),
  connect: vi.fn(),
  disconnect: vi.fn(),
};

vi.mock('centrifuge', () => ({
  // vitest 4.x: `vi.fn(() => obj)` constructors with `new` do not return `obj`.
  // Use a class with a constructor that returns the mock instance instead.
  Centrifuge: class {
    constructor() {
      return mockCentrifuge as never;
    }
  },
}));

// ─── Import after mocks ───────────────────────────────────────────────────────

import { useSessionPresence } from '../../app/composables/useSessionPresence';

// ─── Helpers ──────────────────────────────────────────────────────────────────

const SESSION_A = 'session-aaa';
const SESSION_B = 'session-bbb';

function makeClientInfo(clientId: string, gameSessionId: string, membershipId: string) {
  return {
    client: clientId,
    user: 'user-x',
    connInfo: {
      memberships: [{ gameSessionId, membershipId }],
    },
  };
}

/** Drain all pending microtasks (multiple Promise.resolve passes). */
async function flushMicrotasks(passes = 5): Promise<void> {
  for (let i = 0; i < passes; i++) {
    await Promise.resolve();
  }
}

/** Fire the 'subscribed' handler and resolve presence() with the given snapshot. */
async function triggerSubscribedWithSnapshot(
  clients: Record<string, ReturnType<typeof makeClientInfo>>,
): Promise<void> {
  // Trigger the subscribed handler — this schedules the async IIFE which
  // will call sub.presence() internally.
  capturedHandlers.subscribed?.();
  // Drain enough microtasks for the async IIFE to reach the `await sub.presence()` call.
  await flushMicrotasks(2);
  // Resolve the presence() promise.
  presenceResolve?.({ clients });
  // Drain microtasks again so the async IIFE can proceed past the await.
  await flushMicrotasks(3);
}

// ─── Tests ────────────────────────────────────────────────────────────────────

describe('useSessionPresence', () => {
  beforeEach(() => {
    capturedHandlers = {};
    presenceResolve = null;
    presenceReject = null;

    // Reset mock state
    mockSubscription.on.mockClear();
    mockSubscription.subscribe.mockClear();
    mockSubscription.presence.mockClear();
    mockCentrifuge.on.mockClear();
    mockCentrifuge.newSubscription.mockClear();
    mockCentrifuge.connect.mockClear();
    mockCentrifuge.disconnect.mockClear();

    // Restore presence mock to capture resolve/reject
    mockSubscription.presence.mockImplementation(() => {
      return new Promise<{ clients: Record<string, unknown> }>((resolve, reject) => {
        presenceResolve = resolve;
        presenceReject = reject;
      });
    });

    vi.mocked(issueRealtimeToken).mockResolvedValue({
      data: { token: 'test-token' },
      error: undefined,
    } as never);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  // ── 1. Initial presence snapshot ──────────────────────────────────────────

  it('populates onlineSet from presence snapshot — filters to matching session', async () => {
    const handle = useSessionPresence(SESSION_A);
    await handle.start();

    await triggerSubscribedWithSnapshot({
      'client-1': makeClientInfo('client-1', SESSION_A, 'member-alice'),
      'client-2': makeClientInfo('client-2', SESSION_B, 'member-bob'), // different session
      'client-3': makeClientInfo('client-3', SESSION_A, 'member-charlie'),
    });

    expect(handle.onlineSet.value.has('member-alice')).toBe(true);
    expect(handle.onlineSet.value.has('member-charlie')).toBe(true);
    expect(handle.onlineSet.value.has('member-bob')).toBe(false); // filtered out
    expect(handle.onlineSet.value.size).toBe(2);

    handle.stop();
  });

  // ── 2. join event ─────────────────────────────────────────────────────────

  it('adds membershipId to set on join event', async () => {
    const handle = useSessionPresence(SESSION_A);
    await handle.start();
    await triggerSubscribedWithSnapshot({});

    capturedHandlers.join?.({
      channel: `session.${SESSION_A}`,
      info: makeClientInfo('client-1', SESSION_A, 'member-alice'),
    });

    expect(handle.onlineSet.value.has('member-alice')).toBe(true);

    handle.stop();
  });

  // ── 3. leave event (single client) ───────────────────────────────────────

  it('removes membershipId from set on leave event (single client)', async () => {
    const handle = useSessionPresence(SESSION_A);
    await handle.start();
    await triggerSubscribedWithSnapshot({
      'client-1': makeClientInfo('client-1', SESSION_A, 'member-alice'),
    });

    expect(handle.onlineSet.value.has('member-alice')).toBe(true);

    capturedHandlers.leave?.({
      channel: `session.${SESSION_A}`,
      info: makeClientInfo('client-1', SESSION_A, 'member-alice'),
    });

    expect(handle.onlineSet.value.has('member-alice')).toBe(false);

    handle.stop();
  });

  // ── 4. Multi-client: same membershipId from two client_ids ───────────────

  it('keeps membership online while ≥1 client_id remains; offline only after last client leaves', async () => {
    const handle = useSessionPresence(SESSION_A);
    await handle.start();
    await triggerSubscribedWithSnapshot({});

    // Alice joins from two devices
    capturedHandlers.join?.({
      channel: `session.${SESSION_A}`,
      info: makeClientInfo('client-phone', SESSION_A, 'member-alice'),
    });
    capturedHandlers.join?.({
      channel: `session.${SESSION_A}`,
      info: makeClientInfo('client-laptop', SESSION_A, 'member-alice'),
    });

    expect(handle.onlineSet.value.has('member-alice')).toBe(true);

    // Phone disconnects — still online because laptop is connected
    capturedHandlers.leave?.({
      channel: `session.${SESSION_A}`,
      info: makeClientInfo('client-phone', SESSION_A, 'member-alice'),
    });

    expect(handle.onlineSet.value.has('member-alice')).toBe(true);

    // Laptop disconnects — now offline
    capturedHandlers.leave?.({
      channel: `session.${SESSION_A}`,
      info: makeClientInfo('client-laptop', SESSION_A, 'member-alice'),
    });

    expect(handle.onlineSet.value.has('member-alice')).toBe(false);

    handle.stop();
  });

  // ── 5. Malformed connInfo variants ───────────────────────────────────────

  it('skips join entry silently when connInfo is missing', async () => {
    const handle = useSessionPresence(SESSION_A);
    await handle.start();
    await triggerSubscribedWithSnapshot({});

    const initialSize = handle.onlineSet.value.size;

    expect(() => {
      capturedHandlers.join?.({
        channel: `session.${SESSION_A}`,
        info: { client: 'client-bad', user: 'user-x', connInfo: undefined },
      });
    }).not.toThrow();

    expect(handle.onlineSet.value.size).toBe(initialSize);

    handle.stop();
  });

  it('skips join entry silently when connInfo.memberships is not an array', async () => {
    const handle = useSessionPresence(SESSION_A);
    await handle.start();
    await triggerSubscribedWithSnapshot({});

    expect(() => {
      capturedHandlers.join?.({
        channel: `session.${SESSION_A}`,
        info: {
          client: 'client-bad',
          user: 'user-x',
          connInfo: { memberships: 'not-an-array' },
        },
      });
    }).not.toThrow();

    expect(handle.onlineSet.value.size).toBe(0);

    handle.stop();
  });

  it('skips join entry silently when memberships item has wrong shape', async () => {
    const handle = useSessionPresence(SESSION_A);
    await handle.start();
    await triggerSubscribedWithSnapshot({});

    expect(() => {
      capturedHandlers.join?.({
        channel: `session.${SESSION_A}`,
        info: {
          client: 'client-bad',
          user: 'user-x',
          connInfo: { memberships: [{ gameSessionId: 42, membershipId: null }] },
        },
      });
    }).not.toThrow();

    expect(handle.onlineSet.value.size).toBe(0);

    handle.stop();
  });

  it('skips snapshot entry silently when connInfo is malformed', async () => {
    const handle = useSessionPresence(SESSION_A);
    await handle.start();

    // Snapshot with a mix of valid and malformed entries
    await triggerSubscribedWithSnapshot({
      'client-good': makeClientInfo('client-good', SESSION_A, 'member-alice'),
      'client-bad': { client: 'client-bad', user: 'user-y', connInfo: null } as never,
    });

    expect(handle.onlineSet.value.has('member-alice')).toBe(true);
    expect(handle.onlineSet.value.size).toBe(1);

    handle.stop();
  });

  // ── 6. stop() clears the set ──────────────────────────────────────────────

  it('stop() clears onlineSet and disconnects', async () => {
    const handle = useSessionPresence(SESSION_A);
    await handle.start();
    await triggerSubscribedWithSnapshot({
      'client-1': makeClientInfo('client-1', SESSION_A, 'member-alice'),
    });

    expect(handle.onlineSet.value.size).toBe(1);

    handle.stop();

    expect(handle.onlineSet.value.size).toBe(0);
    expect(mockCentrifuge.disconnect).toHaveBeenCalled();
  });

  // ── 7. Presence() rejection is non-fatal ─────────────────────────────────

  it('does not throw if presence() rejects', async () => {
    const handle = useSessionPresence(SESSION_A);
    await handle.start();

    capturedHandlers.subscribed?.();
    await flushMicrotasks(2);
    presenceReject?.(new Error('presence not available'));
    await flushMicrotasks(3);

    // set remains empty — no crash
    expect(handle.onlineSet.value.size).toBe(0);

    handle.stop();
  });
});
