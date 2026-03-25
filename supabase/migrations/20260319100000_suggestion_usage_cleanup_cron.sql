-- Enable pg_cron extension (already available on Supabase)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Delete suggestion_usage rows older than 4 weeks, every Sunday at 03:00 UTC
SELECT cron.schedule(
  'cleanup-suggestion-usage',
  '0 3 * * 0',
  $$DELETE FROM suggestion_usage
    WHERE (week_year * 100 + week_number) < (
      EXTRACT(ISOYEAR FROM now())::int * 100
      + EXTRACT(WEEK FROM now())::int - 4
    )$$
);

-- Simplify existing ingredients cleanup: remove logging, just delete
-- Use DO block to ignore error when the job does not exist yet (fresh setup)
DO $$
BEGIN
  PERFORM cron.unschedule('cleanup-unused-ingredients');
EXCEPTION WHEN OTHERS THEN
  -- Job does not exist — ignore
END;
$$;

SELECT cron.schedule(
  'cleanup-unused-ingredients',
  '0 3 * * *',
  $$DELETE FROM ingredients i
    WHERE NOT EXISTS (
      SELECT 1 FROM recipe_ingredients ri
      WHERE ri.ingredient_id = i.id
    )$$
);

-- Drop obsolete log table
DROP TABLE IF EXISTS cleanup_log;
