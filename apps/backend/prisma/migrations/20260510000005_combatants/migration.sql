-- CreateEnum
CREATE TYPE "combatant_type" AS ENUM ('PC', 'NPC');

-- AlterTable: wire activeCombatantId as a real FK with onDelete:SetNull
ALTER TABLE "encounter" ADD CONSTRAINT "encounter_activeCombatantId_fkey"
  FOREIGN KEY ("activeCombatantId") REFERENCES "combatant"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- CreateTable
CREATE TABLE "combatant" (
    "id"            TEXT NOT NULL,
    "encounterId"   TEXT NOT NULL,
    "combatantType" "combatant_type" NOT NULL,
    "characterId"   TEXT,
    "npcId"         TEXT,
    "displayName"   TEXT NOT NULL,
    "initiative"    INTEGER,
    "turnOrder"     INTEGER,
    "hpCurrent"     INTEGER NOT NULL,
    "hpMax"         INTEGER NOT NULL,
    "armor"         INTEGER NOT NULL DEFAULT 0,
    "signature"     INTEGER NOT NULL DEFAULT 0,
    "statusFlags"   TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    "notes"         TEXT,
    "pcSnapshot"    JSONB,
    "npcSnapshot"   JSONB,
    "createdAt"     TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt"     TIMESTAMP(3) NOT NULL,

    CONSTRAINT "combatant_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "combatant_encounterId_idx" ON "combatant"("encounterId");

-- Unique guards for COMBATANT_DUPLICATE
-- Partial unique index: only when characterId IS NOT NULL
CREATE UNIQUE INDEX "combatant_encounterId_characterId_key"
  ON "combatant"("encounterId", "characterId")
  WHERE "characterId" IS NOT NULL;

-- Partial unique index: only when npcId IS NOT NULL
CREATE UNIQUE INDEX "combatant_encounterId_npcId_key"
  ON "combatant"("encounterId", "npcId")
  WHERE "npcId" IS NOT NULL;

-- AddForeignKey: combatant → encounter
ALTER TABLE "combatant" ADD CONSTRAINT "combatant_encounterId_fkey"
  FOREIGN KEY ("encounterId") REFERENCES "encounter"("id") ON DELETE CASCADE ON UPDATE CASCADE;
