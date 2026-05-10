-- CreateEnum
CREATE TYPE "ship_class" AS ENUM ('fighter', 'shuttle', 'torpedo-boat', 'light-freighter', 'light-passenger', 'courier-yacht', 'clipper', 'patrol-boat', 'gunboat', 'assault-ship', 'blockade-runner', 'pleasure-yacht', 'flying-circus', 'prospector', 'rescue-ship', 'passenger-liner', 'heavy-freighter', 'cruiser', 'destroyer', 'heavy-cruiser');

-- CreateEnum
CREATE TYPE "ship_module_slot" AS ENUM ('BRIDGE', 'REACTOR', 'DRIVE', 'HOLD', 'WEAPON', 'TORPEDO', 'SENSOR', 'COMMS', 'HANGAR', 'QUARTERS', 'MEDICAL', 'WORKSHOP', 'CHAPEL', 'ESCAPE-PODS', 'CRYO', 'DOCKING', 'MINING', 'REPAIR', 'CONCEALED-HOLD', 'PROXY-DECK', 'OTHER');

-- CreateEnum
CREATE TYPE "crew_position" AS ENUM ('captain', 'pilot', 'sensorOp', 'gunner', 'engineer', 'serviceCrew');

-- CreateTable
CREATE TABLE "ship" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "class" "ship_class" NOT NULL,
    "model" TEXT,
    "registry" TEXT,
    "hullCurrent" INTEGER NOT NULL DEFAULT 0,
    "hullMax" INTEGER NOT NULL DEFAULT 0,
    "energyCurrent" INTEGER NOT NULL DEFAULT 0,
    "energyMax" INTEGER NOT NULL DEFAULT 0,
    "armor" INTEGER NOT NULL DEFAULT 0,
    "maneuverability" INTEGER NOT NULL DEFAULT 0,
    "signature" INTEGER NOT NULL DEFAULT 0,
    "speed" INTEGER NOT NULL DEFAULT 0,
    "cargoCapacity" INTEGER NOT NULL DEFAULT 0,
    "problems" TEXT[],
    "history" TEXT,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ship_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ship_module" (
    "id" TEXT NOT NULL,
    "shipId" TEXT NOT NULL,
    "slot" "ship_module_slot" NOT NULL,
    "name" TEXT NOT NULL,
    "energyUse" INTEGER NOT NULL DEFAULT 0,
    "data" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ship_module_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "crew_slot" (
    "shipId" TEXT NOT NULL,
    "position" "crew_position" NOT NULL,
    "assignedCharacterId" TEXT,
    "assignedAt" TIMESTAMP(3),

    CONSTRAINT "crew_slot_pkey" PRIMARY KEY ("shipId","position")
);

-- CreateIndex
CREATE INDEX "ship_ownerId_idx" ON "ship"("ownerId");

-- CreateIndex
CREATE INDEX "ship_module_shipId_idx" ON "ship_module"("shipId");

-- CreateIndex
CREATE INDEX "crew_slot_assignedCharacterId_idx" ON "crew_slot"("assignedCharacterId");

-- AddForeignKey
ALTER TABLE "ship" ADD CONSTRAINT "ship_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ship_module" ADD CONSTRAINT "ship_module_shipId_fkey" FOREIGN KEY ("shipId") REFERENCES "ship"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "crew_slot" ADD CONSTRAINT "crew_slot_shipId_fkey" FOREIGN KEY ("shipId") REFERENCES "ship"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "crew_slot" ADD CONSTRAINT "crew_slot_assignedCharacterId_fkey" FOREIGN KEY ("assignedCharacterId") REFERENCES "character"("id") ON DELETE SET NULL ON UPDATE CASCADE;

