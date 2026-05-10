-- CreateTable
CREATE TABLE "npc" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "attributes" JSONB NOT NULL,
    "skills" JSONB NOT NULL,
    "hpCurrent" INTEGER NOT NULL DEFAULT 4,
    "hpMax" INTEGER NOT NULL DEFAULT 4,
    "mpCurrent" INTEGER NOT NULL DEFAULT 4,
    "mpMax" INTEGER NOT NULL DEFAULT 4,
    "signature" INTEGER NOT NULL DEFAULT 0,
    "keySkillModifier" INTEGER NOT NULL DEFAULT 0,
    "armor" JSONB NOT NULL DEFAULT '[]',
    "weapons" JSONB NOT NULL DEFAULT '[]',
    "tags" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "npc_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "npc_ownerId_idx" ON "npc"("ownerId");

-- AddForeignKey
ALTER TABLE "npc" ADD CONSTRAINT "npc_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;
