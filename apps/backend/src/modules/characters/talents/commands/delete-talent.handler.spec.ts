import { beforeEach, describe, expect, it, vi } from 'vitest';

import { TalentNotFoundError, TalentNotOwnedError } from '../domain/talent.errors';

import { DeleteTalentCommand } from './delete-talent.command';
import { DeleteTalentHandler } from './delete-talent.handler';

import type { ICharacterRepo, TalentReadModel } from '../../domain/character.ports';
import type { ITalentRepo } from '../domain/talent.ports';

function makeCharacterRepo(): ICharacterRepo {
  return {
    findActiveById: vi.fn(),
    findOwnerIdById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
  };
}

function makeTalentRepo(): ITalentRepo {
  return {
    findById: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
  };
}

function makeTalent(overrides: Partial<TalentReadModel & { characterId: string }> = {}): TalentReadModel & { characterId: string } {
  return {
    id: 'talent-1',
    characterId: 'char-1',
    name: 'Wing-Mate',
    description: 'Bonus',
    rank: 1,
    acquiredAt: '2026-01-15T00:00:00.000Z',
    ...overrides,
  };
}

describe('DeleteTalentHandler', () => {
  let characterRepo: ICharacterRepo;
  let talentRepo: ITalentRepo;
  let handler: DeleteTalentHandler;

  beforeEach(() => {
    characterRepo = makeCharacterRepo();
    talentRepo = makeTalentRepo();
    handler = new DeleteTalentHandler(talentRepo, characterRepo);
  });

  it('deletes talent when caller owns the parent character', async () => {
    vi.mocked(talentRepo.findById).mockResolvedValue(makeTalent());
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    vi.mocked(talentRepo.delete).mockResolvedValue(undefined);

    await expect(
      handler.execute(new DeleteTalentCommand('talent-1', 'user-1')),
    ).resolves.toBeUndefined();
    expect(talentRepo.delete).toHaveBeenCalledWith('talent-1');
  });

  it('throws TalentNotFoundError when talent does not exist', async () => {
    vi.mocked(talentRepo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new DeleteTalentCommand('missing', 'user-1')),
    ).rejects.toBeInstanceOf(TalentNotFoundError);
    expect(talentRepo.delete).not.toHaveBeenCalled();
  });

  it('throws TalentNotOwnedError when caller does not own parent character', async () => {
    vi.mocked(talentRepo.findById).mockResolvedValue(makeTalent());
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'other-user' });

    await expect(
      handler.execute(new DeleteTalentCommand('talent-1', 'user-1')),
    ).rejects.toBeInstanceOf(TalentNotOwnedError);
    expect(talentRepo.delete).not.toHaveBeenCalled();
  });

  it('returns TalentNotOwnedError with 403 status', async () => {
    vi.mocked(talentRepo.findById).mockResolvedValue(makeTalent());
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'other' });

    await expect(
      handler.execute(new DeleteTalentCommand('talent-1', 'user-1')),
    ).rejects.toMatchObject({ status: 403, code: 'TALENT_NOT_OWNED' });
  });
});
