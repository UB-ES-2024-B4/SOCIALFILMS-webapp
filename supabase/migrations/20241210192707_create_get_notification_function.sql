set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_notifications()
 RETURNS json
 LANGUAGE plpgsql
AS $function$DECLARE
  result JSON;
BEGIN
  SELECT row_to_json(p)
  INTO result
  FROM (
    SELECT 
      sender_id,
      receiver_id,
      movie_id,
      is_read,
      receiver_username,
      sender_username
    FROM public.notifications
    WHERE receiver_id = auth.uid()
  ) p;

  -- Check if _result does not exist
  IF result IS NULL THEN
    RAISE EXCEPTION 'No notifications found'
    USING ERRCODE = 'F0001';
  END IF;

  RETURN result;

END$function$
;


