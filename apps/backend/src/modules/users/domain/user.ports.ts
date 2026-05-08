/**
 * WHY this file exists:
 * Port interfaces keep the domain and application layers free of infrastructure.
 * The Prisma adapter in `infra/user.repo.ts` implements these interfaces and is
 * registered by token in `users.module.ts`. Handlers never import Prisma directly.
 */

export const USER_REPO = Symbol('USER_REPO');

/**
 * Read model returned by getMe / updateMe — maps exactly to the OpenAPI `Me` schema.
 * `displayName` is `null` when the user has not set one.
 */
export interface MeReadModel {
  id: string;
  email: string;
  displayName: string | null;
  createdAt: string; // ISO-8601
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
   * Stamp `deletedAt` on the user row. Idempotent: if the row is already
   * soft-deleted (or does not exist) the call is a no-op.
   * Returns the timestamp written to `deletedAt`, or `null` when the row
   * was already deleted / not found (caller should still return 204).
   */
  softDelete(id: string, deletedAt: Date): Promise<Date | null>;
}
