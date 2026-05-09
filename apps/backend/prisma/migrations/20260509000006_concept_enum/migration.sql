-- Migration: concept_enum
-- Replaces the free-text `character.concept` column with the new Concept
-- enum (11 archetypes per Coriolis core book ch.2). Existing rows lose
-- their free-text concept value (greenfield-only assumption — dev data is
-- throwaway). Future migrations cannot recover the prior strings.

-- CreateEnum
CREATE TYPE "concept" AS ENUM ('artist', 'networker', 'fugitive', 'negotiator', 'operative', 'pilot', 'pioneer', 'preacher', 'scientist', 'sailor', 'soldier');

-- AlterTable
ALTER TABLE "character" DROP COLUMN "concept",
ADD COLUMN     "concept" "concept";
