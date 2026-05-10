import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  AttributeOutOfRangeError,
  CharacterNameEmptyError,
  CharacterNotFoundError,
  CharacterNotOwnedError,
  CrewConceptImmutableError,
  InvalidStatusTransitionError,
  MutantImmutableError,
  MutantLineageForbiddenError,
  MutantLineageRequiredError,
  ReadOnlyFieldError,
  RoleConceptMismatchError,
  SkillOutOfRangeError,
} from '../domain/character.errors';
import { DEFAULT_CONDITIONS, DEFAULT_SKILLS } from '../domain/character.ports';

import { UpdateCharacterCommand, UpdateCharacterDto } from './update-character.command';
import { UpdateCharacterHandler } from './update-character.handler';

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
    role: null,
    roleUnmigrated: false,
    iconId: null,
    upbringing: 'plebeian',
    origin: null,
    reputation: 2,
    startingWealth: 500,
    crewConcept: null,
    mutant: false,
    mutantLineage: null,
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

describe('UpdateCharacterHandler', () => {
  let repo: ICharacterRepo;
  let handler: UpdateCharacterHandler;

  beforeEach(() => {
    repo = makeRepo();
    vi.mocked(fakeEventBus.publish).mockReset();
    handler = new UpdateCharacterHandler(repo, fakeEventBus);
  });

  it('updates name and returns refreshed model', async () => {
    const existing = makeCharacter();
    const updated = makeCharacter({ name: 'Hassan' });
    vi.mocked(repo.findActiveById).mockResolvedValue(existing);
    vi.mocked(repo.update).mockResolvedValue(updated);

    const dto = Object.assign(new UpdateCharacterDto(), { name: 'Hassan' });
    const result = await handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto));

    expect(result.name).toBe('Hassan');
    expect(repo.update).toHaveBeenCalledWith('char-1', expect.objectContaining({ name: 'Hassan' }));
  });

  it('throws CharacterNotFoundError for missing character', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(null);

    const dto = Object.assign(new UpdateCharacterDto(), { name: 'NewName' });
    await expect(
      handler.execute(new UpdateCharacterCommand('missing', 'user-1', dto)),
    ).rejects.toBeInstanceOf(CharacterNotFoundError);
  });

  it('throws CharacterNotFoundError with 404 status', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(null);

    const dto = Object.assign(new UpdateCharacterDto(), {});
    await expect(
      handler.execute(new UpdateCharacterCommand('missing', 'user-1', dto)),
    ).rejects.toMatchObject({ status: 404, code: 'CHARACTER_NOT_FOUND' });
  });

  it('throws CharacterNotOwnedError when ownerId does not match', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ ownerId: 'other-user' }));

    const dto = Object.assign(new UpdateCharacterDto(), { name: 'NewName' });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);
  });

  it('throws CharacterNotOwnedError with 403 status', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ ownerId: 'other-user' }));

    const dto = Object.assign(new UpdateCharacterDto(), {});
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toMatchObject({ status: 403, code: 'CHARACTER_NOT_OWNED' });
  });

  it('throws CharacterNameEmptyError when name is empty string', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter());

    const dto = Object.assign(new UpdateCharacterDto(), { name: '' });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(CharacterNameEmptyError);
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('throws AttributeOutOfRangeError when attribute is out of bounds (strength=0)', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter());

    const dto = Object.assign(new UpdateCharacterDto(), {
      attributes: { strength: 0, agility: 2, wits: 2, empathy: 2 },
    });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(AttributeOutOfRangeError);
  });

  it('throws AttributeOutOfRangeError when attribute is 1 (below new floor of 2)', async () => {
    // ГЛАВА 2 «ХАРАКТЕРИСТИКИ»: no in-game mechanic lowers an attribute below 2.
    // The floor was lifted from 1 → 2 in Block D of T-2026-05-10-010.
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter());

    const dto = Object.assign(new UpdateCharacterDto(), {
      attributes: { strength: 1, agility: 2, wits: 2, empathy: 2 },
    });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(AttributeOutOfRangeError);
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('throws AttributeOutOfRangeError when attribute exceeds 5', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter());

    const dto = Object.assign(new UpdateCharacterDto(), {
      attributes: { strength: 6, agility: 2, wits: 2, empathy: 2 },
    });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(AttributeOutOfRangeError);
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('does not throw for attribute at floor (strength=2)', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter());
    vi.mocked(repo.update).mockResolvedValue(
      makeCharacter({ attributes: { strength: 2, agility: 2, wits: 2, empathy: 2 } }),
    );

    const dto = Object.assign(new UpdateCharacterDto(), {
      attributes: { strength: 2, agility: 2, wits: 2, empathy: 2 },
    });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).resolves.toBeDefined();
  });

  it('does not throw for attribute at ceiling (strength=5)', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter());
    vi.mocked(repo.update).mockResolvedValue(
      makeCharacter({ attributes: { strength: 5, agility: 2, wits: 2, empathy: 2 } }),
    );

    const dto = Object.assign(new UpdateCharacterDto(), {
      attributes: { strength: 5, agility: 2, wits: 2, empathy: 2 },
    });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).resolves.toBeDefined();
  });

  it('throws SkillOutOfRangeError when skill exceeds 5', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter());

    const dto = Object.assign(new UpdateCharacterDto(), {
      skills: { ...DEFAULT_SKILLS, force: 6 },
    });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(SkillOutOfRangeError);
  });

  it('publishes CharacterUpdatedEvent after update', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter());
    vi.mocked(repo.update).mockResolvedValue(makeCharacter({ name: 'Updated' }));

    const dto = Object.assign(new UpdateCharacterDto(), { name: 'Updated' });
    await handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto));

    expect(fakeEventBus.publish).toHaveBeenCalledOnce();
  });

  it('does not update unset fields', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter());
    vi.mocked(repo.update).mockResolvedValue(makeCharacter());

    const dto = Object.assign(new UpdateCharacterDto(), { experience: 5 });
    await handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto));

    expect(repo.update).toHaveBeenCalledWith(
      'char-1',
      expect.not.objectContaining({ name: expect.anything() }),
    );
  });

  it('throws ReadOnlyFieldError when dto contains hp.max', async () => {
    const dto = Object.assign(new UpdateCharacterDto(), { hp: { max: 99 } });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(ReadOnlyFieldError);
    expect(repo.findActiveById).not.toHaveBeenCalled();
  });

  it('throws ReadOnlyFieldError with 422 status for hp.max', async () => {
    const dto = Object.assign(new UpdateCharacterDto(), { hp: { max: 99 } });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toMatchObject({ status: 422, code: 'READ_ONLY_FIELD' });
  });

  it('throws ReadOnlyFieldError when dto contains mp.max', async () => {
    const dto = Object.assign(new UpdateCharacterDto(), { mp: { max: 99 } });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(ReadOnlyFieldError);
  });

  it('throws ReadOnlyFieldError when dto contains encumbrance.max', async () => {
    const dto = Object.assign(new UpdateCharacterDto(), { encumbrance: { max: 99 } });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(ReadOnlyFieldError);
  });

  it('throws ReadOnlyFieldError when dto contains encumbrance.current', async () => {
    const dto = Object.assign(new UpdateCharacterDto(), { encumbrance: { current: 5 } });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(ReadOnlyFieldError);
  });

  it('allows hp.current without throwing ReadOnlyFieldError', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter());
    vi.mocked(repo.update).mockResolvedValue(makeCharacter({ hp: { current: 5, max: 6 } }));

    const dto = Object.assign(new UpdateCharacterDto(), { hp: { current: 5 } });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).resolves.toBeDefined();
  });

  // ── status transitions (ADR 0002, T-5.6.1.b) ────────────────────────────────

  it('permits draft → active transition and passes status to repo', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ status: 'draft' }));
    vi.mocked(repo.update).mockResolvedValue(makeCharacter({ status: 'active' }));

    const dto = Object.assign(new UpdateCharacterDto(), { status: 'active' });
    const result = await handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto));

    expect(result.status).toBe('active');
    expect(repo.update).toHaveBeenCalledWith(
      'char-1',
      expect.objectContaining({ status: 'active' }),
    );
  });

  it('throws InvalidStatusTransitionError for active → draft with 422 status', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ status: 'active' }));

    const dto = Object.assign(new UpdateCharacterDto(), { status: 'draft' });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(InvalidStatusTransitionError);
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('rejects active → draft with code INVALID_STATUS_TRANSITION and status 422', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ status: 'active' }));

    const dto = Object.assign(new UpdateCharacterDto(), { status: 'draft' });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toMatchObject({ status: 422, code: 'INVALID_STATUS_TRANSITION' });
  });

  it('allows draft → draft no-op without error', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ status: 'draft' }));
    vi.mocked(repo.update).mockResolvedValue(makeCharacter({ status: 'draft' }));

    const dto = Object.assign(new UpdateCharacterDto(), { status: 'draft' });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).resolves.toBeDefined();
  });

  it('allows active → active no-op without error', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ status: 'active' }));
    vi.mocked(repo.update).mockResolvedValue(makeCharacter({ status: 'active' }));

    const dto = Object.assign(new UpdateCharacterDto(), { status: 'active' });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).resolves.toBeDefined();
  });

  // ── Block 3: crewConcept lifecycle ──────────────────────────────────────────

  it('allows crewConcept change while character is draft', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(
      makeCharacter({ status: 'draft', crewConcept: null }),
    );
    vi.mocked(repo.update).mockResolvedValue(
      makeCharacter({ status: 'draft', crewConcept: 'free-trader' }),
    );

    const dto = Object.assign(new UpdateCharacterDto(), { crewConcept: 'free-trader' as const });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).resolves.toBeDefined();
    expect(repo.update).toHaveBeenCalledWith(
      'char-1',
      expect.objectContaining({ crewConcept: 'free-trader' }),
    );
  });

  it('throws CrewConceptImmutableError when changing crewConcept on an active character', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(
      makeCharacter({ status: 'active', crewConcept: 'free-trader' }),
    );

    const dto = Object.assign(new UpdateCharacterDto(), { crewConcept: 'mercenary' as const });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(CrewConceptImmutableError);
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('does not call update with crewConcept when DTO omits it', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(
      makeCharacter({ status: 'active', crewConcept: 'free-trader' }),
    );
    vi.mocked(repo.update).mockResolvedValue(
      makeCharacter({ status: 'active', crewConcept: 'free-trader', name: 'New' }),
    );

    const dto = Object.assign(new UpdateCharacterDto(), { name: 'New' });
    await handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto));

    const updateArg = vi.mocked(repo.update).mock.calls[0]?.[1] ?? {};
    expect(Object.hasOwn(updateArg, 'crewConcept')).toBe(false);
  });

  // -------- Role validation (Block E) --------

  describe('role validation on update', () => {
    it('setting a role that belongs to the concept succeeds and clears roleUnmigrated', async () => {
      vi.mocked(repo.findActiveById).mockResolvedValue(
        makeCharacter({ status: 'draft', concept: 'pilot', role: 'ace', roleUnmigrated: true }),
      );
      vi.mocked(repo.update).mockResolvedValue(
        makeCharacter({ status: 'draft', concept: 'pilot', role: 'driver', roleUnmigrated: false }),
      );

      const dto = Object.assign(new UpdateCharacterDto(), { role: 'driver' });
      await handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto));

      expect(repo.update).toHaveBeenCalledWith(
        'char-1',
        expect.objectContaining({ role: 'driver', roleUnmigrated: false }),
      );
    });

    it('clearing roleUnmigrated when user explicitly picks a role on a migrated row', async () => {
      vi.mocked(repo.findActiveById).mockResolvedValue(
        makeCharacter({
          status: 'draft',
          concept: 'soldier',
          role: 'legionnaire',
          roleUnmigrated: true,
        }),
      );
      vi.mocked(repo.update).mockResolvedValue(
        makeCharacter({
          status: 'draft',
          concept: 'soldier',
          role: 'officer',
          roleUnmigrated: false,
        }),
      );

      const dto = Object.assign(new UpdateCharacterDto(), { role: 'officer' });
      await handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto));

      expect(repo.update).toHaveBeenCalledWith(
        'char-1',
        expect.objectContaining({ role: 'officer', roleUnmigrated: false }),
      );
    });

    it('throws RoleConceptMismatchError when role does not belong to existing concept', async () => {
      vi.mocked(repo.findActiveById).mockResolvedValue(
        makeCharacter({ status: 'draft', concept: 'pilot' }),
      );

      const dto = Object.assign(new UpdateCharacterDto(), { role: 'legionnaire' });
      await expect(
        handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
      ).rejects.toBeInstanceOf(RoleConceptMismatchError);
      expect(repo.update).not.toHaveBeenCalled();
    });

    it('RoleConceptMismatchError has status 400 and code ROLE_CONCEPT_MISMATCH', async () => {
      vi.mocked(repo.findActiveById).mockResolvedValue(
        makeCharacter({ status: 'draft', concept: 'artist' }),
      );

      const dto = Object.assign(new UpdateCharacterDto(), { role: 'ace' });
      await expect(
        handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
      ).rejects.toMatchObject({ status: 400, code: 'ROLE_CONCEPT_MISMATCH' });
    });
  });

  describe('mutant flag (ST3001 ch.4)', () => {
    it('persists mutant + lineage while draft', async () => {
      vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ status: 'draft' }));
      vi.mocked(repo.update).mockResolvedValue(
        makeCharacter({ status: 'draft', mutant: true, mutantLineage: 'zirba' }),
      );

      const dto = Object.assign(new UpdateCharacterDto(), {
        mutant: true,
        mutantLineage: 'zirba',
      });
      await handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto));

      expect(repo.update).toHaveBeenCalledWith(
        'char-1',
        expect.objectContaining({ mutant: true, mutantLineage: 'zirba' }),
      );
    });

    it('rejects toggling mutant on an active character (MUTANT_IMMUTABLE)', async () => {
      vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ status: 'active' }));

      const dto = Object.assign(new UpdateCharacterDto(), {
        mutant: true,
        mutantLineage: 'shingura',
      });

      await expect(
        handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
      ).rejects.toBeInstanceOf(MutantImmutableError);
      expect(repo.update).not.toHaveBeenCalled();
    });

    it('rejects mutant=true without lineage even on a draft', async () => {
      vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter({ status: 'draft' }));

      const dto = Object.assign(new UpdateCharacterDto(), { mutant: true });

      await expect(
        handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
      ).rejects.toBeInstanceOf(MutantLineageRequiredError);
      expect(repo.update).not.toHaveBeenCalled();
    });

    it('rejects clearing mutant while keeping a non-null lineage', async () => {
      vi.mocked(repo.findActiveById).mockResolvedValue(
        makeCharacter({ status: 'draft', mutant: true, mutantLineage: 'nerida' }),
      );

      const dto = Object.assign(new UpdateCharacterDto(), { mutant: false });

      await expect(
        handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
      ).rejects.toBeInstanceOf(MutantLineageForbiddenError);
      expect(repo.update).not.toHaveBeenCalled();
    });

    it('skips mutant fields in update when DTO omits them', async () => {
      vi.mocked(repo.findActiveById).mockResolvedValue(
        makeCharacter({ status: 'active', mutant: true, mutantLineage: 'zirba' }),
      );
      vi.mocked(repo.update).mockResolvedValue(
        makeCharacter({ status: 'active', mutant: true, mutantLineage: 'zirba', name: 'New' }),
      );

      const dto = Object.assign(new UpdateCharacterDto(), { name: 'New' });
      await handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto));

      const updateArg = vi.mocked(repo.update).mock.calls[0]?.[1] ?? {};
      expect(Object.hasOwn(updateArg, 'mutant')).toBe(false);
      expect(Object.hasOwn(updateArg, 'mutantLineage')).toBe(false);
    });
  });
});
