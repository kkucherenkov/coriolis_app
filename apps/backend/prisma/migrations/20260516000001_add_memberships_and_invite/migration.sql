-- AlterTable
ALTER TABLE "game_session" ADD COLUMN     "inviteCreatedById" TEXT,
ADD COLUMN     "inviteRotatedAt" TIMESTAMP(3),
ADD COLUMN     "inviteTokenHash" CHAR(64);

-- CreateTable
CREATE TABLE "game_session_membership" (
    "id" TEXT NOT NULL,
    "gameSessionId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    "characterId" TEXT,
    "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "leftAt" TIMESTAMP(3),

    CONSTRAINT "game_session_membership_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "game_session_membership_userId_idx" ON "game_session_membership"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "game_session_membership_gameSessionId_userId_key" ON "game_session_membership"("gameSessionId", "userId");

-- AddForeignKey
ALTER TABLE "game_session_membership" ADD CONSTRAINT "game_session_membership_gameSessionId_fkey" FOREIGN KEY ("gameSessionId") REFERENCES "game_session"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "game_session_membership" ADD CONSTRAINT "game_session_membership_characterId_fkey" FOREIGN KEY ("characterId") REFERENCES "character"("id") ON DELETE SET NULL ON UPDATE CASCADE;
