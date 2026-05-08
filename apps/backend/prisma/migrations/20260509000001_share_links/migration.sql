-- CreateTable
CREATE TABLE "share_link" (
    "id" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "characterId" TEXT NOT NULL,
    "includeGmNotes" BOOLEAN NOT NULL DEFAULT false,
    "expiresAt" TIMESTAMP(3),
    "revokedAt" TIMESTAMP(3),
    "lastViewedAt" TIMESTAMP(3),
    "viewCount" INTEGER NOT NULL DEFAULT 0,
    "label" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "share_link_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "share_link_slug_key" ON "share_link"("slug");

-- CreateIndex
CREATE INDEX "share_link_characterId_idx" ON "share_link"("characterId");

-- CreateIndex
CREATE INDEX "share_link_revokedAt_idx" ON "share_link"("revokedAt");

-- AddForeignKey
ALTER TABLE "share_link" ADD CONSTRAINT "share_link_characterId_fkey" FOREIGN KEY ("characterId") REFERENCES "character"("id") ON DELETE CASCADE ON UPDATE CASCADE;
