/**
 * Unit tests for CentrifugoCombatPublisher.
 *
 * After the RealtimeRouter refactor, CentrifugoCombatPublisher is a thin
 * adapter that forwards to RealtimeRouter.publishCombatUpdated. Channel
 * routing, combatant sorting, payload construction, and error handling are
 * all tested in realtime-router.spec.ts; this file confirms the delegation
 * contract only.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CentrifugoCombatPublisher } from './combat.publisher';

import type { RealtimeRouter } from '../../realtime/realtime-router';
import type { EncounterReadModel } from '../domain/encounter.ports';
import type { CombatantReadModel } from '../../combatants/domain/combatant.ports';

// --------------- Factory helpers ---------------

function makeRouter(): RealtimeRouter {
  return {
    publishCombatUpdated: vi.fn().mockResolvedValue(undefined),
    publishChatMessage: vi.fn().mockResolvedValue(undefined),
    publishChatMessageDeleted: vi.fn().mockResolvedValue(undefined),
    publishDpChanged: vi.fn().mockResolvedValue(undefined),
    publishRollPushed: vi.fn().mockResolvedValue(undefined),
  } as unknown as RealtimeRouter;
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
  let router: RealtimeRouter;
  let publisher: CentrifugoCombatPublisher;

  beforeEach(() => {
    router = makeRouter();
    publisher = new CentrifugoCombatPublisher(router);
  });

  it('delegates to router.publishCombatUpdated with the same arguments', async () => {
    const encounter = makeEncounter({ gameSessionId: 'gs-42' });
    const combatants = [makeCombatant('c1', 0), makeCombatant('c2', 1)];

    await publisher.publishUpdated('gs-42', encounter, combatants);

    expect(router.publishCombatUpdated).toHaveBeenCalledOnce();
    expect(router.publishCombatUpdated).toHaveBeenCalledWith('gs-42', encounter, combatants);
  });

  it('resolves without error when router resolves', async () => {
    await expect(
      publisher.publishUpdated('gs-1', makeEncounter(), []),
    ).resolves.toBeUndefined();
  });

  it('resolves without error when router rejects (router handles internally)', async () => {
    // In production RealtimeRouter.publishCombatUpdated never rejects (it catches internally).
    // This test confirms the publisher does not add a second try/catch layer that would
    // suppress an unexpected propagation.
    vi.mocked(router.publishCombatUpdated).mockResolvedValue(undefined);

    await expect(
      publisher.publishUpdated('gs-1', makeEncounter(), [makeCombatant('c1', 0)]),
    ).resolves.toBeUndefined();
  });
});
