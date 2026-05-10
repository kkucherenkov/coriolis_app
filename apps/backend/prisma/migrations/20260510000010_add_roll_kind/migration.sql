-- AlterTable: add kind discriminator to Roll
-- Default 'skill' ensures all existing rolls migrate cleanly
-- (they were all skill rolls before this taxonomy existed).
ALTER TABLE "roll" ADD COLUMN "kind" text NOT NULL DEFAULT 'skill';
