-- Migration: character_status
-- Adds CharacterStatus enum and status column to the Character table.
-- Default ACTIVE preserves existing rows' semantics unchanged.

-- CreateEnum
CREATE TYPE "character_status" AS ENUM ('ACTIVE', 'DRAFT');

-- AlterTable
ALTER TABLE "character" ADD COLUMN "status" "character_status" NOT NULL DEFAULT 'ACTIVE';

-- CreateIndex
CREATE INDEX "character_status_idx" ON "character"("status");
