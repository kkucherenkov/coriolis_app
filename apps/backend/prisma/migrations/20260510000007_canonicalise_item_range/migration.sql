-- Migration: canonicalise_item_range
-- Translates personal-scale weapon range values from legacy 5-band to canonical 4-band enum.
-- Mapping: arm → close, near → close, short → medium, long → long (unchanged), distant → extreme
-- Idempotent: WHERE clause restricts to rows with legacy values only.

-- Personal-scale weapon items (Item.data->>'range')
UPDATE "item"
SET data = jsonb_set(
  data,
  '{range}',
  to_jsonb(
    CASE data->>'range'
      WHEN 'arm'     THEN 'close'
      WHEN 'near'    THEN 'close'
      WHEN 'short'   THEN 'medium'
      WHEN 'distant' THEN 'extreme'
      ELSE data->>'range'  -- 'long' stays 'long'; unknown values pass through
    END
  ),
  false
)
WHERE type = 'WEAPON'
  AND data ? 'range'
  AND data->>'range' IN ('arm', 'near', 'short', 'distant');

-- NPC weapons array (Npc.weapons is jsonb containing a JSON array; each element has .range)
UPDATE "npc" n
SET weapons = (
  SELECT COALESCE(jsonb_agg(
    CASE
      WHEN elem ? 'range' AND elem->>'range' IN ('arm', 'near') THEN
        jsonb_set(elem, '{range}', to_jsonb('close'::text))
      WHEN elem ? 'range' AND elem->>'range' = 'short' THEN
        jsonb_set(elem, '{range}', to_jsonb('medium'::text))
      WHEN elem ? 'range' AND elem->>'range' = 'distant' THEN
        jsonb_set(elem, '{range}', to_jsonb('extreme'::text))
      ELSE elem
    END
  ), '[]'::jsonb)
  FROM jsonb_array_elements(n.weapons) elem
)
WHERE jsonb_typeof(weapons) = 'array'
  AND EXISTS (
    SELECT 1 FROM jsonb_array_elements(n.weapons) e
    WHERE e ? 'range' AND e->>'range' IN ('arm', 'near', 'short', 'distant')
  );
