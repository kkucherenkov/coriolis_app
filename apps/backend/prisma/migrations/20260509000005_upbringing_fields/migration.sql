-- Migration: upbringing_fields
-- Adds the Upbringing enum and the upbringing/origin/reputation/startingWealth
-- columns on the character table. Defaults match the plebeian baseline so any
-- pre-existing rows remain valid; the CreateCharacterHandler always supplies
-- explicit values for new rows.
-- Source: Coriolis core book ch.2, table 2.2 — "Воспитание".

-- CreateEnum
CREATE TYPE "upbringing" AS ENUM ('plebeian', 'stationary', 'aristocrat');

-- AlterTable
ALTER TABLE "character" ADD COLUMN     "origin" TEXT,
ADD COLUMN     "reputation" INTEGER NOT NULL DEFAULT 2,
ADD COLUMN     "startingWealth" INTEGER NOT NULL DEFAULT 500,
ADD COLUMN     "upbringing" "upbringing" NOT NULL DEFAULT 'plebeian';
