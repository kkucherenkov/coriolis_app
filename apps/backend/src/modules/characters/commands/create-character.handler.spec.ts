/**
 * Unit tests for CreateCharacterHandler.
 * Repo and EventBus are vi.fn() mocks — no NestJS or Prisma bootstrapping.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  AttributeBudgetExceededError,
  AttributeOutOfCreationRangeError,
  AttributeOutOfRangeError,
  CharacterNameEmptyError,
  CharacterNameTooLongError,
  IconUnknownError,
  SkillBudgetExceededError,
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
    concept: null,
    iconId: null,
    upbringing: 'plebeian',
    origin: null,
    reputation: 2,
    startingWealth: 500,
    crewConcept: null,
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

function makeDto(overrides: Partial<CreateCharacterDto> = {}): CreateCharacterDto {
  return Object.assign(new CreateCharacterDto(), {
    name: 'Kalim al-Rashid',
    upbringing: 'plebeian' as const,
    ...overrides,
  });
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
      handler.execute(new CreateCharacterCommand('user-1', makeDto({ name: 'a'.repeat(81) }))),
    ).rejects.toBeInstanceOf(CharacterNameTooLongError);
  });

  it('accepts name of exactly 80 characters', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeCharacter({ name: 'a'.repeat(80) }));

    await expect(
      handler.execute(new CreateCharacterCommand('user-1', makeDto({ name: 'a'.repeat(80) }))),
    ).resolves.toBeDefined();
  });

  it('throws IconUnknownError for invalid icon', async () => {
    await expect(
      handler.execute(
        new CreateCharacterCommand('user-1', makeDto({ iconId: 'unknown-icon' as never })),
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
      handler.execute(new CreateCharacterCommand('user-1', makeDto({ skills }))),
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

  // ── status field (T-5.6.1.b) ────────────────────────────────────────────────

  it('defaults status to active when dto.status is omitted', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeCharacter({ status: 'active' }));

    await handler.execute(new CreateCharacterCommand('user-1', makeDto()));

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ status: 'active' }));
  });

  it('passes status draft through to the repo when dto.status is draft', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeCharacter({ status: 'draft' }));

    await handler.execute(new CreateCharacterCommand('user-1', makeDto({ status: 'draft' })));

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ status: 'draft' }));
  });

  it('passes status active through to the repo when dto.status is active', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeCharacter({ status: 'active' }));

    await handler.execute(new CreateCharacterCommand('user-1', makeDto({ status: 'active' })));

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ status: 'active' }));
  });

  it('returns the status field from the repo result', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeCharacter({ status: 'draft' }));

    const result = await handler.execute(
      new CreateCharacterCommand('user-1', makeDto({ status: 'draft' })),
    );

    expect(result.status).toBe('draft');
  });

  // -------- Upbringing-derived budgets (Coriolis core book ch.2) --------

  it('plebeian: derives reputation 2 and startingWealth 500', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeCharacter({ upbringing: 'plebeian' }));

    await handler.execute(
      new CreateCharacterCommand('user-1', makeDto({ upbringing: 'plebeian' })),
    );

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ upbringing: 'plebeian', reputation: 2, startingWealth: 500 }),
    );
  });

  it('stationary: derives reputation 4 and startingWealth 1000', async () => {
    vi.mocked(repo.create).mockResolvedValue(
      makeCharacter({ upbringing: 'stationary', reputation: 4, startingWealth: 1000 }),
    );

    await handler.execute(
      new CreateCharacterCommand('user-1', makeDto({ upbringing: 'stationary' })),
    );

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ upbringing: 'stationary', reputation: 4, startingWealth: 1000 }),
    );
  });

  it('aristocrat: derives reputation 6 and startingWealth 5000', async () => {
    vi.mocked(repo.create).mockResolvedValue(
      makeCharacter({ upbringing: 'aristocrat', reputation: 6, startingWealth: 5000 }),
    );

    await handler.execute(
      new CreateCharacterCommand('user-1', makeDto({ upbringing: 'aristocrat' })),
    );

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ upbringing: 'aristocrat', reputation: 6, startingWealth: 5000 }),
    );
  });

  it('throws AttributeBudgetExceededError when sum exceeds upbringing budget', async () => {
    // aristocrat budget = 13; 4+4+3+3 = 14 → reject
    await expect(
      handler.execute(
        new CreateCharacterCommand(
          'user-1',
          makeDto({
            upbringing: 'aristocrat',
            attributes: { strength: 4, agility: 4, wits: 3, empathy: 3 },
          }),
        ),
      ),
    ).rejects.toBeInstanceOf(AttributeBudgetExceededError);
    expect(repo.create).not.toHaveBeenCalled();
  });

  it('throws AttributeOutOfCreationRangeError when an attribute is below the 2..4 cap', async () => {
    await expect(
      handler.execute(
        new CreateCharacterCommand(
          'user-1',
          makeDto({
            upbringing: 'plebeian',
            attributes: { strength: 1, agility: 4, wits: 4, empathy: 4 },
          }),
        ),
      ),
    ).rejects.toBeInstanceOf(AttributeOutOfCreationRangeError);
  });

  it('throws AttributeOutOfCreationRangeError when an attribute exceeds 4 (key-attr exception is Block 2)', async () => {
    await expect(
      handler.execute(
        new CreateCharacterCommand(
          'user-1',
          makeDto({
            upbringing: 'plebeian',
            attributes: { strength: 5, agility: 4, wits: 3, empathy: 3 },
          }),
        ),
      ),
    ).rejects.toBeInstanceOf(AttributeOutOfCreationRangeError);
  });

  it('accepts attributes that exactly match the upbringing budget', async () => {
    vi.mocked(repo.create).mockResolvedValue(
      makeCharacter({
        upbringing: 'aristocrat',
        reputation: 6,
        startingWealth: 5000,
        attributes: { strength: 4, agility: 3, wits: 3, empathy: 3 },
      }),
    );

    await expect(
      handler.execute(
        new CreateCharacterCommand(
          'user-1',
          makeDto({
            upbringing: 'aristocrat',
            attributes: { strength: 4, agility: 3, wits: 3, empathy: 3 },
          }),
        ),
      ),
    ).resolves.toBeDefined();
  });

  it('throws SkillBudgetExceededError when sum of skills exceeds upbringing budget', async () => {
    // plebeian skill budget = 8; total spent below = 9 → reject
    await expect(
      handler.execute(
        new CreateCharacterCommand(
          'user-1',
          makeDto({
            upbringing: 'plebeian',
            skills: {
              dexterity: 1,
              force: 1,
              infiltration: 1,
              manipulation: 1,
              meleeCombat: 1,
              observation: 1,
              rangedCombat: 1,
              survival: 1,
              command: 1,
              culture: 0,
              dataDjinn: 0,
              medicurgy: 0,
              mysticPowers: 0,
              pilot: 0,
              science: 0,
              technology: 0,
            },
          }),
        ),
      ),
    ).rejects.toBeInstanceOf(SkillBudgetExceededError);
  });

  // -------- Concept-aware caps (Block 2) --------

  it('soldier (key attr agility): allows agility=5 at creation', async () => {
    vi.mocked(repo.create).mockResolvedValue(
      makeCharacter({
        upbringing: 'plebeian',
        concept: 'soldier',
        attributes: { strength: 4, agility: 5, wits: 3, empathy: 3 },
      }),
    );
    await expect(
      handler.execute(
        new CreateCharacterCommand(
          'user-1',
          makeDto({
            upbringing: 'plebeian',
            concept: 'soldier',
            attributes: { strength: 4, agility: 5, wits: 3, empathy: 3 },
          }),
        ),
      ),
    ).resolves.toBeDefined();
  });

  it('soldier: rejects strength=5 (non-key) even though agility=5 is allowed', async () => {
    await expect(
      handler.execute(
        new CreateCharacterCommand(
          'user-1',
          makeDto({
            upbringing: 'plebeian',
            concept: 'soldier',
            attributes: { strength: 5, agility: 4, wits: 3, empathy: 3 },
          }),
        ),
      ),
    ).rejects.toBeInstanceOf(AttributeOutOfCreationRangeError);
  });

  it('pilot: allows pilot skill at rank 3 (key skill)', async () => {
    vi.mocked(repo.create).mockResolvedValue(
      makeCharacter({ upbringing: 'stationary', concept: 'pilot' }),
    );
    await expect(
      handler.execute(
        new CreateCharacterCommand(
          'user-1',
          makeDto({
            upbringing: 'stationary',
            concept: 'pilot',
            skills: { ...DEFAULT_SKILLS, pilot: 3 },
          }),
        ),
      ),
    ).resolves.toBeDefined();
  });

  it('pilot: rejects culture=2 (non-key skill exceeds cap of 1)', async () => {
    await expect(
      handler.execute(
        new CreateCharacterCommand(
          'user-1',
          makeDto({
            upbringing: 'stationary',
            concept: 'pilot',
            skills: { ...DEFAULT_SKILLS, culture: 2 },
          }),
        ),
      ),
    ).rejects.toBeInstanceOf(SkillOutOfRangeError);
  });

  it('artist on plebeian: reputation = 2 + 1 = 3', async () => {
    vi.mocked(repo.create).mockResolvedValue(
      makeCharacter({ upbringing: 'plebeian', concept: 'artist', reputation: 3 }),
    );
    await handler.execute(
      new CreateCharacterCommand('user-1', makeDto({ upbringing: 'plebeian', concept: 'artist' })),
    );
    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ concept: 'artist', reputation: 3 }),
    );
  });

  it('fugitive on plebeian: reputation clamped to 0 (2 + -2 = 0)', async () => {
    vi.mocked(repo.create).mockResolvedValue(
      makeCharacter({ upbringing: 'plebeian', concept: 'fugitive', reputation: 0 }),
    );
    await handler.execute(
      new CreateCharacterCommand(
        'user-1',
        makeDto({ upbringing: 'plebeian', concept: 'fugitive' }),
      ),
    );
    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ concept: 'fugitive', reputation: 0 }),
    );
  });

  it('scientist on aristocrat: reputation = 6 + 1 = 7', async () => {
    vi.mocked(repo.create).mockResolvedValue(
      makeCharacter({ upbringing: 'aristocrat', concept: 'scientist', reputation: 7 }),
    );
    await handler.execute(
      new CreateCharacterCommand(
        'user-1',
        makeDto({ upbringing: 'aristocrat', concept: 'scientist' }),
      ),
    );
    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ concept: 'scientist', reputation: 7 }),
    );
  });

  // -------- Block 3: Talent kind + crewConcept --------

  it('passes crewConcept through to the repo when provided in the DTO', async () => {
    vi.mocked(repo.create).mockResolvedValue(
      makeCharacter({ upbringing: 'plebeian', crewConcept: 'free-trader' }),
    );
    await handler.execute(
      new CreateCharacterCommand(
        'user-1',
        makeDto({ upbringing: 'plebeian', crewConcept: 'free-trader' }),
      ),
    );
    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ crewConcept: 'free-trader' }),
    );
  });

  it('defaults crewConcept to null when not provided', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeCharacter());
    await handler.execute(new CreateCharacterCommand('user-1', makeDto()));
    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ crewConcept: null }));
  });

  it('auto-derives an iconGift talent from the chosen icon', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeCharacter({ iconId: 'traveler' }));
    await handler.execute(
      new CreateCharacterCommand('user-1', makeDto({ upbringing: 'plebeian', iconId: 'traveler' })),
    );
    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        iconId: 'traveler',
        talents: [expect.objectContaining({ kind: 'iconGift', name: 'gift-traveler' })],
      }),
    );
  });

  it('seeds no talents when no icon is chosen', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeCharacter());
    await handler.execute(
      new CreateCharacterCommand('user-1', makeDto({ upbringing: 'plebeian' })),
    );
    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ talents: [] }));
  });

  it('iconGift talent ID is the canonical gift-{iconId} for every IconId', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeCharacter({ iconId: 'lady-of-tears' }));
    await handler.execute(
      new CreateCharacterCommand(
        'user-1',
        makeDto({ upbringing: 'plebeian', iconId: 'lady-of-tears' }),
      ),
    );
    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        talents: [expect.objectContaining({ kind: 'iconGift', name: 'gift-lady-of-tears' })],
      }),
    );
  });

  it('hydrates the iconGift seed with the catalog English description (not an empty string)', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeCharacter({ iconId: 'gambler' }));
    await handler.execute(
      new CreateCharacterCommand('user-1', makeDto({ upbringing: 'plebeian', iconId: 'gambler' })),
    );
    const createArgs = vi.mocked(repo.create).mock.calls[0]?.[0];
    expect(createArgs?.talents?.[0]?.kind).toBe('iconGift');
    expect(createArgs?.talents?.[0]?.name).toBe('gift-gambler');
    // The catalog description for the Gambler gift mentions "three sixes" —
    // a tight enough invariant to catch regressions if the seed reverts to
    // the old empty-string placeholder while still allowing prose tweaks.
    expect(createArgs?.talents?.[0]?.description).toMatch(/sixes/i);
  });
});
