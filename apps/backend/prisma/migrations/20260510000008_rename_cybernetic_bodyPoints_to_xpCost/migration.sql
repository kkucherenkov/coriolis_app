-- Rename JSONB key bodyPoints → xpCost for all CYBERNETIC items.
-- Defaults to xpCost: 5 (canonical talent acquisition cost per ГЛАВА 4 ST3001).
-- Idempotent: rows that already have xpCost and no bodyPoints are skipped.

-- Step 1: rows with bodyPoints — strip the old key and set xpCost to 5.
UPDATE "item"
SET data = (data - 'bodyPoints') || jsonb_build_object('xpCost', 5)
WHERE type = 'CYBERNETIC'
  AND data ? 'bodyPoints';

-- Step 2: defensive backfill — rows with neither key (should not exist, but
-- belt-and-suspenders) get xpCost: 5.
UPDATE "item"
SET data = data || jsonb_build_object('xpCost', 5)
WHERE type = 'CYBERNETIC'
  AND NOT (data ? 'xpCost');
