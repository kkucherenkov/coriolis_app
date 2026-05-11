/**
 * WHY this file exists:
 * Port interfaces keep the domain and application layers free of infrastructure.
 * The Prisma adapter in `infra/user.repo.ts` implements these interfaces and is
 * registered by token in `users.module.ts`. Handlers never import Prisma directly.
 */

export const USER_REPO = Symbol('USER_REPO');

/** Allowed theme values — must match the OpenAPI `Me.theme` enum. */
export type UserTheme = 'dark' | 'high-contrast';

/**
 * Read model returned by getMe / updateMe — maps exactly to the OpenAPI `Me` schema.
 * `displayName` is `null` when the user has not set one.
 * `theme` defaults to `dark` and is always present.
 */
export interface MeReadModel {
  id: string;
  email: string;
  displayName: string | null;
  createdAt: string; // ISO-8601
  theme: UserTheme;
}

/**
 * Port interface — the only contract the domain and application layers see.
 * The SELECT shape is scoped to the use case; never over-fetch.
 */
export interface IUserRepo {
  /**
   * Find a user by id. Returns `null` when the user does not exist or has
   * been soft-deleted (`deletedAt IS NOT NULL`).
   */
  findActiveById(id: string): Promise<MeReadModel | null>;

  /**
   * Update only `displayName` on the user row. Returns the refreshed read
   * model. Throws if the row is gone (should not happen in normal flow).
   */
  updateDisplayName(id: string, displayName: string | null): Promise<MeReadModel>;

  /**
   * Update the `displayName` and/or `theme` fields on the user row.
   * Only fields present in the payload are written; absent fields are preserved.
   * Returns the refreshed read model.
   */
  updateProfile(
    id: string,
    patch: { displayName?: string | null; theme?: UserTheme },
  ): Promise<MeReadModel>;

  /**
   * Stamp `deletedAt` on the user row. Idempotent: if the row is already
   * soft-deleted (or does not exist) the call is a no-op.
   * Returns the timestamp written to `deletedAt`, or `null` when the row
   * was already deleted / not found (caller should still return 204).
   */
  softDelete(id: string, deletedAt: Date): Promise<Date | null>;
}

// ── Export port ───────────────────────────────────────────────────────────

export const EXPORT_REPO = Symbol('EXPORT_REPO');

/**
 * Minimal user envelope used inside the export bundle. Mirrors the
 * MeExportUser OpenAPI schema. Excludes email by design.
 */
export interface MeExportUserDto {
  id: string;
  displayName: string | null;
  locale: string;
}

/**
 * The bundle shape returned by ExportMeHandler. Nested array types use
 * `unknown[]` because they are owned by other bounded contexts
 * (Characters, Ships, Npcs, GameSessions) and rebuilt verbatim from
 * Prisma. The OpenAPI schema is the contract — runtime validation by
 * `express-openapi-validator` is the safety net.
 */
export interface MeExportBundle {
  $schemaVersion: '1';
  exportedAt: string; // ISO-8601 UTC
  user: MeExportUserDto;
  characters: unknown[];
  ships: unknown[];
  npcs: unknown[];
  gameSessions: unknown[];
}

export interface IExportRepo {
  /**
   * Read the user + their characters, ships, npcs, and game sessions in
   * the shape expected by the OpenAPI export schemas. NPCs are
   * user-scoped (not session-scoped) in this codebase, so they are
   * loaded as a separate top-level read.
   */
  loadBundleFor(userId: string): Promise<MeExportBundle>;
}
