-- Migration: add_memberships_and_invite
--
-- Phase 8 Stream A.
-- Adds:
--   1. invite fields on game_session (inviteTokenHash, inviteRotatedAt,
--      inviteCreatedById).
--   2. game_session_membership table with (gameSessionId, userId) unique,
--      (userId) indexed.
-- Backfill: for every existing game_session row, INSERT a GM-role
-- membership for its owner. This is required so the existing realtime
-- ACL ("session.<id> for any active membership", to land in Stream B)
-- continues to authorise the GM after Stream B widens the ACL query.

-- 1. Extend game_session ------------------------------------------------
ALTER TABLE "game_session"
  ADD COLUMN "inviteTokenHash"   CHAR(64),
  ADD COLUMN "inviteRotatedAt"   TIMESTAMP(3),
  ADD COLUMN "inviteCreatedById" TEXT;

-- 2. Create game_session_membership ------------------------------------
CREATE TABLE "game_session_membership" (
  "id"            TEXT NOT NULL,
  "gameSessionId" TEXT NOT NULL,
  "userId"        TEXT NOT NULL,
  "role"          TEXT NOT NULL,
  "characterId"   TEXT,
  "joinedAt"      TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "leftAt"        TIMESTAMP(3),

  CONSTRAINT "game_session_membership_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "game_session_membership_gameSessionId_userId_key"
  ON "game_session_membership"("gameSessionId", "userId");

CREATE INDEX "game_session_membership_userId_idx"
  ON "game_session_membership"("userId");

ALTER TABLE "game_session_membership"
  ADD CONSTRAINT "game_session_membership_gameSessionId_fkey"
    FOREIGN KEY ("gameSessionId") REFERENCES "game_session"("id")
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT "game_session_membership_characterId_fkey"
    FOREIGN KEY ("characterId") REFERENCES "character"("id")
    ON DELETE SET NULL ON UPDATE CASCADE;

-- 3. Backfill GM memberships --------------------------------------------
-- One row per existing game_session, role="gm", characterId NULL.
-- joinedAt mirrors the session's createdAt so the audit trail is honest.
INSERT INTO "game_session_membership" ("id", "gameSessionId", "userId", "role", "joinedAt")
SELECT
  -- 24-char cuid-like id, prefixed so backfill rows are auditable.
  'cmbf' || substr(md5(gs.id || gs."ownerId" || gs."createdAt"::text), 1, 20),
  gs.id,
  gs."ownerId",
  'gm',
  gs."createdAt"
FROM "game_session" gs
WHERE NOT EXISTS (
  SELECT 1
  FROM "game_session_membership" m
  WHERE m."gameSessionId" = gs.id AND m."userId" = gs."ownerId"
);
