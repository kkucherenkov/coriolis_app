import { describe, it, expect, vi, beforeEach } from 'vitest';

import {
  CharacterNotFoundError,
  CharacterNotOwnedError,
} from '../../characters/domain/character.errors';

import { ListShareLinksQuery } from './list-share-links.query';
import { ListShareLinksHandler } from './list-share-links.handler';

import type { ICharacterRepo } from '../../characters/domain/character.ports';
import type { IShareLinkRepo, ShareLinkReadModel } from '../domain/share-link.ports';

const MOCK_LINKS: ShareLinkReadModel[] = [
  {
    id: 'sl_01',
    slug: '3Bk7NzYqAcMpRvWxDjGhTs4Q',
    characterId: 'char_01',
    includeGmNotes: false,
    label: null,
    expiresAt: null,
    revokedAt: null,
    lastViewedAt: null,
    viewCount: 0,
    createdAt: '2026-05-09T10:00:00Z',
    updatedAt: '2026-05-09T10:00:00Z',
  },
];

function makeHandler(): {
  handler: ListShareLinksHandler;
  characterRepo: ICharacterRepo;
  shareLinkRepo: IShareLinkRepo;
} {
  const characterRepo = {
    findOwnerIdById: vi.fn(),
    findActiveById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    deleteAbandonedDrafts: vi.fn(),
    delete: vi.fn(),
  } as unknown as ICharacterRepo;

  const shareLinkRepo = {
    create: vi.fn(),
    findBySlug: vi.fn(),
    findById: vi.fn(),
    findOwnerIdByShareLinkId: vi.fn(),
    listByCharacterId: vi.fn(),
    revoke: vi.fn(),
    findCharacterBySlug: vi.fn(),
    flushViewCounts: vi.fn(),
  } as unknown as IShareLinkRepo;

  const handler = new ListShareLinksHandler(characterRepo, shareLinkRepo);
  return { handler, characterRepo, shareLinkRepo };
}

describe('ListShareLinksHandler', () => {
  let handler: ListShareLinksHandler;
  let characterRepo: ICharacterRepo;
  let shareLinkRepo: IShareLinkRepo;

  beforeEach(() => {
    ({ handler, characterRepo, shareLinkRepo } = makeHandler());
  });

  it('returns items for the caller-owned character', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(shareLinkRepo.listByCharacterId).mockResolvedValue(MOCK_LINKS);

    const result = await handler.execute(new ListShareLinksQuery('user_01', 'char_01'));

    expect(result.items).toEqual(MOCK_LINKS);
  });

  it('throws CharacterNotFoundError when character does not exist', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue(null);

    await expect(
      handler.execute(new ListShareLinksQuery('user_01', 'char_missing')),
    ).rejects.toBeInstanceOf(CharacterNotFoundError);
  });

  it('throws CharacterNotOwnedError when caller does not own the character', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_other' });

    await expect(
      handler.execute(new ListShareLinksQuery('user_01', 'char_01')),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);
  });
});
