-- Baseline migration.
--
-- Captures the schema as of commit d94d8fe ("feat(backend): add Coriolis
-- domain models to Prisma schema", 2026-05-08 10:00 +04:00) — the state
-- immediately before the first per-feature migration
-- (20260508000001_character_status). Generated via
--
--   prisma migrate diff --from-empty \
--     --to-schema <historical-schema.prisma> \
--     --script
--
-- Why this file exists at all: the original migration history was bootstrapped
-- against a `prisma db push`-synced dev database, so the first per-feature
-- migration jumped straight to ALTER TABLE without a prior CREATE TABLE.
-- `prisma migrate deploy` against a fresh database failed at migration #1
-- with `relation "character" does not exist`. This baseline records the
-- missing initial schema so deploy works against an empty DB.
--
-- For existing developer databases (those that were already synced via
-- `prisma db push` before this baseline was added): run ONCE, against your
-- local DB, to tell Prisma the baseline is already applied without
-- re-running it:
--
--   pnpm --filter @app/backend exec prisma migrate resolve \
--     --applied 20260508000000_baseline
--
-- Future schema changes: always `prisma migrate dev --name <slug>` so the
-- history stays complete. See .claude/CLAUDE.md § "Prisma migrations" for
-- the full guardrails.


-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "icon_id" AS ENUM ('lady-of-tears', 'traveler', 'messenger', 'merchant', 'dancer', 'gambler', 'judge', 'faceless-one', 'deckhand');

-- CreateEnum
CREATE TYPE "item_type" AS ENUM ('WEAPON', 'ARMOR', 'GEAR', 'CYBERNETIC', 'SHIP_MODULE', 'OTHER');

-- CreateEnum
CREATE TYPE "relationship_kind" AS ENUM ('ally', 'rival', 'family', 'mentor', 'debtor', 'creditor');

-- CreateEnum
CREATE TYPE "injury_severity" AS ENUM ('LIGHT', 'SEVERE', 'CRITICAL');

-- CreateTable
CREATE TABLE "user" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "emailVerified" BOOLEAN NOT NULL,
    "image" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "phoneNumber" TEXT,
    "phoneNumberVerified" BOOLEAN,
    "displayName" TEXT,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "user_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "session" (
    "id" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "token" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "userId" TEXT NOT NULL,

    CONSTRAINT "session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "account" (
    "id" TEXT NOT NULL,
    "accountId" TEXT NOT NULL,
    "providerId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "accessToken" TEXT,
    "refreshToken" TEXT,
    "idToken" TEXT,
    "accessTokenExpiresAt" TIMESTAMP(3),
    "refreshTokenExpiresAt" TIMESTAMP(3),
    "scope" TEXT,
    "password" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "verification" (
    "id" TEXT NOT NULL,
    "identifier" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3),
    "updatedAt" TIMESTAMP(3),

    CONSTRAINT "verification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "character" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "concept" TEXT,
    "iconId" "icon_id",
    "attributes" JSONB NOT NULL,
    "skills" JSONB NOT NULL,
    "hpCurrent" INTEGER NOT NULL DEFAULT 14,
    "mpCurrent" INTEGER NOT NULL DEFAULT 10,
    "experience" INTEGER NOT NULL DEFAULT 0,
    "conditions" JSONB NOT NULL,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "character_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "item" (
    "id" TEXT NOT NULL,
    "characterId" TEXT NOT NULL,
    "type" "item_type" NOT NULL,
    "data" JSONB NOT NULL,

    CONSTRAINT "item_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "talent" (
    "id" TEXT NOT NULL,
    "characterId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "rank" INTEGER NOT NULL DEFAULT 1,
    "acquiredAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "talent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "relationship" (
    "id" TEXT NOT NULL,
    "characterId" TEXT NOT NULL,
    "targetName" TEXT NOT NULL,
    "kind" "relationship_kind" NOT NULL,
    "notes" TEXT,

    CONSTRAINT "relationship_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "critical_injury" (
    "id" TEXT NOT NULL,
    "characterId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "severity" "injury_severity" NOT NULL,
    "effect" TEXT NOT NULL,
    "acquiredAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "critical_injury_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "user_email_key" ON "user"("email");

-- CreateIndex
CREATE UNIQUE INDEX "user_phoneNumber_key" ON "user"("phoneNumber");

-- CreateIndex
CREATE UNIQUE INDEX "session_token_key" ON "session"("token");

-- CreateIndex
CREATE INDEX "character_ownerId_idx" ON "character"("ownerId");

-- CreateIndex
CREATE INDEX "item_characterId_idx" ON "item"("characterId");

-- CreateIndex
CREATE INDEX "talent_characterId_idx" ON "talent"("characterId");

-- CreateIndex
CREATE INDEX "relationship_characterId_idx" ON "relationship"("characterId");

-- CreateIndex
CREATE INDEX "critical_injury_characterId_idx" ON "critical_injury"("characterId");

-- AddForeignKey
ALTER TABLE "session" ADD CONSTRAINT "session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "account" ADD CONSTRAINT "account_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "character" ADD CONSTRAINT "character_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "item" ADD CONSTRAINT "item_characterId_fkey" FOREIGN KEY ("characterId") REFERENCES "character"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "talent" ADD CONSTRAINT "talent_characterId_fkey" FOREIGN KEY ("characterId") REFERENCES "character"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "relationship" ADD CONSTRAINT "relationship_characterId_fkey" FOREIGN KEY ("characterId") REFERENCES "character"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "critical_injury" ADD CONSTRAINT "critical_injury_characterId_fkey" FOREIGN KEY ("characterId") REFERENCES "character"("id") ON DELETE CASCADE ON UPDATE CASCADE;

