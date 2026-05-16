-- Migration: drop_character_game_session
--
-- Phase 8 Stream E.
-- Drops the legacy `character_game_session` join table now that
-- `GameSessionMembership.characterId` is the single source of truth
-- for "who is at this table" (Phase 8 Stream A introduced memberships;
-- Stream E removes the parallel join + the `characterIds` API field).
--
-- Backfill discipline: before dropping the table, copy the GM's
-- first-assigned character (oldest `assignedAt`) into the GM's
-- own membership row's `characterId`, but only when that row's
-- `characterId` is still NULL. This preserves the most common
-- v1 case — GM ran a PC of their own — without losing data.
-- Players added later via the invite flow already carry their own
-- character on the membership row, so they're untouched.

-- 1. Backfill GM membership.characterId from the join table ------------
--    For each game_session, take the OLDEST character_game_session row
--    whose character is owned by the session's GM, and write its
--    characterId into that GM's membership row when null.
UPDATE "game_session_membership" gsm
SET    "characterId" = src."characterId"
FROM (
  SELECT DISTINCT ON (cgs."gameSessionId")
    cgs."gameSessionId",
    cgs."characterId",
    gs."ownerId"
  FROM "character_game_session" cgs
  JOIN "character"   c  ON c."id" = cgs."characterId"
  JOIN "game_session" gs ON gs."id" = cgs."gameSessionId"
  WHERE c."ownerId" = gs."ownerId"
  ORDER BY cgs."gameSessionId", cgs."assignedAt" ASC
) src
WHERE gsm."gameSessionId" = src."gameSessionId"
  AND gsm."userId"        = src."ownerId"
  AND gsm."role"          = 'gm'
  AND gsm."characterId"   IS NULL
  AND gsm."leftAt"        IS NULL;

-- 2. Drop the join table -----------------------------------------------
--    Prisma cascades remove the FK constraints with the table itself.
DROP TABLE "character_game_session";
