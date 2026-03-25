-- Rate limit: max 5 recipe inserts per user per minute.
-- Step 1: Auto-populate created_by with the authenticated user's ID on insert.
-- Step 2: Count recent inserts by the same user to enforce the limit.

-- Ensure created_by is always set to the current user on insert
CREATE OR REPLACE FUNCTION public.set_recipe_created_by()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  NEW.created_by := public.supabase_uid();
  RETURN NEW;
END;
$$;

CREATE TRIGGER recipe_set_created_by
  BEFORE INSERT ON public.recipes
  FOR EACH ROW
  EXECUTE FUNCTION public.set_recipe_created_by();

-- Rate limit check: max 5 inserts per user per minute
CREATE OR REPLACE FUNCTION public.check_recipe_insert_rate_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  recent_count integer;
BEGIN
  SELECT count(*) INTO recent_count
  FROM public.recipes
  WHERE created_by = public.supabase_uid()
    AND created_at > now() - interval '1 minute';

  IF recent_count >= 5 THEN
    RAISE EXCEPTION 'Rate limit exceeded: max 5 recipe inserts per minute'
      USING ERRCODE = 'P0429';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER recipe_insert_rate_limit
  BEFORE INSERT ON public.recipes
  FOR EACH ROW
  EXECUTE FUNCTION public.check_recipe_insert_rate_limit();
