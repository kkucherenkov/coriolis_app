-- CreateEnum
CREATE TYPE "dp_source" AS ENUM ('GM_MANUAL', 'ROLL_PUSH', 'SYSTEM');

-- CreateTable
CREATE TABLE "dp_event" (
    "id" TEXT NOT NULL,
    "gameSessionId" TEXT NOT NULL,
    "delta" INTEGER NOT NULL,
    "reason" TEXT,
    "source" "dp_source" NOT NULL,
    "rollId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "dp_event_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "dp_event_gameSessionId_createdAt_idx" ON "dp_event"("gameSessionId", "createdAt");

-- AddForeignKey
ALTER TABLE "dp_event" ADD CONSTRAINT "dp_event_gameSessionId_fkey" FOREIGN KEY ("gameSessionId") REFERENCES "game_session"("id") ON DELETE CASCADE ON UPDATE CASCADE;
