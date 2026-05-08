import { describe, it, expect, vi, beforeEach } from 'vitest';

import { CharacterNotFoundError, CharacterNotOwnedError } from '../../characters/domain/character.errors';

import { CreateShareLinkCommand, CreateShareLinkDto } from './create-share-link.command';
import { CreateShareLinkHandler } from './create-share-link.handler';

import type { ICharacterRepo } from '../../characters/domain/character.ports';
import type { IShareLinkRepo, ShareLinkReadModel } from '../domain/share-link.ports';

const MOCK_SHARE_LINK: ShareLinkReadModel = {
  id: 'sl_01',
  slug: 'AAAAAAAAAAAAAAAAAAAAAAAAA'.slice(0, 24),
  characterId: 'char_01',
  includeGmNotes: false,
  label: null,
  expiresAt: null,
  revokedAt: null,
  lastViewedAt: null,
  viewCount: 0,
  createdAt: '2026-05-09T10:00:00Z',
  updatedAt: '2026-05-09T10:00:00Z',
};

function makeHandler(): {
  handler: CreateShareLinkHandler;
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

  const handler = new CreateShareLinkHandler(characterRepo as ICharacterRepo, shareLinkRepo as IShareLinkRepo);

  return { handler, characterRepo, shareLinkRepo };
}

describe('CreateShareLinkHandler', () => {
  let handler: CreateShareLinkHandler;
  let characterRepo: ICharacterRepo;
  let shareLinkRepo: IShareLinkRepo;

  beforeEach(() => {
    ({ handler, characterRepo, shareLinkRepo } = makeHandler());
  });

  it('creates a share link when the caller owns the character', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(shareLinkRepo.create).mockResolvedValue(MOCK_SHARE_LINK);

    const dto = new CreateShareLinkDto();
    const command = new CreateShareLinkCommand('user_01', 'char_01', dto);

    const result = await handler.execute(command);

    expect(result).toEqual(MOCK_SHARE_LINK);
    expect(shareLinkRepo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        characterId: 'char_01',
        includeGmNotes: false,
        label: null,
        expiresAt: null,
      }),
    );
    // Verify a slug was generated (24 chars)
    const call = vi.mocked(shareLinkRepo.create).mock.calls[0]?.[0];
    expect(call?.slug).toHaveLength(24);
  });

  it('creates a share link with includeGmNotes=true', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(shareLinkRepo.create).mockResolvedValue({ ...MOCK_SHARE_LINK, includeGmNotes: true });

    const dto = new CreateShareLinkDto();
    dto.includeGmNotes = true;
    dto.label = 'GM copy';
    const command = new CreateShareLinkCommand('user_01', 'char_01', dto);

    await handler.execute(command);

    expect(shareLinkRepo.create).toHaveBeenCalledWith(
      expect.objectContaining({ includeGmNotes: true, label: 'GM copy' }),
    );
  });

  it('creates a share link with expiresAt', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(shareLinkRepo.create).mockResolvedValue(MOCK_SHARE_LINK);

    const dto = new CreateShareLinkDto();
    dto.expiresAt = '2027-01-01T00:00:00Z';
    const command = new CreateShareLinkCommand('user_01', 'char_01', dto);

    await handler.execute(command);

    const call = vi.mocked(shareLinkRepo.create).mock.calls[0]?.[0];
    expect(call?.expiresAt).toEqual(new Date('2027-01-01T00:00:00Z'));
  });

  it('throws CharacterNotFoundError when character does not exist', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue(null);

    const command = new CreateShareLinkCommand('user_01', 'char_missing', new CreateShareLinkDto());

    await expect(handler.execute(command)).rejects.toBeInstanceOf(CharacterNotFoundError);
  });

  it('throws CharacterNotOwnedError when caller does not own the character', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_other' });

    const command = new CreateShareLinkCommand('user_01', 'char_01', new CreateShareLinkDto());

    await expect(handler.execute(command)).rejects.toBeInstanceOf(CharacterNotOwnedError);
  });
});
