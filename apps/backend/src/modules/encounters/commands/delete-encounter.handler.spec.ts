/**
 * Unit tests for DeleteEncounterHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { EncounterAccessDeniedError, EncounterNotFoundError } from '../domain/encounter.errors';

import { DeleteEncounterCommand } from './delete-encounter.command';
import { DeleteEncounterHandler } from './delete-encounter.handler';

import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type { EncounterReadModel, IEncounterRepo } from '../domain/encounter.ports';

function makeRepo(): IEncounterRepo {
  return {
    findById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
  };
}

function makeAccess(): IGameSessionAccess {
  return {
    isOwner: vi.fn(),
    isMember: vi.fn(),
    getOwnerId: vi.fn(),
  };
}

function makeEncounter(overrides: Partial<EncounterReadModel> = {}): EncounterReadModel {
  return {
    id: 'enc-1',
    gameSessionId: 'gs-1',
    name: 'Ambush',
    notes: null,
    status: 'setup',
    round: 0,
    activeCombatantId: null,
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

describe('DeleteEncounterHandler', () => {
  let repo: IEncounterRepo;
  let access: IGameSessionAccess;
  let handler: DeleteEncounterHandler;

  beforeEach(() => {
    repo = makeRepo();
    access = makeAccess();
    handler = new DeleteEncounterHandler(repo, access);
    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
  });

  it('deletes an encounter when caller is GM owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());

    await handler.execute(new DeleteEncounterCommand('enc-1', 'user-1'));

    expect(repo.delete).toHaveBeenCalledWith('enc-1');
  });

  it('throws EncounterNotFoundError when encounter does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new DeleteEncounterCommand('enc-missing', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
    expect(repo.delete).not.toHaveBeenCalled();
  });

  it('throws EncounterNotFoundError (404) when session gone', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue(null);

    await expect(
      handler.execute(new DeleteEncounterCommand('enc-1', 'user-1')),
    ).rejects.toMatchObject({ status: 404 });
    expect(repo.delete).not.toHaveBeenCalled();
  });

  it('throws EncounterAccessDeniedError when caller is not GM owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue('owner-1');

    await expect(
      handler.execute(new DeleteEncounterCommand('enc-1', 'other-user')),
    ).rejects.toBeInstanceOf(EncounterAccessDeniedError);
    expect(repo.delete).not.toHaveBeenCalled();
  });

  it('EncounterAccessDeniedError has status 403', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue('owner-1');

    await expect(
      handler.execute(new DeleteEncounterCommand('enc-1', 'other-user')),
    ).rejects.toMatchObject({ code: 'ENCOUNTER_ACCESS_DENIED', status: 403 });
  });

  it('does NOT publish combat.updated on delete (encounter no longer exists after deletion)', async () => {
    // combat.updated is deliberately skipped for delete-encounter.
    // The encounter row is gone; any snapshot would reference a deleted resource.
    // Clients discover deletion via the next GET /encounters/{id} → 404.
    // No publish infrastructure is injected into this handler.
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());

    // If the handler mistakenly tried to publish, it would fail at construction
    // (no COMBAT_PUBLISHER injected). The test just verifies the happy path completes.
    await expect(
      handler.execute(new DeleteEncounterCommand('enc-1', 'user-1')),
    ).resolves.toBeUndefined();
    expect(repo.delete).toHaveBeenCalledWith('enc-1');
  });
});
