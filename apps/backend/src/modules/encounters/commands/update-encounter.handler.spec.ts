/**
 * Unit tests for UpdateEncounterHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  EncounterAccessDeniedError,
  EncounterInvalidTransitionError,
  EncounterNoCombatantsError,
  EncounterNotFoundError,
} from '../domain/encounter.errors';

import { UpdateEncounterCommand, UpdateEncounterDto } from './update-encounter.command';
import { UpdateEncounterHandler } from './update-encounter.handler';

import type { EventBus } from '@nestjs/cqrs';
import type {
  ICombatantCount,
  ICombatantRepo,
} from '../../../modules/combatants/domain/combatant.ports';
import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type { EncounterReadModel, IEncounterRepo } from '../domain/encounter.ports';
import type { ICombatPublisher } from '../infra/combat.publisher';

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

function makeCombatantCount(count = 0): ICombatantCount {
  return {
    countByEncounter: vi.fn().mockResolvedValue(count),
  };
}

function makeCombatantRepo(): ICombatantRepo {
  return {
    findById: vi.fn(),
    listByEncounter: vi.fn().mockResolvedValue([]),
    listByEncounterWithSnapshot: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    countByEncounter: vi.fn(),
  };
}

function makeCombatPublisher(): ICombatPublisher {
  return { publishUpdated: vi.fn().mockResolvedValue(undefined) };
}

function makeEventBus(): Pick<EventBus, 'publish'> {
  return { publish: vi.fn() };
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

function makeDto(overrides: Partial<UpdateEncounterDto> = {}): UpdateEncounterDto {
  return Object.assign(new UpdateEncounterDto(), overrides);
}

describe('UpdateEncounterHandler', () => {
  let repo: IEncounterRepo;
  let access: IGameSessionAccess;
  let combatantCount: ICombatantCount;
  let combatantRepo: ICombatantRepo;
  let combatPublisher: ICombatPublisher;
  let eventBus: Pick<EventBus, 'publish'>;
  let handler: UpdateEncounterHandler;

  beforeEach(() => {
    repo = makeRepo();
    access = makeAccess();
    combatantCount = makeCombatantCount(0);
    combatantRepo = makeCombatantRepo();
    combatPublisher = makeCombatPublisher();
    eventBus = makeEventBus();
    handler = new UpdateEncounterHandler(
      repo,
      access,
      combatantCount,
      combatantRepo,
      combatPublisher,
      eventBus as EventBus,
    );
    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
  });

  it('throws EncounterNotFoundError when encounter does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new UpdateEncounterCommand('enc-missing', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
  });

  it('throws EncounterAccessDeniedError when caller is not GM owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue('owner-1');

    await expect(
      handler.execute(new UpdateEncounterCommand('enc-1', 'other-user', makeDto())),
    ).rejects.toBeInstanceOf(EncounterAccessDeniedError);
  });

  it('EncounterAccessDeniedError has status 403', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue('owner-1');

    await expect(
      handler.execute(new UpdateEncounterCommand('enc-1', 'other-user', makeDto())),
    ).rejects.toMatchObject({ code: 'ENCOUNTER_ACCESS_DENIED', status: 403 });
  });

  it('renames encounter (name-only patch at setup status)', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(repo.update).mockResolvedValue(makeEncounter({ name: 'Renamed' }));

    await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ name: 'Renamed' })),
    );

    expect(repo.update).toHaveBeenCalledWith('enc-1', expect.objectContaining({ name: 'Renamed' }));
  });

  it('trims whitespace from name', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(repo.update).mockResolvedValue(makeEncounter({ name: 'Renamed' }));

    await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ name: '  Renamed  ' })),
    );

    expect(repo.update).toHaveBeenCalledWith('enc-1', expect.objectContaining({ name: 'Renamed' }));
  });

  it('updates notes at setup status', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(repo.update).mockResolvedValue(makeEncounter({ notes: 'New notes' }));

    await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ notes: 'New notes' })),
    );

    expect(repo.update).toHaveBeenCalledWith(
      'enc-1',
      expect.objectContaining({ notes: 'New notes' }),
    );
  });

  it('updates notes at active status', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'active' }));
    vi.mocked(repo.update).mockResolvedValue(
      makeEncounter({ status: 'active', notes: 'Active notes' }),
    );

    await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ notes: 'Active notes' })),
    );

    expect(repo.update).toHaveBeenCalledWith(
      'enc-1',
      expect.objectContaining({ notes: 'Active notes' }),
    );
  });

  it('updates notes at ended status', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'ended' }));
    vi.mocked(repo.update).mockResolvedValue(
      makeEncounter({ status: 'ended', notes: 'Post-mortem' }),
    );

    await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ notes: 'Post-mortem' })),
    );

    expect(repo.update).toHaveBeenCalledWith(
      'enc-1',
      expect.objectContaining({ notes: 'Post-mortem' }),
    );
  });

  it('throws ENCOUNTER_NO_COMBATANTS for setup → active when no combatants', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'setup' }));
    vi.mocked(combatantCount.countByEncounter).mockResolvedValue(0);

    await expect(
      handler.execute(new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ status: 'active' }))),
    ).rejects.toBeInstanceOf(EncounterNoCombatantsError);
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('ENCOUNTER_NO_COMBATANTS has status 422', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'setup' }));
    vi.mocked(combatantCount.countByEncounter).mockResolvedValue(0);

    await expect(
      handler.execute(new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ status: 'active' }))),
    ).rejects.toMatchObject({ code: 'ENCOUNTER_NO_COMBATANTS', status: 422 });
  });

  it('allows setup → active when encounter has ≥1 combatant', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'setup' }));
    vi.mocked(combatantCount.countByEncounter).mockResolvedValue(2);
    vi.mocked(repo.update).mockResolvedValue(makeEncounter({ status: 'active' }));

    await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ status: 'active' })),
    );

    expect(repo.update).toHaveBeenCalledWith(
      'enc-1',
      expect.objectContaining({ status: 'active' }),
    );
  });

  it('does not query combatant count for active → ended', async () => {
    vi.mocked(repo.findById).mockResolvedValue(
      makeEncounter({ status: 'active', activeCombatantId: 'cb-1' }),
    );
    vi.mocked(repo.update).mockResolvedValue(
      makeEncounter({ status: 'ended', activeCombatantId: null }),
    );

    await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ status: 'ended' })),
    );

    expect(combatantCount.countByEncounter).not.toHaveBeenCalled();
  });

  it('allows active → ended and resets activeCombatantId', async () => {
    vi.mocked(repo.findById).mockResolvedValue(
      makeEncounter({ status: 'active', activeCombatantId: 'cb-1' }),
    );
    vi.mocked(repo.update).mockResolvedValue(
      makeEncounter({ status: 'ended', activeCombatantId: null }),
    );

    await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ status: 'ended' })),
    );

    expect(repo.update).toHaveBeenCalledWith(
      'enc-1',
      expect.objectContaining({ status: 'ended', activeCombatantId: null }),
    );
  });

  it('throws ENCOUNTER_INVALID_TRANSITION for active → setup', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'active' }));

    await expect(
      handler.execute(new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ status: 'setup' }))),
    ).rejects.toBeInstanceOf(EncounterInvalidTransitionError);
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('throws ENCOUNTER_INVALID_TRANSITION for ended → active', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'ended' }));

    await expect(
      handler.execute(new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ status: 'active' }))),
    ).rejects.toBeInstanceOf(EncounterInvalidTransitionError);
  });

  it('throws ENCOUNTER_INVALID_TRANSITION for setup → ended (skip)', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'setup' }));

    await expect(
      handler.execute(new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ status: 'ended' }))),
    ).rejects.toBeInstanceOf(EncounterInvalidTransitionError);
  });

  it('no-op when status is same as current (no repo call)', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'setup' }));
    vi.mocked(repo.update).mockResolvedValue(makeEncounter());

    await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ status: 'setup', name: 'Renamed' })),
    );

    // status unchanged — no status key in patch
    expect(repo.update).toHaveBeenCalledWith(
      'enc-1',
      expect.not.objectContaining({ status: expect.anything() }),
    );
  });

  it('calls combatPublisher.publishUpdated after successful update', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    const updated = makeEncounter({ name: 'Renamed' });
    vi.mocked(repo.update).mockResolvedValue(updated);
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([]);

    await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ name: 'Renamed' })),
    );

    expect(combatPublisher.publishUpdated).toHaveBeenCalledWith('gs-1', updated, []);
  });

  it('publish failure does not break the flow — returns updated encounter', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    const updated = makeEncounter({ name: 'Renamed' });
    vi.mocked(repo.update).mockResolvedValue(updated);
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([]);
    vi.mocked(combatPublisher.publishUpdated).mockRejectedValueOnce(new Error('Centrifugo down'));

    const result = await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ name: 'Renamed' })),
    );

    expect(result).toEqual(updated);
  });

  it('publishes EncounterStartedEvent on setup → active transition', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'setup' }));
    vi.mocked(combatantCount.countByEncounter).mockResolvedValue(2);
    vi.mocked(repo.update).mockResolvedValue(makeEncounter({ status: 'active' }));

    await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ status: 'active' })),
    );

    expect(eventBus.publish).toHaveBeenCalledOnce();
    expect(eventBus.publish).toHaveBeenCalledWith(
      expect.objectContaining({ encounterId: 'enc-1', gameSessionId: 'gs-1' }),
    );
  });

  it('publishes EncounterEndedEvent on active → ended transition', async () => {
    vi.mocked(repo.findById).mockResolvedValue(
      makeEncounter({ status: 'active', activeCombatantId: 'cb-1' }),
    );
    vi.mocked(repo.update).mockResolvedValue(
      makeEncounter({ status: 'ended', activeCombatantId: null }),
    );

    await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ status: 'ended' })),
    );

    expect(eventBus.publish).toHaveBeenCalledOnce();
    expect(eventBus.publish).toHaveBeenCalledWith(
      expect.objectContaining({ encounterId: 'enc-1', gameSessionId: 'gs-1' }),
    );
  });

  it('does not publish any lifecycle event for a name-only update', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(repo.update).mockResolvedValue(makeEncounter({ name: 'Renamed' }));

    await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ name: 'Renamed' })),
    );

    expect(eventBus.publish).not.toHaveBeenCalled();
  });

  it('publishes lifecycle event even when combatPublisher throws', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'setup' }));
    vi.mocked(combatantCount.countByEncounter).mockResolvedValue(1);
    vi.mocked(repo.update).mockResolvedValue(makeEncounter({ status: 'active' }));
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([]);
    vi.mocked(combatPublisher.publishUpdated).mockRejectedValueOnce(new Error('Centrifugo down'));

    await handler.execute(
      new UpdateEncounterCommand('enc-1', 'user-1', makeDto({ status: 'active' })),
    );

    // Event must still fire despite publisher failure
    expect(eventBus.publish).toHaveBeenCalledOnce();
  });
});
