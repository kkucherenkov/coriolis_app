-- Migration: add_chat_tables
-- Adds ChatMessage, ChatReadCursor, ChatBlock tables for Phase 8 Stream C chat feature.

-- CreateTable
CREATE TABLE "chat_message" (
    "id" TEXT NOT NULL,
    "gameSessionId" TEXT NOT NULL,
    "authorMembershipId" TEXT,
    "targetMembershipId" TEXT,
    "kind" TEXT NOT NULL,
    "body" TEXT,
    "systemKey" TEXT,
    "systemParams" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "editedAt" TIMESTAMP(3),
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "chat_message_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "chat_read_cursor" (
    "membershipId" TEXT NOT NULL,
    "conversationKey" TEXT NOT NULL,
    "lastReadAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "chat_read_cursor_pkey" PRIMARY KEY ("membershipId","conversationKey")
);

-- CreateTable
CREATE TABLE "chat_block" (
    "id" TEXT NOT NULL,
    "gameSessionId" TEXT NOT NULL,
    "blockerMembershipId" TEXT NOT NULL,
    "blockedMembershipId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "chat_block_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "chat_message_gameSessionId_createdAt_idx" ON "chat_message"("gameSessionId", "createdAt");

-- CreateIndex
CREATE INDEX "chat_message_gameSessionId_authorMembershipId_targetMembershipId_createdAt_idx" ON "chat_message"("gameSessionId", "authorMembershipId", "targetMembershipId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "chat_block_gameSessionId_blockerMembershipId_blockedMembershipId_key" ON "chat_block"("gameSessionId", "blockerMembershipId", "blockedMembershipId");

-- CreateIndex
CREATE INDEX "chat_block_gameSessionId_blockedMembershipId_idx" ON "chat_block"("gameSessionId", "blockedMembershipId");

-- AddForeignKey
ALTER TABLE "chat_message" ADD CONSTRAINT "chat_message_gameSessionId_fkey" FOREIGN KEY ("gameSessionId") REFERENCES "game_session"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chat_message" ADD CONSTRAINT "chat_message_authorMembershipId_fkey" FOREIGN KEY ("authorMembershipId") REFERENCES "game_session_membership"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chat_message" ADD CONSTRAINT "chat_message_targetMembershipId_fkey" FOREIGN KEY ("targetMembershipId") REFERENCES "game_session_membership"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chat_read_cursor" ADD CONSTRAINT "chat_read_cursor_membershipId_fkey" FOREIGN KEY ("membershipId") REFERENCES "game_session_membership"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chat_block" ADD CONSTRAINT "chat_block_gameSessionId_fkey" FOREIGN KEY ("gameSessionId") REFERENCES "game_session"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chat_block" ADD CONSTRAINT "chat_block_blockerMembershipId_fkey" FOREIGN KEY ("blockerMembershipId") REFERENCES "game_session_membership"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chat_block" ADD CONSTRAINT "chat_block_blockedMembershipId_fkey" FOREIGN KEY ("blockedMembershipId") REFERENCES "game_session_membership"("id") ON DELETE CASCADE ON UPDATE CASCADE;
