-- Migration: mutant_fields
-- Adds the MutantLineage enum (Coriolis ST3001 ch.4 §Стигмы пасынков —
-- три канонические родословные пасынков: Зирба / Шингура / Нерида), the
-- `character.mutant` boolean flag (default false), and the optional
-- `character.mutantLineage` column. Both columns are mutable while the
-- character is `draft` and immutable once `active` (enforced in the
-- application layer, not the database).

-- CreateEnum
CREATE TYPE "mutant_lineage" AS ENUM ('zirba', 'shingura', 'nerida');

-- AlterTable
ALTER TABLE "character"
  ADD COLUMN "mutant"        BOOLEAN          NOT NULL DEFAULT false,
  ADD COLUMN "mutantLineage" "mutant_lineage";
