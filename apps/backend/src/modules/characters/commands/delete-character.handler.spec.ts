import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CharacterNotFoundError, CharacterNotOwnedError } from '../domain/character.errors';
import { DEFAULT_CONDITIONS, DEFAULT_SKILLS } from '../domain/character.ports';

import { DeleteCharacterCommand } from './delete-character.command';
import { DeleteCharacterHandler } from './delete-character.handler';

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

function makeCharacter(overrides: Partial<CharacterReadModel> = {}): CharacterReadModel {
  return {
    id: 'char-1',
    ownerId: 'user-1',
    name: 'Kalim',
    concept: null,
    iconId: null,
    upbringing: 'plebeian',
    origin: null,
    reputation: 2,
    startingWealth: 500,
    attributes: { strength: 3, agility: 3, wits: 3, empathy: 3 },
    skills: { ...DEFAULT_SKILLS },
    hp: { current: 14, max: 14 },
    mp: { current: 10, max: 10 },
    encumbrance: { current: 0, max: 5 },
    experience: 0,
    conditions: { ...DEFAULT_CONDITIONS },
    criticalInjuries: [],
    talents: [],
    relationships: [],
    inventory: [],
    notes: null,
    status: 'active',
    createdAt: '2026-01-15T00:00:00.000Z',
    updatedAt: '2026-01-15T00:00:00.000Z',
    ...overrides,
  };
}

describe('DeleteCharacterHandler', () => {
  let repo: ICharacterRepo;
  let handler: DeleteCharacterHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new DeleteCharacterHandler(repo);
  });

  it('deletes the character when owner matches', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter());
    vi.mocked(repo.delete).mockResolvedValue(undefined);

    await expect(
      handler.execute(new DeleteCharacterCommand('char-1', 'user-1')),
    ).resolves.toBeUndefined();
    expect(repo.delete).toHaveBeenCalledWith('char-1');
  });

  it('throws CharacterNotFoundError when character does not exist', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(null);

    await expect(
      handler.execute(new DeleteCharacterCommand('missing', 'user-1')),
    ).rejects.toBeInstanceOf(CharacterNotFoundError);
    expect(repo.delete).not.toHaveBeenCalled();
  });

  it('throws CharacterNotOwnedError when ownerId mismatches', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ ownerId: 'other' }));

    await expect(
      handler.execute(new DeleteCharacterCommand('char-1', 'user-1')),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);
    expect(repo.delete).not.toHaveBeenCalled();
  });

  it('returns CharacterNotOwnedError with 403 status', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ ownerId: 'other' }));

    await expect(
      handler.execute(new DeleteCharacterCommand('char-1', 'user-1')),
    ).rejects.toMatchObject({ status: 403, code: 'CHARACTER_NOT_OWNED' });
  });
});
