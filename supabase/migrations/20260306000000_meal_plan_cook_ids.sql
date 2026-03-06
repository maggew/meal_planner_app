-- Replace single cook_id with cook_ids TEXT[] on meal_plan_entries
ALTER TABLE meal_plan_entries
  DROP COLUMN IF EXISTS cook_id,
  ADD COLUMN IF NOT EXISTS cook_ids TEXT[] NOT NULL DEFAULT '{}';
