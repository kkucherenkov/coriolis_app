/**
 * Unit tests for CentrifugoCombatPublisher.
 *
 * CENTRIFUGO_CLIENT is stubbed with a vi.fn() — no HTTP calls are made.
 * Verifies:
 *   - channel string: session.{gameSessionId}
 *   - payload shape: required fields present (gameSessionId, encounterId,
 *     encounter, combatants, at)
 *   - combatant mapping: displayName → name, sourceId → referenceId
 *   - sort order: combatants ordered by turnOrder ascending, nulls last
 *   - non-fatal: Logger.error is called when the client throws; no exception
 *     bubbles to the caller
 */
import { Logger } from '@nestjs/common';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CentrifugoCombatPublisher } from './combat.publisher';

import type { ICentrifugoClient } from '../../realtime/centrifugo.client';
import type { EncounterReadModel } from '../domain/encounter.ports';
import type { CombatantReadModel } from '../../combatants/domain/combatant.ports';

// --------------- Factory helpers ---------------

function makeClient(): ICentrifugoClient {
  return { publish: vi.fn().mockResolvedValue(undefined) };
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
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
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
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

// --------------- Tests ---------------

describe('CentrifugoCombatPublisher', () => {
  let client: ICentrifugoClient;
  let publisher: CentrifugoCombatPublisher;

  beforeEach(() => {
    client = makeClient();
    publisher = new CentrifugoCombatPublisher(client);
  });

  it('publishes to session.{gameSessionId} channel', async () => {
    await publisher.publishUpdated('gs-42', makeEncounter({ gameSessionId: 'gs-42' }), []);

    expect(client.publish).toHaveBeenCalledOnce();
    const [channel] = vi.mocked(client.publish).mock.calls[0]!;
    expect(channel).toBe('session.gs-42');
  });

  it('payload contains all required top-level fields', async () => {
    await publisher.publishUpdated('gs-1', makeEncounter(), []);

    const [, payload] = vi.mocked(client.publish).mock.calls[0]!;
    expect(payload).toMatchObject({
      gameSessionId: 'gs-1',
      encounterId: 'enc-1',
      encounter: expect.objectContaining({ id: 'enc-1' }),
      combatants: expect.any(Array),
      at: expect.any(String),
    });
  });

  it('encounter snapshot contains required sub-fields', async () => {
    const enc = makeEncounter();
    await publisher.publishUpdated('gs-1', enc, []);

    const [, payload] = vi.mocked(client.publish).mock.calls[0]!;
    const encounter = payload['encounter'] as Record<string, unknown>;
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
    const combatant = makeCombatant('c1', 0, {
      displayName: 'Zara al-Khatib',
      sourceId: 'char-99',
    });
    await publisher.publishUpdated('gs-1', makeEncounter(), [combatant]);

    const [, payload] = vi.mocked(client.publish).mock.calls[0]!;
    const items = payload['combatants'] as Record<string, unknown>[];
    expect(items).toHaveLength(1);
    expect(items[0]).toMatchObject({ name: 'Zara al-Khatib', referenceId: 'char-99' });
  });

  it('sorts combatants by turnOrder ascending', async () => {
    const c1 = makeCombatant('c1', 2);
    const c2 = makeCombatant('c2', 0);
    const c3 = makeCombatant('c3', 1);
    await publisher.publishUpdated('gs-1', makeEncounter(), [c1, c2, c3]);

    const [, payload] = vi.mocked(client.publish).mock.calls[0]!;
    const items = payload['combatants'] as Record<string, unknown>[];
    expect(items.map((i) => i['id'])).toEqual(['c2', 'c3', 'c1']);
  });

  it('places null-turnOrder combatants last', async () => {
    const c1 = makeCombatant('c1', null);
    const c2 = makeCombatant('c2', 0);
    await publisher.publishUpdated('gs-1', makeEncounter(), [c1, c2]);

    const [, payload] = vi.mocked(client.publish).mock.calls[0]!;
    const items = payload['combatants'] as Record<string, unknown>[];
    expect(items.map((i) => i['id'])).toEqual(['c2', 'c1']);
  });

  it('does not mutate the original combatants array (toSorted creates a copy)', async () => {
    const combatants = [makeCombatant('c1', 2), makeCombatant('c2', 0)];
    const originalOrder = combatants.map((c) => c.id);

    await publisher.publishUpdated('gs-1', makeEncounter(), combatants);

    expect(combatants.map((c) => c.id)).toEqual(originalOrder);
  });

  it('does not throw and calls Logger.error when centrifugo client rejects', async () => {
    vi.mocked(client.publish).mockRejectedValueOnce(new Error('Centrifugo unreachable'));

    // Spy on the Logger prototype to capture the error call without accessing private fields.
    const errorSpy = vi.spyOn(Logger.prototype, 'error');

    await expect(
      publisher.publishUpdated('gs-1', makeEncounter(), []),
    ).resolves.toBeUndefined();

    expect(errorSpy).toHaveBeenCalledOnce();
    expect(errorSpy.mock.calls[0]![0]).toContain('Failed to publish combat.updated');
  });

  it('publishes empty combatants array when encounter has no combatants', async () => {
    await publisher.publishUpdated('gs-1', makeEncounter(), []);

    const [, payload] = vi.mocked(client.publish).mock.calls[0]!;
    expect(payload['combatants']).toEqual([]);
  });

  it('at field is a valid ISO-8601 datetime string', async () => {
    await publisher.publishUpdated('gs-1', makeEncounter(), []);

    const [, payload] = vi.mocked(client.publish).mock.calls[0]!;
    const at = payload['at'] as string;
    expect(new Date(at).toISOString()).toBe(at);
  });
});
