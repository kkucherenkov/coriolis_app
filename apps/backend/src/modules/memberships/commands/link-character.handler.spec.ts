import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  CharacterNotOwnedError,
  MembershipNotAuthorizedError,
  MembershipNotFoundError,
} from '../domain/membership.errors';

import { LinkCharacterCommand } from './link-character.command';
import { LinkCharacterHandler, type ICharacterOwnership } from './link-character.handler';

import type { EventBus } from '@nestjs/cqrs';
import type { IMembershipRepo, MembershipReadModel } from '../domain/membership.ports';

function makeRepo(): IMembershipRepo {
  return {
    listActive: vi.fn(),
    findById: vi.fn(),
    findActiveByUser: vi.fn(),
    softDelete: vi.fn(),
    setCharacter: vi.fn(),
  };
}

function makeOwnership(): ICharacterOwnership {
  return { isOwnedBy: vi.fn() };
}

function makeBus(): EventBus {
  return { publish: vi.fn(), publishAll: vi.fn() } as unknown as EventBus;
}

function makeMember(overrides: Partial<MembershipReadModel> = {}): MembershipReadModel {
  return {
    id: 'm-1',
    gameSessionId: 'gs-1',
    userId: 'user-1',
    role: 'player',
    displayName: 'Yara',
    characterId: null,
    characterName: null,
    joinedAt: '2026-05-15T10:00:00.000Z',
    leftAt: null,
    ...overrides,
  };
}

describe('LinkCharacterHandler', () => {
  let repo: IMembershipRepo;
  let ownership: ICharacterOwnership;
  let bus: EventBus;
  let handler: LinkCharacterHandler;

  beforeEach(() => {
    repo = makeRepo();
    ownership = makeOwnership();
    bus = makeBus();
    handler = new LinkCharacterHandler(repo, ownership, bus);
  });

  it('links a character the caller owns', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember());
    vi.mocked(ownership.isOwnedBy).mockResolvedValue(true);
    vi.mocked(repo.setCharacter).mockResolvedValue(
      makeMember({ characterId: 'c-1', characterName: 'Yara Zenith' }),
    );

    const result = await handler.execute(new LinkCharacterCommand('gs-1', 'user-1', 'm-1', 'c-1'));

    expect(result.characterId).toBe('c-1');
    expect(repo.setCharacter).toHaveBeenCalledWith('m-1', 'c-1');
    expect(bus.publish).toHaveBeenCalledWith(
      expect.objectContaining({ membershipId: 'm-1', characterId: 'c-1' }),
    );
  });

  it('unlinks when characterId is null', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember({ characterId: 'c-old' }));
    vi.mocked(repo.setCharacter).mockResolvedValue(makeMember({ characterId: null }));

    await handler.execute(new LinkCharacterCommand('gs-1', 'user-1', 'm-1', null));

    expect(ownership.isOwnedBy).not.toHaveBeenCalled();
    expect(repo.setCharacter).toHaveBeenCalledWith('m-1', null);
  });

  it('refuses to link a character the caller does not own', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember());
    vi.mocked(ownership.isOwnedBy).mockResolvedValue(false);
    await expect(
      handler.execute(new LinkCharacterCommand('gs-1', 'user-1', 'm-1', 'c-OTHER')),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);
  });

  it('refuses cross-user link', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember({ userId: 'OTHER' }));
    await expect(
      handler.execute(new LinkCharacterCommand('gs-1', 'user-1', 'm-1', 'c-1')),
    ).rejects.toBeInstanceOf(MembershipNotAuthorizedError);
  });

  it('refuses non-existent membership', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);
    await expect(
      handler.execute(new LinkCharacterCommand('gs-1', 'user-1', 'm-X', 'c-1')),
    ).rejects.toBeInstanceOf(MembershipNotFoundError);
  });
});
