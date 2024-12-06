drop policy "Enable delete for users based on receiver_id" on "public"."notifications";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.delete_notification(_sender_username text, _movie_id integer)
 RETURNS json
 LANGUAGE plpgsql
AS $function$DECLARE
  _receiver_id UUID;
  _receiver_username TEXT;
  _sender_id UUID;
  existing_notification_count int2;
BEGIN
  -- get receiver user id and receiver username
  SELECT auth.uid() INTO _receiver_id;
  SELECT username INTO _receiver_username FROM public.profiles WHERE id = _receiver_id;
  -- get sender user id
  SELECT id INTO _sender_id FROM public.profiles WHERE username = _sender_username;

  -- Check if username does not exist
  IF _receiver_id IS NULL THEN
    RAISE EXCEPTION 'User % does not exist', _receiver_username
    USING ERRCODE = 'F0002';
  END IF;

  -- Check if username does not exist
  IF _sender_id IS NULL THEN
    RAISE EXCEPTION 'User % does not exist', _sender_username
    USING ERRCODE = 'F0003';
  END IF;

  -- Check if usernames are the same
  IF _sender_id = _receiver_id THEN
    RAISE EXCEPTION 'Sender and receiver are the same user'
    USING ERRCODE = 'F0003';
  END IF;

  -- Check if the notification exists
  SELECT COUNT(*)
  INTO existing_notification_count
  FROM public.notifications
  WHERE receiver_username = _receiver_username
    AND sender_username = _sender_username
    AND movie_id = _movie_id;

  IF existing_notification_count = 0 THEN
    RAISE EXCEPTION 'Notification from % to % for movie % does not exist', _sender_username, _receiver_username, _movie_id
    USING ERRCODE = 'F0006';
  END IF;

  -- Delete notification
  DELETE FROM public.notifications
  WHERE receiver_username = _receiver_username
  AND sender_username = _sender_username
  AND movie_id = _movie_id;

  -- Return a success JSON response
  RETURN json_build_object(
    'success', TRUE,
    'message', 'Notification deleted successfully'
  );

END;$function$
;

create policy "Enable delete for users based on user_id"
on "public"."notifications"
as permissive
for delete
to public
using ((( SELECT auth.uid() AS uid) = receiver_id));



