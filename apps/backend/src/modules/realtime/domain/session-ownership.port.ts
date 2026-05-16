/**
 * WHY this file exists:
 * Minimal read port used by RealtimeService to determine which Centrifugo
 * session channels a given user is allowed to subscribe to.
 *
 * Renamed from ISessionOwnershipRepo (GM-only) to ISessionAccessRepo in
 * Stream B — now covers any user with an active membership (leftAt IS NULL).
 *
 * The narrow-port pattern is preserved to avoid a circular module dependency:
 *   GameSessionsModule → RealtimeModule (for CENTRIFUGO_CLIENT)
 *   RealtimeModule → GameSessionsModule (for IGameSessionRepo)
 * The adapter queries Prisma directly in realtime/infra/.
 */

export const SESSION_ACCESS_REPO = Symbol('SESSION_ACCESS_REPO');

export interface UserMembership {
  gameSessionId: string;
  membershipId: string;
}

export interface ISessionAccessRepo {
  /**
   * Returns the IDs of all GameSessions the user has an active membership in
   * (role = 'gm' OR 'player', leftAt IS NULL).
   * Used to build the `channels` claim in the Centrifugo JWT.
   */
  findActiveSessionIdsForUser(userId: string): Promise<string[]>;

  /**
   * Returns all active memberships for the user with their gameSessionId and
   * membershipId. Used by RealtimeService to build the widened channel allow
   * list that now includes session.<id>.chat and session.<id>.member.<id>.
   */
  findActiveMembershipsForUser(userId: string): Promise<UserMembership[]>;
}
