-- Add show_carb_tags flag to groups table
-- Controls whether carb-tag variety scoring is used in recipe suggestions
ALTER TABLE groups ADD COLUMN IF NOT EXISTS show_carb_tags BOOLEAN NOT NULL DEFAULT TRUE;
