import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CharacterNotFoundError, CharacterNotOwnedError } from '../domain/character.errors';
import { DEFAULT_CONDITIONS, DEFAULT_SKILLS } from '../domain/character.ports';

import { GetCharacterQuery } from './get-character.query';
import { GetCharacterHandler } from './get-character.handler';

import type { ICharacterRepo, CharacterReadModel } from '../domain/character.ports';

function makeRepo(): ICharacterRepo {
  return {
    findActiveById: vi.fn(),
    findOwnerIdById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
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
    createdAt: '2026-01-15T00:00:00.000Z',
    updatedAt: '2026-01-15T00:00:00.000Z',
    ...overrides,
  };
}

describe('GetCharacterHandler', () => {
  let repo: ICharacterRepo;
  let handler: GetCharacterHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new GetCharacterHandler(repo);
  });

  it('returns CharacterReadModel when character exists and owned', async () => {
    const char = makeCharacter();
    vi.mocked(repo.findActiveById).mockResolvedValue(char);

    const result = await handler.execute(new GetCharacterQuery('char-1', 'user-1'));

    expect(result).toEqual(char);
    expect(repo.findActiveById).toHaveBeenCalledWith('char-1');
  });

  it('throws CharacterNotFoundError when character does not exist', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(null);

    await expect(
      handler.execute(new GetCharacterQuery('missing', 'user-1')),
    ).rejects.toBeInstanceOf(CharacterNotFoundError);
  });

  it('throws CharacterNotFoundError with 404 status', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(null);

    await expect(
      handler.execute(new GetCharacterQuery('missing', 'user-1')),
    ).rejects.toMatchObject({ status: 404, code: 'CHARACTER_NOT_FOUND' });
  });

  it('throws CharacterNotOwnedError when character belongs to another user', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ ownerId: 'other-user' }));

    await expect(
      handler.execute(new GetCharacterQuery('char-1', 'user-1')),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);
  });

  it('throws CharacterNotOwnedError with 403 status', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ ownerId: 'other-user' }));

    await expect(
      handler.execute(new GetCharacterQuery('char-1', 'user-1')),
    ).rejects.toMatchObject({ status: 403, code: 'CHARACTER_NOT_OWNED' });
  });

  it('returns character with all nested arrays', async () => {
    const char = makeCharacter({
      talents: [{ id: 't-1', name: 'Wing-Mate', description: 'Desc', rank: 1, acquiredAt: '2026-01-15T00:00:00.000Z' }],
      inventory: [{ id: 'i-1', type: 'GEAR', name: 'Toolkit', weight: 1, quantity: 1 }],
    });
    vi.mocked(repo.findActiveById).mockResolvedValue(char);

    const result = await handler.execute(new GetCharacterQuery('char-1', 'user-1'));

    expect(result.talents).toHaveLength(1);
    expect(result.inventory).toHaveLength(1);
  });
});
