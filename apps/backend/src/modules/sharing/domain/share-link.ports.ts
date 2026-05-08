/**
 * WHY this file exists:
 * Port interfaces decouple the domain/application layer from Prisma.
 * Handlers inject IShareLinkRepo by token (SHARE_LINK_REPO).
 * The Prisma adapter in infra/ implements the interface.
 */
import type { CharacterReadModel } from '../../characters/domain/character.ports';

export interface ShareLinkReadModel {
  id: string;
  slug: string;
  characterId: string;
  includeGmNotes: boolean;
  label: string | null;
  expiresAt: string | null; // ISO-8601 or null
  revokedAt: string | null; // ISO-8601 or null
  lastViewedAt: string | null; // ISO-8601 or null
  viewCount: number;
  createdAt: string; // ISO-8601
  updatedAt: string; // ISO-8601
}

export const SHARE_LINK_REPO = Symbol('SHARE_LINK_REPO');

export interface CreateShareLinkData {
  slug: string;
  characterId: string;
  includeGmNotes: boolean;
  label: string | null;
  expiresAt: Date | null;
}

export interface ViewFlushEntry {
  slug: string;
  count: number;
}

export interface IShareLinkRepo {
  /**
   * Persist a new share link row.
   * Throws if the slug collides (UNIQUE constraint) — callers should retry
   * with a fresh slug (collision probability is negligible at expected scale).
   */
  create(data: CreateShareLinkData): Promise<ShareLinkReadModel>;

  /**
   * Resolve a slug to a raw share-link row, including all status fields.
   * Returns null if the slug does not exist.
   */
  findBySlug(slug: string): Promise<ShareLinkReadModel | null>;

  /**
   * Find a share link by id. Returns null if not found.
   */
  findById(id: string): Promise<ShareLinkReadModel | null>;

  /**
   * Returns the ownerId of the character that owns this share link.
   * Used by the revoke command to verify ownership before mutation.
   */
  findOwnerIdByShareLinkId(id: string): Promise<{ ownerId: string } | null>;

  /**
   * List all non-revoked share links for a character, newest-first.
   */
  listByCharacterId(characterId: string): Promise<ShareLinkReadModel[]>;

  /**
   * Soft-revoke a share link by setting revokedAt = now().
   * Idempotent: revoke an already-revoked link is a no-op.
   */
  revoke(id: string): Promise<void>;

  /**
   * Resolve a slug to the full character read model.
   * Returns null if the slug does not exist.
   * The share link's includeGmNotes flag is returned separately — callers
   * must apply the notes filter at the application layer.
   */
  findCharacterBySlug(slug: string): Promise<{
    shareLink: ShareLinkReadModel;
    character: CharacterReadModel;
  } | null>;

  /**
   * Batch-flush pending view counts.
   * For each entry, increments `viewCount` by `entry.count` and sets
   * `lastViewedAt` = now() in a single transaction.
   */
  flushViewCounts(entries: ViewFlushEntry[]): Promise<void>;
}
