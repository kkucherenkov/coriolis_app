-- Migration: talent_kind_and_crew_concept
-- Adds the CrewConcept enum (амплуа команды per ST3001 ch.2 §АМПЛУА КОМАНДЫ),
-- the optional `character.crewConcept` column, the TalentKind discriminator
-- enum (personal | crew | iconGift | stigma), and the `talent.kind` column
-- (defaults to `personal` for legacy rows and the common case).

-- CreateEnum
CREATE TYPE "crew_concept" AS ENUM ('free-trader', 'mercenary', 'explorer', 'agents', 'pilgrim');

-- CreateEnum
CREATE TYPE "talent_kind" AS ENUM ('personal', 'crew', 'iconGift', 'stigma');

-- AlterTable
ALTER TABLE "character" ADD COLUMN     "crewConcept" "crew_concept";

-- AlterTable
ALTER TABLE "talent" ADD COLUMN     "kind" "talent_kind" NOT NULL DEFAULT 'personal';
