set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.set_is_read(_sender_username text, _movie_id integer, _is_read bool)
 RETURNS json
 LANGUAGE plpgsql
AS $function$DECLARE
  _receiver_id UUID;
  _receiver_username TEXT;
  _sender_id UUID;
  rows_updated INT;
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

  -- Check if the notification is already set to the desired is_read status
  IF EXISTS (
    SELECT 1
    FROM public.notifications
    WHERE sender_id = _sender_id
    AND receiver_id = _receiver_id
    AND movie_id = _movie_id
    AND is_read = _is_read
  ) THEN

    RETURN json_build_object(
      'success', FALSE,
      'message', 'is_read is already set to ' || _is_read
    );
  END IF;
  
  -- Update the is_read field if the notification exists
  IF EXISTS (
    SELECT 1
    FROM public.notifications
    WHERE sender_id = _sender_id
    AND receiver_id = _receiver_id
    AND movie_id = _movie_id
  ) THEN
    -- Update the is_read field
    UPDATE public.notifications
    SET is_read = _is_read
    WHERE sender_id = _sender_id
    AND receiver_id = _receiver_id
    AND movie_id = _movie_id;

    RETURN json_build_object(
      'success', TRUE,
      'message', 'Notification is_read updated successfully'
    );
  ELSE
    RETURN json_build_object(
      'success', FALSE,
      'message', 'Notification not found'
    );
  END IF;

  RETURN json_build_object(
    'success', TRUE,
    'message', 'Notification is_read updated successfully'
  );

END;$function$
;


CREATE OR REPLACE FUNCTION public.get_is_read(_sender_username text, _movie_id integer)
 RETURNS JSON
 LANGUAGE plpgsql
AS $function$DECLARE
  is_read_status BOOLEAN;
  _receiver_username TEXT;
  _sender_id UUID;
  _receiver_id UUID;
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
  
  -- Retrieve the is_read status
  SELECT is_read
  INTO is_read_status
  FROM public.notifications
  WHERE sender_id = _sender_id
  AND receiver_id = _receiver_id
  AND movie_id = _movie_id;
  
  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', FALSE,
      'message', 'Notification not found'
    );
  END IF;

  RETURN json_build_object(
    'success', TRUE,
    'is_read', is_read_status
  );
END;$function$
;

CREATE OR REPLACE FUNCTION public.set_all_is_read(_is_read bool)
 RETURNS JSON
 LANGUAGE plpgsql
AS $function$DECLARE
  _receiver_id UUID;
  _receiver_username TEXT;
BEGIN
  -- get receiver user id and receiver username
  SELECT auth.uid() INTO _receiver_id;
  SELECT username INTO _receiver_username FROM public.profiles WHERE id = _receiver_id;
  
  -- Check if username does not exist
  IF _receiver_id IS NULL THEN
    RAISE EXCEPTION 'User % does not exist', _receiver_username
    USING ERRCODE = 'F0002';
  END IF;

  -- Check if username does not exist
  IF _receiver_username IS NULL THEN
    RAISE EXCEPTION 'User % does not exist', _receiver_username
    USING ERRCODE = 'F0003';
  END IF;

  -- Check if there are any notifications to update
  IF EXISTS (
    SELECT 1
    FROM public.notifications
    WHERE receiver_username = _receiver_username
      AND is_read != _is_read
  ) THEN
    -- Update all notifications for the receiver_user to set _is_read = TRUE
    UPDATE public.notifications
    SET is_read = _is_read
    WHERE receiver_username = _receiver_username;

    RETURN json_build_object(
      'success', TRUE,
      'message', 'All _is_read notifications have been updated successfully'
    );
  ELSE
    -- No notifications to update
    RETURN json_build_object(
      'success', FALSE,
      'message', 'No is_read notifications found to be updated'
    );
  END IF;

END;$function$
;