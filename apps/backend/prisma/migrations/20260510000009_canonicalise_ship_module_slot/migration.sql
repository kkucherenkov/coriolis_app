-- Migration: canonicalise_ship_module_slot
-- Rewrites legacy lowercase ItemSlotType values stored in Item.data JSONB
-- to the canonical uppercase ShipModuleSlot enum (ГЛАВА 7).
-- Mapping: bridge→BRIDGE, hull→OTHER, hold→HOLD,
--          weapon→WEAPON, drive→DRIVE, sensor→SENSOR, comms→COMMS
-- Idempotent: ELSE clause preserves already-canonical values; WHERE clause
-- limits rows to those still carrying a legacy lowercase slug.

UPDATE "item"
SET data = jsonb_set(
  data,
  '{slot}',
  to_jsonb(
    CASE data->>'slot'
      WHEN 'bridge' THEN 'BRIDGE'
      WHEN 'hull'   THEN 'OTHER'
      WHEN 'hold'   THEN 'HOLD'
      WHEN 'weapon' THEN 'WEAPON'
      WHEN 'drive'  THEN 'DRIVE'
      WHEN 'sensor' THEN 'SENSOR'
      WHEN 'comms'  THEN 'COMMS'
      ELSE data->>'slot'
    END
  ),
  false
)
WHERE type = 'SHIP_MODULE'
  AND data ? 'slot'
  AND data->>'slot' IN ('bridge', 'hull', 'hold', 'weapon', 'drive', 'sensor', 'comms');
