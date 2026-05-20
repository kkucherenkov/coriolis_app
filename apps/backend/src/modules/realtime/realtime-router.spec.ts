/**
 * Unit tests for RealtimeRouter.
 *
 * Strategy: mock ICentrifugoClient.publish via vi.fn() — no real Centrifugo,
 * no NestJS bootstrap. Each test asserts:
 *  - correct channel name (string equality)
 *  - correct payload shape (toMatchObject / exact equality)
 *  - Centrifugo errors are caught + logged, not re-thrown
 *
 * Channel-name builder functions are also tested directly because they are
 * exported for use in contract tests.
 */
import { Logger } from '@nestjs/common';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import {
  RealtimeRouter,
  buildChatChannels,
  sessionChannel,
  sessionChatChannel,
  sessionMemberChannel,
} from './realtime-router';

import type { ICentrifugoClient } from './centrifugo.client';
import type { CombatantReadModel } from '../combatants/domain/combatant.ports';
import type { EncounterReadModel } from '../encounters/domain/encounter.ports';
import type { ChatMessageReadModel } from '../chat/domain/chat.ports';
import type {
  ChatMessageDeletedPayload,
  DpChangedPayload,
  RollPushedPayload,
} from './realtime-router';

// Restore Logger.prototype spies between tests so error-call counts don't accumulate.
afterEach(() => {
  vi.restoreAllMocks();
});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function makeClient(): ICentrifugoClient {
  return { publish: vi.fn().mockResolvedValue(undefined) };
}

function makeRouter(client: ICentrifugoClient): RealtimeRouter {
  return new RealtimeRouter(client);
}

function makeEncounter(overrides: Partial<EncounterReadModel> = {}): EncounterReadModel {
  return {
    id: 'enc-1',
    gameSessionId: 'gs-1',
    name: 'Ambush at Dock 7',
    notes: null,
    status: 'active',
    round: 1,
    activeCombatantId: 'comb-1',
    createdAt: '2026-05-20T10:00:00.000Z',
    updatedAt: '2026-05-20T10:00:00.000Z',
    ...overrides,
  };
}

function makeCombatant(
  id: string,
  turnOrder: number | null,
  overrides: Partial<CombatantReadModel> = {},
): CombatantReadModel {
  return {
    id,
    encounterId: 'enc-1',
    combatantType: 'pc',
    sourceId: `char-${id}`,
    displayName: `Fighter ${id}`,
    initiative: turnOrder === null ? null : 5,
    turnOrder,
    hpCurrent: 4,
    hpMax: 4,
    armor: 0,
    signature: 0,
    statusFlags: [],
    notes: null,
    createdAt: '2026-05-20T10:00:00.000Z',
    updatedAt: '2026-05-20T10:00:00.000Z',
    ...overrides,
  };
}

function makeChatMessage(overrides: Partial<ChatMessageReadModel> = {}): ChatMessageReadModel {
  return {
    id: 'msg-1',
    gameSessionId: 'gs-1',
    authorMembershipId: 'mem-author',
    authorDisplayName: 'Author',
    targetMembershipId: null,
    kind: 'text',
    body: 'Hello',
    systemKey: null,
    systemParams: null,
    createdAt: '2026-05-20T10:00:00.000Z',
    editedAt: null,
    deletedAt: null,
    ...overrides,
  };
}

// ---------------------------------------------------------------------------
// Channel-name builder functions
// ---------------------------------------------------------------------------

describe('channel-name builders', () => {
  it('sessionChannel builds session.{id}', () => {
    expect(sessionChannel('gs-42')).toBe('session.gs-42');
  });

  it('sessionChatChannel builds session.{id}.chat', () => {
    expect(sessionChatChannel('gs-42')).toBe('session.gs-42.chat');
  });

  it('sessionMemberChannel builds session.{id}.member.{membId}', () => {
    expect(sessionMemberChannel('gs-42', 'mem-99')).toBe('session.gs-42.member.mem-99');
  });
});

describe('buildChatChannels', () => {
  it('broadcast (targetMembershipId=null) → [session.<id>.chat]', () => {
    expect(buildChatChannels('gs-1', 'mem-author', null)).toEqual(['session.gs-1.chat']);
  });

  it('whisper → [session.<id>.member.<target>, session.<id>.member.<author>]', () => {
    const channels = buildChatChannels('gs-1', 'mem-author', 'mem-target');
    expect(channels).toHaveLength(2);
    expect(channels).toContain('session.gs-1.member.mem-target');
    expect(channels).toContain('session.gs-1.member.mem-author');
  });

  it('self-whisper (author === target) → [session.<id>.member.<self>] (deduplicated)', () => {
    const channels = buildChatChannels('gs-1', 'mem-self', 'mem-self');
    expect(channels).toHaveLength(1);
    expect(channels[0]).toBe('session.gs-1.member.mem-self');
  });

  it('whisper with null authorMembershipId → only target channel', () => {
    const channels = buildChatChannels('gs-1', null, 'mem-target');
    expect(channels).toEqual(['session.gs-1.member.mem-target']);
  });
});

// ---------------------------------------------------------------------------
// publishDpChanged
// ---------------------------------------------------------------------------

describe('RealtimeRouter.publishDpChanged', () => {
  let client: ICentrifugoClient;
  let router: RealtimeRouter;

  beforeEach(() => {
    client = makeClient();
    router = makeRouter(client);
  });

  it('publishes to session.{gameSessionId}', async () => {
    const payload: DpChangedPayload = {
      gameSessionId: 'gs-42',
      dpCount: 5,
      delta: 2,
      source: 'gm-manual',
      at: '2026-05-20T10:00:00.000Z',
    };

    await router.publishDpChanged(payload);

    expect(client.publish).toHaveBeenCalledOnce();
    const [channel] = vi.mocked(client.publish).mock.calls[0]!;
    expect(channel).toBe('session.gs-42');
  });

  it('payload contains all required fields', async () => {
    const payload: DpChangedPayload = {
      gameSessionId: 'gs-1',
      dpCount: 3,
      delta: 1,
      source: 'roll-push',
      at: '2026-05-20T10:00:00.000Z',
    };

    await router.publishDpChanged(payload);

    const [, data] = vi.mocked(client.publish).mock.calls[0]!;
    expect(data).toMatchObject({
      gameSessionId: 'gs-1',
      dpCount: 3,
      delta: 1,
      source: 'roll-push',
      at: '2026-05-20T10:00:00.000Z',
    });
  });

  it('Centrifugo error is caught + logged, not re-thrown', async () => {
    vi.mocked(client.publish).mockRejectedValue(new Error('centrifugo down'));
    const errorSpy = vi.spyOn(Logger.prototype, 'error');

    await expect(
      router.publishDpChanged({
        gameSessionId: 'gs-1',
        dpCount: 0,
        delta: -1,
        source: 'gm-manual',
        at: '2026-05-20T10:00:00.000Z',
      }),
    ).resolves.toBeUndefined();

    expect(errorSpy).toHaveBeenCalledOnce();
    expect(errorSpy.mock.calls[0]![0]).toContain('dp.changed');
  });
});

// ---------------------------------------------------------------------------
// publishRollPushed
// ---------------------------------------------------------------------------

describe('RealtimeRouter.publishRollPushed', () => {
  let client: ICentrifugoClient;
  let router: RealtimeRouter;

  beforeEach(() => {
    client = makeClient();
    router = makeRouter(client);
  });

  it('publishes to session.{gameSessionId}', async () => {
    const payload: RollPushedPayload = {
      rollId: 'roll-1',
      characterId: 'char-1',
      gameSessionId: 'gs-7',
      hits: 3,
      kind: 'skill',
      at: '2026-05-20T10:00:00.000Z',
    };

    await router.publishRollPushed(payload);

    const [channel] = vi.mocked(client.publish).mock.calls[0]!;
    expect(channel).toBe('session.gs-7');
  });

  it('payload contains rollId, characterId, gameSessionId, hits, kind, at', async () => {
    const payload: RollPushedPayload = {
      rollId: 'roll-99',
      characterId: 'char-99',
      gameSessionId: 'gs-1',
      hits: 2,
      kind: 'skill',
      at: '2026-05-20T10:00:00.000Z',
    };

    await router.publishRollPushed(payload);

    const [, data] = vi.mocked(client.publish).mock.calls[0]!;
    expect(data).toMatchObject({
      rollId: 'roll-99',
      characterId: 'char-99',
      gameSessionId: 'gs-1',
      hits: 2,
      kind: 'skill',
    });
  });

  it('Centrifugo error is caught + logged, not re-thrown', async () => {
    vi.mocked(client.publish).mockRejectedValue(new Error('timeout'));
    const errorSpy = vi.spyOn(Logger.prototype, 'error');

    await expect(
      router.publishRollPushed({
        rollId: 'r1',
        characterId: 'c1',
        gameSessionId: 'gs-1',
        hits: 1,
        kind: 'skill',
        at: '2026-05-20T10:00:00.000Z',
      }),
    ).resolves.toBeUndefined();

    expect(errorSpy).toHaveBeenCalledOnce();
    expect(errorSpy.mock.calls[0]![0]).toContain('roll.pushed');
  });
});

// ---------------------------------------------------------------------------
// publishCombatUpdated
// ---------------------------------------------------------------------------

describe('RealtimeRouter.publishCombatUpdated', () => {
  let client: ICentrifugoClient;
  let router: RealtimeRouter;

  beforeEach(() => {
    client = makeClient();
    router = makeRouter(client);
  });

  it('publishes to session.{gameSessionId}', async () => {
    await router.publishCombatUpdated('gs-42', makeEncounter({ gameSessionId: 'gs-42' }), []);

    const [channel] = vi.mocked(client.publish).mock.calls[0]!;
    expect(channel).toBe('session.gs-42');
  });

  it('payload contains all required top-level fields', async () => {
    await router.publishCombatUpdated('gs-1', makeEncounter(), []);

    const [, data] = vi.mocked(client.publish).mock.calls[0]!;
    expect(data).toMatchObject({
      gameSessionId: 'gs-1',
      encounterId: 'enc-1',
      encounter: expect.objectContaining({ id: 'enc-1' }),
      combatants: expect.any(Array),
      at: expect.any(String),
    });
  });

  it('encounter snapshot includes all required sub-fields', async () => {
    const enc = makeEncounter();
    await router.publishCombatUpdated('gs-1', enc, []);

    const [, data] = vi.mocked(client.publish).mock.calls[0]!;
    const encounter = (data as Record<string, unknown>)['encounter'] as Record<string, unknown>;
    expect(encounter).toMatchObject({
      id: enc.id,
      gameSessionId: enc.gameSessionId,
      name: enc.name,
      status: enc.status,
      round: enc.round,
      activeCombatantId: enc.activeCombatantId,
      createdAt: enc.createdAt,
      updatedAt: enc.updatedAt,
    });
  });

  it('maps displayName → name and sourceId → referenceId', async () => {
    const c = makeCombatant('c1', 0, { displayName: 'Zara al-Khatib', sourceId: 'char-99' });
    await router.publishCombatUpdated('gs-1', makeEncounter(), [c]);

    const [, data] = vi.mocked(client.publish).mock.calls[0]!;
    const items = (data as Record<string, unknown>)['combatants'] as Record<string, unknown>[];
    expect(items[0]).toMatchObject({ name: 'Zara al-Khatib', referenceId: 'char-99' });
  });

  it('sorts combatants by turnOrder ascending', async () => {
    const combatants = [makeCombatant('c1', 2), makeCombatant('c2', 0), makeCombatant('c3', 1)];
    await router.publishCombatUpdated('gs-1', makeEncounter(), combatants);

    const [, data] = vi.mocked(client.publish).mock.calls[0]!;
    const items = (data as Record<string, unknown>)['combatants'] as Record<string, unknown>[];
    expect(items.map((i) => i['id'])).toEqual(['c2', 'c3', 'c1']);
  });

  it('places null-turnOrder combatants last', async () => {
    const combatants = [makeCombatant('c1', null), makeCombatant('c2', 0)];
    await router.publishCombatUpdated('gs-1', makeEncounter(), combatants);

    const [, data] = vi.mocked(client.publish).mock.calls[0]!;
    const items = (data as Record<string, unknown>)['combatants'] as Record<string, unknown>[];
    expect(items.map((i) => i['id'])).toEqual(['c2', 'c1']);
  });

  it('does not mutate the original combatants array', async () => {
    const combatants = [makeCombatant('c1', 2), makeCombatant('c2', 0)];
    const originalOrder = combatants.map((c) => c.id);

    await router.publishCombatUpdated('gs-1', makeEncounter(), combatants);

    expect(combatants.map((c) => c.id)).toEqual(originalOrder);
  });

  it('Centrifugo error is caught + logged, not re-thrown', async () => {
    vi.mocked(client.publish).mockRejectedValue(new Error('Centrifugo unreachable'));
    const errorSpy = vi.spyOn(Logger.prototype, 'error');

    await expect(
      router.publishCombatUpdated('gs-1', makeEncounter(), []),
    ).resolves.toBeUndefined();

    expect(errorSpy).toHaveBeenCalledOnce();
    expect(errorSpy.mock.calls[0]![0]).toContain('combat.updated');
  });

  it('at field is a valid ISO-8601 datetime string', async () => {
    await router.publishCombatUpdated('gs-1', makeEncounter(), []);

    const [, data] = vi.mocked(client.publish).mock.calls[0]!;
    const at = (data as Record<string, unknown>)['at'] as string;
    expect(new Date(at).toISOString()).toBe(at);
  });
});

// ---------------------------------------------------------------------------
// publishChatMessage
// ---------------------------------------------------------------------------

describe('RealtimeRouter.publishChatMessage', () => {
  let client: ICentrifugoClient;
  let router: RealtimeRouter;

  beforeEach(() => {
    client = makeClient();
    router = makeRouter(client);
  });

  it('broadcast → 1 publish call to session.<id>.chat', async () => {
    const msg = makeChatMessage({ targetMembershipId: null });

    await router.publishChatMessage('gs-1', msg.authorMembershipId, null, msg);

    expect(client.publish).toHaveBeenCalledOnce();
    const [channel] = vi.mocked(client.publish).mock.calls[0]!;
    expect(channel).toBe('session.gs-1.chat');
  });

  it('whisper → 2 publish calls to both member channels with same payload ref', async () => {
    const msg = makeChatMessage({ authorMembershipId: 'mem-a', targetMembershipId: 'mem-b' });

    await router.publishChatMessage('gs-1', 'mem-a', 'mem-b', msg);

    expect(client.publish).toHaveBeenCalledTimes(2);
    const calls = vi.mocked(client.publish).mock.calls;
    const channels = calls.map(([ch]) => ch);
    expect(channels).toContain('session.gs-1.member.mem-a');
    expect(channels).toContain('session.gs-1.member.mem-b');
    // Same payload object — confirmed by same reference
    expect(calls[0]?.[1]).toBe(calls[1]?.[1]);
  });

  it('self-whisper → 1 publish call (deduplicated)', async () => {
    const msg = makeChatMessage({ authorMembershipId: 'mem-self', targetMembershipId: 'mem-self' });

    await router.publishChatMessage('gs-1', 'mem-self', 'mem-self', msg);

    expect(client.publish).toHaveBeenCalledOnce();
    const [channel] = vi.mocked(client.publish).mock.calls[0]!;
    expect(channel).toBe('session.gs-1.member.mem-self');
  });

  it('Centrifugo error is caught + logged, not re-thrown', async () => {
    vi.mocked(client.publish).mockRejectedValue(new Error('network failure'));
    const errorSpy = vi.spyOn(Logger.prototype, 'error');
    const msg = makeChatMessage({ targetMembershipId: null });

    await expect(
      router.publishChatMessage('gs-1', msg.authorMembershipId, null, msg),
    ).resolves.toBeUndefined();

    expect(errorSpy).toHaveBeenCalledOnce();
  });
});

// ---------------------------------------------------------------------------
// publishChatMessageDeleted
// ---------------------------------------------------------------------------

describe('RealtimeRouter.publishChatMessageDeleted', () => {
  let client: ICentrifugoClient;
  let router: RealtimeRouter;

  beforeEach(() => {
    client = makeClient();
    router = makeRouter(client);
  });

  it('broadcast deleted → 1 publish call to session.<id>.chat with tombstone payload', async () => {
    const payload: ChatMessageDeletedPayload = {
      id: 'msg-1',
      gameSessionId: 'gs-1',
      targetMembershipId: null,
      deletedAt: '2026-05-20T10:10:00.000Z',
    };

    await router.publishChatMessageDeleted('gs-1', 'mem-author', null, payload);

    expect(client.publish).toHaveBeenCalledOnce();
    const [channel, data] = vi.mocked(client.publish).mock.calls[0]!;
    expect(channel).toBe('session.gs-1.chat');
    expect(data).toMatchObject({
      id: 'msg-1',
      gameSessionId: 'gs-1',
      targetMembershipId: null,
    });
  });

  it('whisper deleted → 2 publish calls to both member channels', async () => {
    const payload: ChatMessageDeletedPayload = {
      id: 'msg-2',
      gameSessionId: 'gs-1',
      targetMembershipId: 'mem-target',
      deletedAt: '2026-05-20T10:10:00.000Z',
    };

    await router.publishChatMessageDeleted('gs-1', 'mem-author', 'mem-target', payload);

    expect(client.publish).toHaveBeenCalledTimes(2);
    const channels = vi.mocked(client.publish).mock.calls.map(([ch]) => ch);
    expect(channels).toContain('session.gs-1.member.mem-target');
    expect(channels).toContain('session.gs-1.member.mem-author');
  });

  it('Centrifugo error is caught + logged, not re-thrown', async () => {
    vi.mocked(client.publish).mockRejectedValue(new Error('timeout'));
    const errorSpy = vi.spyOn(Logger.prototype, 'error');

    await expect(
      router.publishChatMessageDeleted(
        'gs-1',
        'mem-author',
        null,
        { id: 'msg-1', gameSessionId: 'gs-1', targetMembershipId: null, deletedAt: '2026-05-20T10:00:00.000Z' },
      ),
    ).resolves.toBeUndefined();

    expect(errorSpy).toHaveBeenCalledOnce();
  });
});
