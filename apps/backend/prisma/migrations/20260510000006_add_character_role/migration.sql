-- Migration: add_character_role
-- Adds `role` (nullable String) and `roleUnmigrated` (Boolean, default false)
-- to the Character table per T-2026-05-10-010 Block E.
--
-- Backfill: for every row where concept IS NOT NULL AND role IS NULL,
-- sets `role` to the first canonical role for that amplua and
-- `roleUnmigrated` to TRUE. The CASE expression is idempotent — rows
-- that already have a non-null `role` are skipped by the WHERE clause.

-- AlterTable
ALTER TABLE "character" ADD COLUMN "role" TEXT;
ALTER TABLE "character" ADD COLUMN "roleUnmigrated" BOOLEAN NOT NULL DEFAULT false;

-- Backfill existing rows: assign the first canonical role per amplua
-- (companion / analyst / criminal / agitator / assassin / ace / colonist /
-- ascetic / archaeologist / ship-engineer / legionnaire) and mark them as
-- roleUnmigrated=true so the wizard can re-prompt for a confirmed pick.
UPDATE "character"
SET
  "role" = CASE "concept"
    WHEN 'artist'     THEN 'companion'
    WHEN 'networker'  THEN 'analyst'
    WHEN 'fugitive'   THEN 'criminal'
    WHEN 'negotiator' THEN 'agitator'
    WHEN 'operative'  THEN 'assassin'
    WHEN 'pilot'      THEN 'ace'
    WHEN 'pioneer'    THEN 'colonist'
    WHEN 'preacher'   THEN 'ascetic'
    WHEN 'scientist'  THEN 'archaeologist'
    WHEN 'sailor'     THEN 'ship-engineer'
    WHEN 'soldier'    THEN 'legionnaire'
    ELSE NULL
  END,
  "roleUnmigrated" = CASE
    WHEN "concept" IS NOT NULL THEN true
    ELSE false
  END
WHERE "concept" IS NOT NULL AND "role" IS NULL;
