-- Add updated_at column to recipes for delta-sync support.

ALTER TABLE public.recipes
  ADD COLUMN updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

-- Backfill all existing recipes with a known baseline timestamp.
UPDATE public.recipes SET updated_at = '2026-03-30T14:00:00+02:00';

-- Auto-update trigger: only bumps updated_at when content columns actually change.
CREATE OR REPLACE FUNCTION public.set_recipe_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.title, NEW.instructions, NEW.portions, NEW.image_url, NEW.carb_tags)
     IS DISTINCT FROM
     (OLD.title, OLD.instructions, OLD.portions, OLD.image_url, OLD.carb_tags)
  THEN
    NEW.updated_at = now();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_recipe_updated_at
  BEFORE UPDATE ON public.recipes
  FOR EACH ROW
  EXECUTE FUNCTION public.set_recipe_updated_at();

-- TODO: Junction-table changes (recipe_categories, recipe_ingredients) do not
-- fire this trigger. If category/ingredient edits need to invalidate the sync
-- cache, add triggers on those tables that touch recipes.updated_at.
