import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CharacterNotFoundError, CharacterNotOwnedError } from '../domain/character.errors';
import { DEFAULT_CONDITIONS, DEFAULT_SKILLS } from '../domain/character.ports';

import { DuplicateCharacterCommand } from './duplicate-character.command';
import { DuplicateCharacterHandler } from './duplicate-character.handler';

import type { ICharacterRepo, CharacterReadModel } from '../domain/character.ports';

function makeRepo(): ICharacterRepo {
  return {
    findActiveById: vi.fn(),
    findOwnerIdById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    deleteAbandonedDrafts: vi.fn(),
    delete: vi.fn(),
  };
}

const fakeEventBus = { publish: vi.fn() } as unknown as import('@nestjs/cqrs').EventBus;

function makeCharacter(overrides: Partial<CharacterReadModel> = {}): CharacterReadModel {
  return {
    id: 'char-1',
    ownerId: 'user-1',
    name: 'Kalim al-Rashid',
    concept: 'operative',
    iconId: 'traveler',
    upbringing: 'stationary',
    origin: 'Coriolis Station',
    reputation: 4,
    startingWealth: 1000,
    crewConcept: null,
    attributes: { strength: 4, agility: 3, wits: 2, empathy: 3 },
    skills: { ...DEFAULT_SKILLS, force: 3 },
    hp: { current: 12, max: 14 },
    mp: { current: 10, max: 10 },
    encumbrance: { current: 0, max: 5 },
    experience: 100,
    conditions: { ...DEFAULT_CONDITIONS, exhausted: true },
    criticalInjuries: [],
    talents: [],
    relationships: [],
    inventory: [],
    notes: 'Some notes',
    status: 'active',
    createdAt: '2026-01-15T00:00:00.000Z',
    updatedAt: '2026-01-15T00:00:00.000Z',
    ...overrides,
  };
}

describe('DuplicateCharacterHandler', () => {
  let repo: ICharacterRepo;
  let handler: DuplicateCharacterHandler;

  beforeEach(() => {
    repo = makeRepo();
    vi.mocked(fakeEventBus.publish).mockReset();
    handler = new DuplicateCharacterHandler(repo, fakeEventBus);
  });

  it('creates a copy with name "<original> (copy)"', async () => {
    const source = makeCharacter();
    const copy = makeCharacter({ id: 'char-2', name: 'Kalim al-Rashid (copy)', experience: 0 });
    vi.mocked(repo.findActiveById).mockResolvedValue(source);
    vi.mocked(repo.create).mockResolvedValue(copy);

    const result = await handler.execute(new DuplicateCharacterCommand('char-1', 'user-1'));

    expect(result.name).toBe('Kalim al-Rashid (copy)');
    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ name: 'Kalim al-Rashid (copy)' }),
    );
  });

  it('zeros experience on the copy', async () => {
    const source = makeCharacter({ experience: 100 });
    const copy = makeCharacter({ id: 'char-2', name: 'Kalim al-Rashid (copy)', experience: 0 });
    vi.mocked(repo.findActiveById).mockResolvedValue(source);
    vi.mocked(repo.create).mockResolvedValue(copy);

    const result = await handler.execute(new DuplicateCharacterCommand('char-1', 'user-1'));

    expect(result.experience).toBe(0);
    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ experience: 0 }));
  });

  it('copies same attributes and skills', async () => {
    const source = makeCharacter();
    const copy = makeCharacter({
      id: 'char-2',
      name: 'Kalim al-Rashid (copy)',
      experience: 0,
      hp: { current: 14, max: 14 },
      mp: { current: 10, max: 10 },
    });
    vi.mocked(repo.findActiveById).mockResolvedValue(source);
    vi.mocked(repo.create).mockResolvedValue(copy);

    await handler.execute(new DuplicateCharacterCommand('char-1', 'user-1'));

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ attributes: source.attributes, skills: source.skills }),
    );
  });

  it('resets hp/mp to placeholder constants', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(
      makeCharacter({ hp: { current: 5, max: 14 } }),
    );
    const copy = makeCharacter({ id: 'char-2', name: 'Kalim al-Rashid (copy)', experience: 0 });
    vi.mocked(repo.create).mockResolvedValue(copy);

    await handler.execute(new DuplicateCharacterCommand('char-1', 'user-1'));

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ hpCurrent: 14, mpCurrent: 10 }),
    );
  });

  it('throws CharacterNotFoundError when source does not exist', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(null);

    await expect(
      handler.execute(new DuplicateCharacterCommand('missing', 'user-1')),
    ).rejects.toBeInstanceOf(CharacterNotFoundError);
    expect(repo.create).not.toHaveBeenCalled();
  });

  it('throws CharacterNotOwnedError when caller is not the owner', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ ownerId: 'other' }));

    await expect(
      handler.execute(new DuplicateCharacterCommand('char-1', 'user-1')),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);
    expect(repo.create).not.toHaveBeenCalled();
  });

  it('publishes CharacterUpdatedEvent after duplication', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter());
    vi.mocked(repo.create).mockResolvedValue(
      makeCharacter({ id: 'char-2', name: 'Kalim al-Rashid (copy)', experience: 0 }),
    );

    await handler.execute(new DuplicateCharacterCommand('char-1', 'user-1'));

    expect(fakeEventBus.publish).toHaveBeenCalledOnce();
  });
});
