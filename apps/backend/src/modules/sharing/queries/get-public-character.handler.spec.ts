import { describe, it, expect, vi, beforeEach } from 'vitest';

import type { CharacterReadModel } from '../../characters/domain/character.ports';
import {
  ShareLinkExpiredError,
  ShareLinkNotFoundError,
  ShareLinkRevokedError,
} from '../domain/share-link.errors';
import { ViewTracker } from '../infra/view-tracker';

import { GetPublicCharacterQuery } from './get-public-character.query';
import { GetPublicCharacterHandler } from './get-public-character.handler';

import type { IShareLinkRepo, ShareLinkReadModel } from '../domain/share-link.ports';

const SLUG = '3Bk7NzYqAcMpRvWxDjGhTs4Q';

const MOCK_CHARACTER: CharacterReadModel = {
  id: 'char_01',
  ownerId: 'user_01',
  name: 'Tariq',
  concept: null,
  iconId: null,
  upbringing: 'plebeian',
  origin: null,
  reputation: 2,
  startingWealth: 500,
  crewConcept: null,
  mutant: false,
  mutantLineage: null,
  attributes: { strength: 2, agility: 2, wits: 2, empathy: 2 },
  skills: {
    dexterity: 0,
    force: 0,
    infiltration: 0,
    manipulation: 0,
    meleeCombat: 0,
    observation: 0,
    rangedCombat: 0,
    survival: 0,
    command: 0,
    culture: 0,
    dataDjinn: 0,
    medicurgy: 0,
    mysticPowers: 0,
    pilot: 0,
    science: 0,
    technology: 0,
  },
  hp: { current: 14, max: 8 },
  mp: { current: 10, max: 7 },
  encumbrance: { current: 0, max: 6 },
  experience: 0,
  conditions: { exhausted: false, sleepless: false, thirsty: false, hungry: false },
  criticalInjuries: [],
  talents: [],
  relationships: [],
  inventory: [],
  notes: 'Secret GM notes',
  status: 'active',
  createdAt: '2026-05-09T10:00:00Z',
  updatedAt: '2026-05-09T10:00:00Z',
};

function makeShareLink(overrides?: Partial<ShareLinkReadModel>): ShareLinkReadModel {
  return {
    id: 'sl_01',
    slug: SLUG,
    characterId: 'char_01',
    includeGmNotes: false,
    label: null,
    expiresAt: null,
    revokedAt: null,
    lastViewedAt: null,
    viewCount: 0,
    createdAt: '2026-05-09T10:00:00Z',
    updatedAt: '2026-05-09T10:00:00Z',
    ...overrides,
  };
}

function makeHandler(): {
  handler: GetPublicCharacterHandler;
  repo: IShareLinkRepo;
  viewTracker: ViewTracker;
} {
  const repo = {
    create: vi.fn(),
    findBySlug: vi.fn(),
    findById: vi.fn(),
    findOwnerIdByShareLinkId: vi.fn(),
    listByCharacterId: vi.fn(),
    revoke: vi.fn(),
    findCharacterBySlug: vi.fn(),
    flushViewCounts: vi.fn(),
  } as unknown as IShareLinkRepo;

  const viewTracker = new ViewTracker();
  vi.spyOn(viewTracker, 'recordView');

  const handler = new GetPublicCharacterHandler(repo, viewTracker);
  return { handler, repo, viewTracker };
}

describe('GetPublicCharacterHandler', () => {
  let handler: GetPublicCharacterHandler;
  let repo: IShareLinkRepo;
  let viewTracker: ViewTracker;

  beforeEach(() => {
    ({ handler, repo, viewTracker } = makeHandler());
  });

  it('returns character with notes=null when includeGmNotes=false', async () => {
    vi.mocked(repo.findCharacterBySlug).mockResolvedValue({
      shareLink: makeShareLink({ includeGmNotes: false }),
      character: MOCK_CHARACTER,
    });

    const result = await handler.execute(new GetPublicCharacterQuery(SLUG));

    expect(result.notes).toBeNull();
    expect(viewTracker.recordView).toHaveBeenCalledWith(SLUG);
  });

  it('returns character with notes intact when includeGmNotes=true', async () => {
    vi.mocked(repo.findCharacterBySlug).mockResolvedValue({
      shareLink: makeShareLink({ includeGmNotes: true }),
      character: MOCK_CHARACTER,
    });

    const result = await handler.execute(new GetPublicCharacterQuery(SLUG));

    expect(result.notes).toBe('Secret GM notes');
  });

  it('throws ShareLinkNotFoundError for unknown slug', async () => {
    vi.mocked(repo.findCharacterBySlug).mockResolvedValue(null);

    await expect(
      handler.execute(new GetPublicCharacterQuery('unknownslug12345678901234')),
    ).rejects.toBeInstanceOf(ShareLinkNotFoundError);
  });

  it('throws ShareLinkRevokedError for revoked slug', async () => {
    vi.mocked(repo.findCharacterBySlug).mockResolvedValue({
      shareLink: makeShareLink({ revokedAt: '2026-05-09T09:00:00Z' }),
      character: MOCK_CHARACTER,
    });

    await expect(handler.execute(new GetPublicCharacterQuery(SLUG))).rejects.toBeInstanceOf(
      ShareLinkRevokedError,
    );
  });

  it('throws ShareLinkExpiredError for expired slug', async () => {
    vi.mocked(repo.findCharacterBySlug).mockResolvedValue({
      shareLink: makeShareLink({ expiresAt: '2020-01-01T00:00:00Z' }),
      character: MOCK_CHARACTER,
    });

    await expect(handler.execute(new GetPublicCharacterQuery(SLUG))).rejects.toBeInstanceOf(
      ShareLinkExpiredError,
    );
  });

  it('does not throw for a link that has not expired yet', async () => {
    const future = new Date(Date.now() + 86_400_000).toISOString();
    vi.mocked(repo.findCharacterBySlug).mockResolvedValue({
      shareLink: makeShareLink({ expiresAt: future }),
      character: MOCK_CHARACTER,
    });

    await expect(handler.execute(new GetPublicCharacterQuery(SLUG))).resolves.toBeDefined();
  });

  it('records a view via viewTracker even on successful reads', async () => {
    vi.mocked(repo.findCharacterBySlug).mockResolvedValue({
      shareLink: makeShareLink(),
      character: MOCK_CHARACTER,
    });

    await handler.execute(new GetPublicCharacterQuery(SLUG));

    expect(viewTracker.recordView).toHaveBeenCalledOnce();
  });
});
