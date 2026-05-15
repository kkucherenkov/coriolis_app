/**
 * WHY this file exists:
 * Port interfaces decouple the application layer from Prisma. Handlers
 * inject IMembershipRepo and IGameSessionInviteRepo by DI tokens; the
 * Prisma adapter in infra/ implements both. Unit tests swap in vi.fn()
 * mocks without bootstrapping a database.
 *
 * Read models match the OpenAPI GameSessionMembership / InviteMetadata
 * schemas exactly.
 */

export type MembershipRole = 'gm' | 'player';

export interface MembershipReadModel {
  id: string;
  gameSessionId: string;
  userId: string;
  role: MembershipRole;
  displayName: string | null;
  characterId: string | null;
  characterName: string | null;
  joinedAt: string; // ISO-8601
  leftAt: string | null;
}

export interface InviteMetadataReadModel {
  active: boolean;
  rotatedAt: string | null;
}

export const MEMBERSHIP_REPO = Symbol('MEMBERSHIP_REPO');

export interface IMembershipRepo {
  /** Lists ACTIVE (leftAt IS NULL) memberships for the session. */
  listActive(gameSessionId: string): Promise<MembershipReadModel[]>;

  /** Finds a membership by id, including soft-deleted ones. */
  findById(id: string): Promise<MembershipReadModel | null>;

  /** Finds the active membership for (gameSessionId, userId), if any. */
  findActiveByUser(gameSessionId: string, userId: string): Promise<MembershipReadModel | null>;

  /** Soft-deletes by stamping `leftAt = now()`. Idempotent. */
  softDelete(id: string): Promise<void>;

  /** Patches characterId on an existing membership. */
  setCharacter(id: string, characterId: string | null): Promise<MembershipReadModel>;
}

export const GAME_SESSION_INVITE_REPO = Symbol('GAME_SESSION_INVITE_REPO');

export interface IGameSessionInviteRepo {
  /** Asserts the caller owns this session. Throws GameSessionNotOwnerError otherwise. */
  assertOwner(gameSessionId: string, userId: string): Promise<void>;

  /** Returns {active, rotatedAt}; never the plaintext token. */
  getMetadata(gameSessionId: string): Promise<InviteMetadataReadModel>;

  /**
   * Replaces the active invite token hash. Returns the rotation timestamp.
   * The caller is responsible for generating the plaintext+hash via
   * domain/invite-token.ts.
   */
  rotate(
    gameSessionId: string,
    tokenHash: string,
    createdByUserId: string,
  ): Promise<{ rotatedAt: string }>;

  /** Nulls the invite hash field. Idempotent. */
  revoke(gameSessionId: string): Promise<void>;
}
