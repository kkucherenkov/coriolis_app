/**
 * WHY this file exists:
 * Minimal read port used by RealtimeService to determine which Centrifugo
 * session channels a given user is allowed to subscribe to.
 *
 * A full IGameSessionRepo would create a circular module dependency:
 *   GameSessionsModule → RealtimeModule (for CENTRIFUGO_CLIENT)
 *   RealtimeModule → GameSessionsModule (for IGameSessionRepo)
 *
 * This port is intentionally narrow — only what the realtime ACL needs.
 * The adapter lives in realtime/infra/ and queries Prisma directly.
 */

export const SESSION_OWNERSHIP_REPO = Symbol('SESSION_OWNERSHIP_REPO');

export interface ISessionOwnershipRepo {
  /**
   * Returns the IDs of all GameSessions owned by the given user.
   * Used to build the `channels` claim in the Centrifugo JWT.
   */
  findOwnedSessionIds(userId: string): Promise<string[]>;
}
