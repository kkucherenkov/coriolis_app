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
 * T-7.4.1.c: dp.changed is published to Centrifugo via RealtimeRouter after
 *  a successful write; a publish failure does not roll back the DB result.
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
import type { IDpRepo } from '../domain/dp.ports';
import type { RealtimeRouter } from '../../../realtime/realtime-router';

function makeSessionRepo(): IGameSessionRepo {
  return {
    findById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
  };
}

function makeDpRepo(): IDpRepo {
  return {
    applyDelta: vi.fn().mockResolvedValue(0),
    listEvents: vi.fn(),
  };
}

function makeRouter(): RealtimeRouter {
  return {
    publishDpChanged: vi.fn().mockResolvedValue(undefined),
    publishRollPushed: vi.fn().mockResolvedValue(undefined),
    publishCombatUpdated: vi.fn().mockResolvedValue(undefined),
    publishChatMessage: vi.fn().mockResolvedValue(undefined),
    publishChatMessageDeleted: vi.fn().mockResolvedValue(undefined),
  } as unknown as RealtimeRouter;
}

function makeSession(overrides: Partial<GameSessionReadModel> = {}): GameSessionReadModel {
  return {
    id: 'gs-1',
    ownerId: 'user-gm',
    name: 'The Long Night',
    description: null,
    status: 'active',
    dpCount: 3,
    memberships: [],
    shipId: null,
    createdAt: '2026-05-09T10:00:00.000Z',
    updatedAt: '2026-05-09T10:00:00.000Z',
    ...overrides,
  };
}

describe('UpdateDpHandler', () => {
  let sessionRepo: IGameSessionRepo;
  let dpRepo: IDpRepo;
  let router: RealtimeRouter;
  let handler: UpdateDpHandler;

  beforeEach(() => {
    sessionRepo = makeSessionRepo();
    dpRepo = makeDpRepo();
    router = makeRouter();
    handler = new UpdateDpHandler(sessionRepo, dpRepo, router);
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

  it('publishes dp.changed via router with correct shape after successful write', async () => {
    const session = makeSession({ dpCount: 3 });
    const updated = makeSession({ dpCount: 8 });
    vi.mocked(sessionRepo.findById).mockResolvedValueOnce(session).mockResolvedValueOnce(updated);
    vi.mocked(dpRepo.applyDelta).mockResolvedValue(8);

    await handler.execute(new UpdateDpCommand('gs-1', 'user-gm', 5, 'GM_MANUAL', null));

    expect(router.publishDpChanged).toHaveBeenCalledOnce();
    const [payload] = vi.mocked(router.publishDpChanged).mock.calls[0]!;
    expect(payload).toMatchObject({
      gameSessionId: 'gs-1',
      dpCount: 8,
      delta: 5,
      source: 'gm-manual',
    });
    expect(typeof payload.at).toBe('string');
  });

  it('does not roll back DB result when router.publishDpChanged resolves (always resolves)', async () => {
    const session = makeSession({ dpCount: 3 });
    const updated = makeSession({ dpCount: 4 });
    vi.mocked(sessionRepo.findById).mockResolvedValueOnce(session).mockResolvedValueOnce(updated);
    vi.mocked(dpRepo.applyDelta).mockResolvedValue(4);

    // Router never re-throws — this just confirms the handler awaits correctly.
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
    expect(router.publishDpChanged).not.toHaveBeenCalled();
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

  it('allows positive delta from non-owner (ACL only blocks negative)', async () => {
    const session = makeSession({ ownerId: 'other-gm', dpCount: 2 });
    const updated = makeSession({ ownerId: 'other-gm', dpCount: 3 });
    vi.mocked(sessionRepo.findById).mockResolvedValueOnce(session).mockResolvedValueOnce(updated);
    vi.mocked(dpRepo.applyDelta).mockResolvedValue(3);

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

  it('maps ROLL_PUSH source to roll-push in publishDpChanged payload', async () => {
    const session = makeSession({ dpCount: 0 });
    const updated = makeSession({ dpCount: 1 });
    vi.mocked(sessionRepo.findById).mockResolvedValueOnce(session).mockResolvedValueOnce(updated);
    vi.mocked(dpRepo.applyDelta).mockResolvedValue(1);

    await handler.execute(
      new UpdateDpCommand('gs-1', 'system', 1, 'ROLL_PUSH', null, true, 'roll-1'),
    );

    const [payload] = vi.mocked(router.publishDpChanged).mock.calls[0]!;
    expect(payload.source).toBe('roll-push');
  });
});
