set check_function_bodies = off;

CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
  'set_reviews_not_editable',   -- Name of the job (can be any unique identifier)
  '*/1 * * * *',                -- Cron expression to run every minute
  $$
  UPDATE "public"."Reviews"
  SET editable = false
  WHERE editable = true AND created_at <= NOW() - INTERVAL '10 minutes';
  $$                            -- SQL command to run
);