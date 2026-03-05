-- Add group settings columns to groups table
ALTER TABLE groups
  ADD COLUMN IF NOT EXISTS week_start_day TEXT NOT NULL DEFAULT 'monday',
  ADD COLUMN IF NOT EXISTS default_meal_slots JSONB NOT NULL DEFAULT '["breakfast","lunch","dinner"]'::jsonb;
