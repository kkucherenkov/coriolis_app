-- CreateEnum
CREATE TYPE "encounter_status" AS ENUM ('SETUP', 'ACTIVE', 'ENDED');

-- AddColumn encounters to game_session (already handled by relation, no alter needed)

-- CreateTable
CREATE TABLE "encounter" (
    "id" TEXT NOT NULL,
    "gameSessionId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "notes" TEXT,
    "status" "encounter_status" NOT NULL DEFAULT 'SETUP',
    "round" INTEGER NOT NULL DEFAULT 0,
    "activeCombatantId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "encounter_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "encounter_gameSessionId_idx" ON "encounter"("gameSessionId");

-- AddForeignKey
ALTER TABLE "encounter" ADD CONSTRAINT "encounter_gameSessionId_fkey" FOREIGN KEY ("gameSessionId") REFERENCES "game_session"("id") ON DELETE CASCADE ON UPDATE CASCADE;
