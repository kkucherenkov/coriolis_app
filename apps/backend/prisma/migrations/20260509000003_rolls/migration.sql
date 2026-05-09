-- CreateTable
CREATE TABLE "roll" (
    "id" TEXT NOT NULL,
    "characterId" TEXT NOT NULL,
    "gameSessionId" TEXT,
    "label" TEXT NOT NULL,
    "pool" INTEGER NOT NULL,
    "dice" INTEGER[],
    "hits" INTEGER NOT NULL,
    "pushed" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "roll_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "roll_characterId_createdAt_idx" ON "roll"("characterId", "createdAt");

-- CreateIndex
CREATE INDEX "roll_gameSessionId_idx" ON "roll"("gameSessionId");

-- AddForeignKey
ALTER TABLE "roll" ADD CONSTRAINT "roll_characterId_fkey" FOREIGN KEY ("characterId") REFERENCES "character"("id") ON DELETE CASCADE ON UPDATE CASCADE;
