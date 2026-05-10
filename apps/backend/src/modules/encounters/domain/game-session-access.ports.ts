/**
 * WHY this file exists:
 * Port interface for GameSession access checks used by the encounters module.
 * The encounters module needs to verify two things:
 *  - isOwner: caller is the GM owner (required for writes)
 *  - isMember: caller is the GM owner OR has a character assigned to the session
 *              (required for reads)
 *
 * This interface is implemented in infra/ using the PrismaService, so the
 * handlers stay free of DB concerns. Unit tests inject a test double.
 */

export const GAME_SESSION_ACCESS = Symbol('GAME_SESSION_ACCESS');

export interface IGameSessionAccess {
  /**
   * Returns true if `userId` is the ownerId of game session `sessionId`.
   * Returns false (not throws) when the session does not exist.
   */
  isOwner(sessionId: string, userId: string): Promise<boolean>;

  /**
   * Returns true if `userId` is the owner OR has a character assigned to
   * game session `sessionId`. Returns false when the session doesn't exist
   * (don't leak existence to callers who aren't members).
   */
  isMember(sessionId: string, userId: string): Promise<boolean>;

  /**
   * Returns the ownerId of the session, or null if not found.
   * Used by encounter handlers to resolve sessionId from an encounter.
   */
  getOwnerId(sessionId: string): Promise<string | null>;
}
