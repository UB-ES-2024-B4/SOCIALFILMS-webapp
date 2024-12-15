CREATE OR REPLACE FUNCTION public.get_notifications()
RETURNS json
LANGUAGE plpgsql
AS $function$
DECLARE
  notifications_array JSON;
  unread_count INT;
  final_result JSON;
BEGIN
  SELECT 
    json_agg(p),
    (SELECT COUNT(*) FROM public.notifications WHERE receiver_id = auth.uid() AND is_read = FALSE) 
  INTO notifications_array, unread_count
  FROM (
    SELECT 
      sender_id,
      receiver_id,
      movie_id,
      is_read,
      receiver_username,
      sender_username,
      created_at
    FROM public.notifications
    WHERE receiver_id = auth.uid()
  ) p;

  IF notifications_array IS NULL THEN
    RAISE EXCEPTION 'No notifications found'
    USING ERRCODE = 'F0001';
  END IF;

  SELECT json_build_object(
    'notifications', notifications_array,
    'unread_count', unread_count
  ) INTO final_result;

  RETURN final_result;

END;
$function$
;