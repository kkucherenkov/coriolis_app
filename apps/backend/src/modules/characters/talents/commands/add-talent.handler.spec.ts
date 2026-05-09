import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  CharacterNotFoundError,
  CharacterNotOwnedError,
  TalentKindDuplicateError,
} from '../../domain/character.errors';

import { AddTalentCommand, AddTalentDto } from './add-talent.command';
import { AddTalentHandler } from './add-talent.handler';

import type { ICharacterRepo, TalentReadModel } from '../../domain/character.ports';
import type { ITalentRepo } from '../domain/talent.ports';

function makeCharacterRepo(): ICharacterRepo {
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

function makeTalentRepo(): ITalentRepo {
  return {
    findById: vi.fn(),
    listByCharacterId: vi.fn().mockResolvedValue([]),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
  };
}

function makeTalent(
  overrides: Partial<TalentReadModel & { characterId: string }> = {},
): TalentReadModel & { characterId: string } {
  return {
    id: 'talent-1',
    characterId: 'char-1',
    kind: 'personal',
    name: 'Wing-Mate',
    description: 'Bonus when flying wingman',
    rank: 1,
    acquiredAt: '2026-01-15T00:00:00.000Z',
    ...overrides,
  };
}

describe('AddTalentHandler', () => {
  let characterRepo: ICharacterRepo;
  let talentRepo: ITalentRepo;
  let handler: AddTalentHandler;

  beforeEach(() => {
    characterRepo = makeCharacterRepo();
    talentRepo = makeTalentRepo();
    handler = new AddTalentHandler(characterRepo, talentRepo);
  });

  it('adds talent with default rank 1 when rank is omitted', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    vi.mocked(talentRepo.create).mockResolvedValue(makeTalent());

    const dto = Object.assign(new AddTalentDto(), {
      name: 'Wing-Mate',
      description: 'Bonus when flying wingman',
    });

    await handler.execute(new AddTalentCommand('char-1', 'user-1', dto));

    expect(talentRepo.create).toHaveBeenCalledWith(expect.objectContaining({ rank: 1 }));
  });

  it('passes provided rank', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    vi.mocked(talentRepo.create).mockResolvedValue(makeTalent({ rank: 2 }));

    const dto = Object.assign(new AddTalentDto(), {
      name: 'Wing-Mate',
      description: 'Desc',
      rank: 2,
    });

    await handler.execute(new AddTalentCommand('char-1', 'user-1', dto));

    expect(talentRepo.create).toHaveBeenCalledWith(expect.objectContaining({ rank: 2 }));
  });

  it('throws CharacterNotFoundError when character does not exist', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue(null);

    const dto = Object.assign(new AddTalentDto(), { name: 'T', description: 'D' });

    await expect(
      handler.execute(new AddTalentCommand('missing', 'user-1', dto)),
    ).rejects.toBeInstanceOf(CharacterNotFoundError);
    expect(talentRepo.create).not.toHaveBeenCalled();
  });

  it('throws CharacterNotOwnedError when character belongs to another user', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'other-user' });

    const dto = Object.assign(new AddTalentDto(), { name: 'T', description: 'D' });

    await expect(
      handler.execute(new AddTalentCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);
  });

  it('returns the created talent', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    const talent = makeTalent({ name: 'Stunt Pilot' });
    vi.mocked(talentRepo.create).mockResolvedValue(talent);

    const dto = Object.assign(new AddTalentDto(), { name: 'Stunt Pilot', description: 'Desc' });
    const result = await handler.execute(new AddTalentCommand('char-1', 'user-1', dto));

    expect(result.name).toBe('Stunt Pilot');
  });

  it('defaults kind to "personal" when omitted', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    vi.mocked(talentRepo.create).mockResolvedValue(makeTalent());

    const dto = Object.assign(new AddTalentDto(), { name: 'T', description: 'D' });
    await handler.execute(new AddTalentCommand('char-1', 'user-1', dto));

    expect(talentRepo.create).toHaveBeenCalledWith(expect.objectContaining({ kind: 'personal' }));
  });

  it('persists the explicit kind when provided', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    vi.mocked(talentRepo.create).mockResolvedValue(makeTalent({ kind: 'crew' }));

    const dto = Object.assign(new AddTalentDto(), {
      kind: 'crew' as const,
      name: 'Wing-Mate',
      description: 'Desc',
    });
    await handler.execute(new AddTalentCommand('char-1', 'user-1', dto));

    expect(talentRepo.create).toHaveBeenCalledWith(expect.objectContaining({ kind: 'crew' }));
  });

  it('rejects a second talent of a non-personal kind', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    vi.mocked(talentRepo.listByCharacterId).mockResolvedValue([
      {
        id: 'gift-1',
        kind: 'iconGift',
        name: 'Gift of the Traveler',
        description: '',
        rank: 1,
        acquiredAt: '2026-01-15T00:00:00.000Z',
      },
    ]);

    const dto = Object.assign(new AddTalentDto(), {
      kind: 'iconGift' as const,
      name: 'Another Gift',
      description: 'Desc',
    });

    await expect(
      handler.execute(new AddTalentCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(TalentKindDuplicateError);
    expect(talentRepo.create).not.toHaveBeenCalled();
  });

  it('allows multiple personal talents on the same character', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    vi.mocked(talentRepo.listByCharacterId).mockResolvedValue([
      {
        id: 'p-1',
        kind: 'personal',
        name: 'Combat Veteran',
        description: '',
        rank: 1,
        acquiredAt: '2026-01-15T00:00:00.000Z',
      },
    ]);
    vi.mocked(talentRepo.create).mockResolvedValue(makeTalent({ kind: 'personal' }));

    const dto = Object.assign(new AddTalentDto(), {
      kind: 'personal' as const,
      name: 'Investigator',
      description: 'Desc',
    });

    await expect(
      handler.execute(new AddTalentCommand('char-1', 'user-1', dto)),
    ).resolves.toBeDefined();
    expect(talentRepo.create).toHaveBeenCalled();
  });

  it('skips the duplicate check for personal talents (does not call listByCharacterId)', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    vi.mocked(talentRepo.create).mockResolvedValue(makeTalent());

    const dto = Object.assign(new AddTalentDto(), {
      kind: 'personal' as const,
      name: 'T',
      description: 'D',
    });
    await handler.execute(new AddTalentCommand('char-1', 'user-1', dto));

    expect(talentRepo.listByCharacterId).not.toHaveBeenCalled();
  });
});
