ALTER TABLE recipes ADD COLUMN IF NOT EXISTS carb_tags jsonb DEFAULT '[]'::jsonb;
