/**
 * Unit tests for CreateCharacterHandler.
 * Repo and EventBus are vi.fn() mocks — no NestJS or Prisma bootstrapping.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  AttributeOutOfRangeError,
  CharacterNameEmptyError,
  CharacterNameTooLongError,
  IconUnknownError,
  SkillOutOfRangeError,
} from '../domain/character.errors';
import { DEFAULT_ATTRIBUTES, DEFAULT_CONDITIONS, DEFAULT_SKILLS } from '../domain/character.ports';

import { CreateCharacterCommand, CreateCharacterDto } from './create-character.command';
import { CreateCharacterHandler } from './create-character.handler';

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

const fakeEventBus = { publish: vi.fn() } as unknown as import('@nestjs/cqrs').EventBus;

function makeCharacter(overrides: Partial<CharacterReadModel> = {}): CharacterReadModel {
  return {
    id: 'char-1',
    ownerId: 'user-1',
    name: 'Kalim al-Rashid',
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

function makeDto(overrides: Partial<CreateCharacterDto> = {}): CreateCharacterDto {
  return Object.assign(new CreateCharacterDto(), { name: 'Kalim al-Rashid', ...overrides });
}

describe('CreateCharacterHandler', () => {
  let repo: ICharacterRepo;
  let handler: CreateCharacterHandler;

  beforeEach(() => {
    repo = makeRepo();
    vi.mocked(fakeEventBus.publish).mockReset();
    handler = new CreateCharacterHandler(repo, fakeEventBus);
  });

  it('creates a character with default attributes when not provided', async () => {
    const char = makeCharacter();
    vi.mocked(repo.create).mockResolvedValue(char);

    const result = await handler.execute(new CreateCharacterCommand('user-1', makeDto()));

    expect(result).toEqual(char);
    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        ownerId: 'user-1',
        name: 'Kalim al-Rashid',
        attributes: DEFAULT_ATTRIBUTES,
      }),
    );
  });

  it('merges provided attributes over defaults', async () => {
    const char = makeCharacter({ attributes: { strength: 4, agility: 2, wits: 2, empathy: 2 } });
    vi.mocked(repo.create).mockResolvedValue(char);

    await handler.execute(
      new CreateCharacterCommand(
        'user-1',
        makeDto({ attributes: { strength: 4, agility: 2, wits: 2, empathy: 2 } }),
      ),
    );

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ attributes: { strength: 4, agility: 2, wits: 2, empathy: 2 } }),
    );
  });

  it('publishes CharacterUpdatedEvent after creation', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeCharacter());

    await handler.execute(new CreateCharacterCommand('user-1', makeDto()));

    expect(fakeEventBus.publish).toHaveBeenCalledOnce();
  });

  it('throws CharacterNameEmptyError for empty name', async () => {
    await expect(
      handler.execute(new CreateCharacterCommand('user-1', makeDto({ name: '' }))),
    ).rejects.toBeInstanceOf(CharacterNameEmptyError);
    expect(repo.create).not.toHaveBeenCalled();
  });

  it('throws CharacterNameEmptyError with 400 status', async () => {
    await expect(
      handler.execute(new CreateCharacterCommand('user-1', makeDto({ name: '  ' }))),
    ).rejects.toMatchObject({ status: 400, code: 'CHARACTER_NAME_EMPTY' });
  });

  it('throws CharacterNameTooLongError when name exceeds 80 chars', async () => {
    await expect(
      handler.execute(
        new CreateCharacterCommand('user-1', makeDto({ name: 'a'.repeat(81) })),
      ),
    ).rejects.toBeInstanceOf(CharacterNameTooLongError);
  });

  it('accepts name of exactly 80 characters', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeCharacter({ name: 'a'.repeat(80) }));

    await expect(
      handler.execute(
        new CreateCharacterCommand('user-1', makeDto({ name: 'a'.repeat(80) })),
      ),
    ).resolves.toBeDefined();
  });

  it('throws IconUnknownError for invalid icon', async () => {
    await expect(
      handler.execute(
        new CreateCharacterCommand(
          'user-1',
          makeDto({ iconId: 'unknown-icon' as never }),
        ),
      ),
    ).rejects.toBeInstanceOf(IconUnknownError);
  });

  it('throws AttributeOutOfRangeError when attribute < 1', async () => {
    await expect(
      handler.execute(
        new CreateCharacterCommand(
          'user-1',
          makeDto({ attributes: { strength: 0, agility: 2, wits: 2, empathy: 2 } }),
        ),
      ),
    ).rejects.toBeInstanceOf(AttributeOutOfRangeError);
  });

  it('throws AttributeOutOfRangeError when attribute > 5', async () => {
    await expect(
      handler.execute(
        new CreateCharacterCommand(
          'user-1',
          makeDto({ attributes: { strength: 6, agility: 2, wits: 2, empathy: 2 } }),
        ),
      ),
    ).rejects.toMatchObject({ status: 422, code: 'ATTRIBUTE_OUT_OF_RANGE' });
  });

  it('throws SkillOutOfRangeError when skill > 5', async () => {
    const skills = { ...DEFAULT_SKILLS, dexterity: 6 };
    await expect(
      handler.execute(
        new CreateCharacterCommand('user-1', makeDto({ skills })),
      ),
    ).rejects.toBeInstanceOf(SkillOutOfRangeError);
  });

  it('accepts all valid icon ids', async () => {
    const validIcons = [
      'lady-of-tears',
      'traveler',
      'messenger',
      'merchant',
      'dancer',
      'gambler',
      'judge',
      'faceless-one',
      'deckhand',
    ] as const;

    for (const iconId of validIcons) {
      vi.mocked(repo.create).mockResolvedValue(makeCharacter({ iconId }));
      await expect(
        handler.execute(new CreateCharacterCommand('user-1', makeDto({ iconId }))),
      ).resolves.toBeDefined();
    }
  });
});
