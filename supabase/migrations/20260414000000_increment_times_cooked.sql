-- RPC function to atomically increment times_cooked
CREATE OR REPLACE FUNCTION increment_times_cooked(recipe_id_param UUID)
RETURNS void
LANGUAGE sql
AS $$
  UPDATE recipes
  SET times_cooked = times_cooked + 1
  WHERE id = recipe_id_param;
$$;
