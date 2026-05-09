-- Migration: me-theme
-- Adds the `theme` column to the `user` table.
-- Default is 'dark' to match the OpenAPI Me.theme default.
-- Column is nullable to allow gradual adoption; the application layer
-- coerces NULL → 'dark' so the wire always returns a non-null value.

ALTER TABLE "user" ADD COLUMN IF NOT EXISTS "theme" TEXT DEFAULT 'dark';
