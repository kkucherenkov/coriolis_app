-- Migration: add_user_chat_docked_collapsed
--
-- Phase 8 Stream D follow-up.
-- Promote the GM chat-dock collapse toggle from the localStorage
-- placeholder shipped in Stream D into a canonical Me-profile field
-- synced across devices.
--
-- Default false matches the existing UI behaviour ("dock visible on
-- first render"); existing rows backfill cleanly via DEFAULT.

ALTER TABLE "user"
  ADD COLUMN "chatDockedCollapsed" BOOLEAN NOT NULL DEFAULT FALSE;
