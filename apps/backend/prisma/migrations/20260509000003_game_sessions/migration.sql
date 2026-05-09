-- CreateEnum
CREATE TYPE "game_session_status" AS ENUM ('ACTIVE', 'ARCHIVED');

-- CreateTable
CREATE TABLE "game_session" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "status" "game_session_status" NOT NULL DEFAULT 'ACTIVE',
    "dpCount" INTEGER NOT NULL DEFAULT 0,
    "shipId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "game_session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "character_game_session" (
    "characterId" TEXT NOT NULL,
    "gameSessionId" TEXT NOT NULL,
    "assignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "character_game_session_pkey" PRIMARY KEY ("characterId","gameSessionId")
);

-- CreateIndex
CREATE INDEX "game_session_ownerId_status_idx" ON "game_session"("ownerId", "status");

-- CreateIndex
CREATE INDEX "character_game_session_gameSessionId_idx" ON "character_game_session"("gameSessionId");

-- AddForeignKey
ALTER TABLE "game_session" ADD CONSTRAINT "game_session_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "character_game_session" ADD CONSTRAINT "character_game_session_characterId_fkey" FOREIGN KEY ("characterId") REFERENCES "character"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "character_game_session" ADD CONSTRAINT "character_game_session_gameSessionId_fkey" FOREIGN KEY ("gameSessionId") REFERENCES "game_session"("id") ON DELETE CASCADE ON UPDATE CASCADE;
