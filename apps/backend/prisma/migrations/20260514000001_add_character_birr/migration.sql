-- Migration: add_character_birr
--
-- Adds `birr` (NOT NULL Int, default 500) to the Character table per
-- T-2026-05-14-005 sub-step T-WIZARD-GEAR-BACKEND-IMPL.
--
-- `birr` is the character's current spendable wallet balance.
--
-- Backfill: every existing row receives `birr = startingWealth` so the
-- wallet starts in lockstep with the historical record. The default
-- value of 500 (plebeian baseline) only kicks in for rows that lack a
-- meaningful `startingWealth`, which by current invariants never
-- happens — `startingWealth` is set by the create-character handler.

-- AlterTable
ALTER TABLE "character" ADD COLUMN "birr" INTEGER NOT NULL DEFAULT 500;

-- Backfill: seed the wallet from startingWealth so existing characters
-- start with their full historical wealth available in the wallet.
UPDATE "character" SET "birr" = "startingWealth";
