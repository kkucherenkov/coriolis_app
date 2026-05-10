-- T-2026-05-10-016: Add optional structured breakdown JSONB column to roll.
-- Null when the roll was created programmatically without a UI breakdown.
ALTER TABLE "roll" ADD COLUMN "breakdown" jsonb;
