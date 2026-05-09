import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  AttributeOutOfRangeError,
  CharacterNameEmptyError,
  CharacterNotFoundError,
  CharacterNotOwnedError,
  InvalidStatusTransitionError,
  ReadOnlyFieldError,
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

  it('throws AttributeOutOfRangeError when attribute is out of bounds', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeCharacter());

    const dto = Object.assign(new UpdateCharacterDto(), {
      attributes: { strength: 0, agility: 2, wits: 2, empathy: 2 },
    });
    await expect(
      handler.execute(new UpdateCharacterCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(AttributeOutOfRangeError);
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
});
