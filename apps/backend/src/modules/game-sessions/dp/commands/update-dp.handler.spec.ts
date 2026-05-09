/**
 * Unit tests for UpdateDpHandler.
 *
 * Covers T-7.3.1.b acceptance criteria:
 *  - Positive delta from GM owner persists DpEvent with source GM_MANUAL.
 *  - Negative delta from GM owner succeeds.
 *  - Negative delta from non-owner → 403 GAME_SESSION_NOT_OWNER.
 *  - delta == 0 → 422 DP_INVALID_DELTA.
 *  - Would go below zero → 422 DP_BELOW_ZERO.
 *  - Internal caller (source ROLL_PUSH) bypasses GM-owner ACL.
 *
 * T-7.4.1.c: dp.changed is published to Centrifugo after a successful write;
 *  a publish failure does not roll back the DB result.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  GameSessionNotFoundError,
  GameSessionNotOwnerError,
} from '../../domain/game-session.errors';
import { DpBelowZeroError, DpInvalidDeltaError } from '../domain/dp.errors';
import { UpdateDpCommand } from './update-dp.command';
import { UpdateDpHandler } from './update-dp.handler';

import type { GameSessionReadModel, IGameSessionRepo } from '../../domain/game-session.ports';
import type { ICentrifugoClient } from '../../../realtime/centrifugo.client';
import type { IDpRepo } from '../domain/dp.ports';

function makeSessionRepo(): IGameSessionRepo {
  return {
    findById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    assignCharacter: vi.fn(),
    unassignCharacter: vi.fn(),
  };
}

function makeDpRepo(): IDpRepo {
  return {
    applyDelta: vi.fn().mockResolvedValue(0),
    listEvents: vi.fn(),
  };
}

function makeCentrifugoClient(): ICentrifugoClient {
  return { publish: vi.fn().mockResolvedValue(undefined) };
}

function makeSession(overrides: Partial<GameSessionReadModel> = {}): GameSessionReadModel {
  return {
    id: 'gs-1',
    ownerId: 'user-gm',
    name: 'The Long Night',
    description: null,
    status: 'active',
    dpCount: 3,
    characterIds: [],
    shipId: null,
    createdAt: '2026-05-09T10:00:00.000Z',
    updatedAt: '2026-05-09T10:00:00.000Z',
    ...overrides,
  };
}

describe('UpdateDpHandler', () => {
  let sessionRepo: IGameSessionRepo;
  let dpRepo: IDpRepo;
  let centrifugo: ICentrifugoClient;
  let handler: UpdateDpHandler;

  beforeEach(() => {
    sessionRepo = makeSessionRepo();
    dpRepo = makeDpRepo();
    centrifugo = makeCentrifugoClient();
    handler = new UpdateDpHandler(sessionRepo, dpRepo, centrifugo);
  });

  it('adds DP and returns updated session (GM_MANUAL +5)', async () => {
    const session = makeSession({ dpCount: 3 });
    const updated = makeSession({ dpCount: 8 });
    vi.mocked(sessionRepo.findById).mockResolvedValueOnce(session).mockResolvedValueOnce(updated);
    vi.mocked(dpRepo.applyDelta).mockResolvedValue(8);

    const result = await handler.execute(
      new UpdateDpCommand('gs-1', 'user-gm', 5, 'GM_MANUAL', 'manual fudge'),
    );

    expect(dpRepo.applyDelta).toHaveBeenCalledWith({
      gameSessionId: 'gs-1',
      delta: 5,
      reason: 'manual fudge',
      source: 'GM_MANUAL',
      rollId: null,
    });
    expect(result.dpCount).toBe(8);
  });

  it('publishes dp.changed with correct shape after successful write', async () => {
    const session = makeSession({ dpCount: 3 });
    const updated = makeSession({ dpCount: 8 });
    vi.mocked(sessionRepo.findById).mockResolvedValueOnce(session).mockResolvedValueOnce(updated);
    vi.mocked(dpRepo.applyDelta).mockResolvedValue(8);

    await handler.execute(new UpdateDpCommand('gs-1', 'user-gm', 5, 'GM_MANUAL', null));

    expect(centrifugo.publish).toHaveBeenCalledOnce();
    const [channel, data] = (centrifugo.publish as ReturnType<typeof vi.fn>).mock.calls[0] as [
      string,
      Record<string, unknown>,
    ];
    expect(channel).toBe('session.gs-1');
    expect(data).toMatchObject({
      gameSessionId: 'gs-1',
      dpCount: 8,
      delta: 5,
      source: 'gm-manual',
    });
    expect(typeof data['at']).toBe('string');
  });

  it('does not roll back DB result when publish throws', async () => {
    const session = makeSession({ dpCount: 3 });
    const updated = makeSession({ dpCount: 4 });
    vi.mocked(sessionRepo.findById).mockResolvedValueOnce(session).mockResolvedValueOnce(updated);
    vi.mocked(dpRepo.applyDelta).mockResolvedValue(4);
    vi.mocked(centrifugo.publish).mockRejectedValue(new Error('centrifugo down'));

    // Must not reject — DB write was successful
    const result = await handler.execute(
      new UpdateDpCommand('gs-1', 'user-gm', 1, 'GM_MANUAL', null),
    );
    expect(result.dpCount).toBe(4);
  });

  it('removes DP by GM owner (GM_MANUAL -3)', async () => {
    const session = makeSession({ dpCount: 5 });
    const updated = makeSession({ dpCount: 2 });
    vi.mocked(sessionRepo.findById).mockResolvedValueOnce(session).mockResolvedValueOnce(updated);
    vi.mocked(dpRepo.applyDelta).mockResolvedValue(2);

    const result = await handler.execute(
      new UpdateDpCommand('gs-1', 'user-gm', -3, 'GM_MANUAL', null),
    );

    expect(dpRepo.applyDelta).toHaveBeenCalledWith(
      expect.objectContaining({ delta: -3, source: 'GM_MANUAL' }),
    );
    expect(result.dpCount).toBe(2);
  });

  it('throws DP_INVALID_DELTA when delta is 0', async () => {
    await expect(
      handler.execute(new UpdateDpCommand('gs-1', 'user-gm', 0, 'GM_MANUAL', null)),
    ).rejects.toBeInstanceOf(DpInvalidDeltaError);
    expect(dpRepo.applyDelta).not.toHaveBeenCalled();
    expect(centrifugo.publish).not.toHaveBeenCalled();
  });

  it('throws GAME_SESSION_NOT_FOUND when session does not exist', async () => {
    vi.mocked(sessionRepo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new UpdateDpCommand('gs-missing', 'user-gm', 1, 'GM_MANUAL', null)),
    ).rejects.toBeInstanceOf(GameSessionNotFoundError);
  });

  it('throws GAME_SESSION_NOT_OWNER when non-owner applies negative delta', async () => {
    vi.mocked(sessionRepo.findById).mockResolvedValue(makeSession({ ownerId: 'other-gm' }));

    await expect(
      handler.execute(new UpdateDpCommand('gs-1', 'user-gm', -1, 'GM_MANUAL', null)),
    ).rejects.toBeInstanceOf(GameSessionNotOwnerError);
    expect(dpRepo.applyDelta).not.toHaveBeenCalled();
  });

  it('allows positive delta from non-owner (HTTP callers are always the owner; test confirms ACL is only on negative)', async () => {
    const session = makeSession({ ownerId: 'other-gm', dpCount: 2 });
    const updated = makeSession({ ownerId: 'other-gm', dpCount: 3 });
    vi.mocked(sessionRepo.findById).mockResolvedValueOnce(session).mockResolvedValueOnce(updated);
    vi.mocked(dpRepo.applyDelta).mockResolvedValue(3);

    // Positive delta from a non-owner — not blocked by ACL
    await expect(
      handler.execute(new UpdateDpCommand('gs-1', 'user-gm', 1, 'GM_MANUAL', null)),
    ).resolves.toBeDefined();
    expect(dpRepo.applyDelta).toHaveBeenCalled();
  });

  it('throws DP_BELOW_ZERO when delta would take dpCount negative', async () => {
    vi.mocked(sessionRepo.findById).mockResolvedValue(makeSession({ dpCount: 2 }));

    await expect(
      handler.execute(new UpdateDpCommand('gs-1', 'user-gm', -5, 'GM_MANUAL', null)),
    ).rejects.toBeInstanceOf(DpBelowZeroError);
    expect(dpRepo.applyDelta).not.toHaveBeenCalled();
  });

  it('internal=true ROLL_PUSH bypasses GM-owner ACL on negative delta', async () => {
    // Even a negative delta from a non-owner is allowed when internal=true
    const session = makeSession({ ownerId: 'different-gm', dpCount: 5 });
    const updated = makeSession({ ownerId: 'different-gm', dpCount: 4 });
    vi.mocked(sessionRepo.findById).mockResolvedValueOnce(session).mockResolvedValueOnce(updated);
    vi.mocked(dpRepo.applyDelta).mockResolvedValue(4);

    await expect(
      handler.execute(new UpdateDpCommand('gs-1', 'system', -1, 'ROLL_PUSH', null, true, 'roll-1')),
    ).resolves.toBeDefined();
    expect(dpRepo.applyDelta).toHaveBeenCalledWith(
      expect.objectContaining({ source: 'ROLL_PUSH', rollId: 'roll-1' }),
    );
  });

  it('internal=true ROLL_PUSH +1 sets source ROLL_PUSH and passes rollId', async () => {
    const session = makeSession({ dpCount: 0 });
    const updated = makeSession({ dpCount: 1 });
    vi.mocked(sessionRepo.findById).mockResolvedValueOnce(session).mockResolvedValueOnce(updated);
    vi.mocked(dpRepo.applyDelta).mockResolvedValue(1);

    await handler.execute(
      new UpdateDpCommand('gs-1', 'system', 1, 'ROLL_PUSH', 'Roll pushed', true, 'roll-42'),
    );

    expect(dpRepo.applyDelta).toHaveBeenCalledWith({
      gameSessionId: 'gs-1',
      delta: 1,
      reason: 'Roll pushed',
      source: 'ROLL_PUSH',
      rollId: 'roll-42',
    });
  });

  it('maps ROLL_PUSH source to roll-push in dp.changed publish', async () => {
    const session = makeSession({ dpCount: 0 });
    const updated = makeSession({ dpCount: 1 });
    vi.mocked(sessionRepo.findById).mockResolvedValueOnce(session).mockResolvedValueOnce(updated);
    vi.mocked(dpRepo.applyDelta).mockResolvedValue(1);

    await handler.execute(
      new UpdateDpCommand('gs-1', 'system', 1, 'ROLL_PUSH', null, true, 'roll-1'),
    );

    const [, data] = (centrifugo.publish as ReturnType<typeof vi.fn>).mock.calls[0] as [
      string,
      Record<string, unknown>,
    ];
    expect(data['source']).toBe('roll-push');
  });
});
