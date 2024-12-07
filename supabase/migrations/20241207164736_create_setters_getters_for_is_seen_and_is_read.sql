set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.set_is_seen(_sender_username text, _movie_id integer, _is_seen bool)
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

  -- Update the is_seen field
  UPDATE public.notifications
  SET is_seen = _is_seen
  WHERE sender_id = _sender_id
  AND receiver_id = _receiver_id
  AND movie_id = _movie_id;

  -- Check if any rows were updated
  GET DIAGNOSTICS rows_updated = ROW_COUNT;

  IF rows_updated = 0 THEN
    RETURN json_build_object(
      'success', FALSE,
      'message', 'Notification not found'
    );
  END IF;

  RETURN json_build_object(
    'success', TRUE,
    'message', 'Notification is_seen updated successfully'
  );

END;$function$
;

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

  -- Update the is_read field, and set is_seen to true if is_read is true
  UPDATE public.notifications
  SET is_read = _is_read,
      is_seen = CASE
                  WHEN _is_read = TRUE THEN TRUE
                  ELSE is_seen
                END
  WHERE sender_id = _sender_id
  AND receiver_id = _receiver_id
  AND movie_id = _movie_id;

  -- Check if any rows were updated
  GET DIAGNOSTICS rows_updated = ROW_COUNT;

  IF rows_updated = 0 THEN
    RETURN json_build_object(
      'success', FALSE,
      'message', 'Notification not found'
    );
  END IF;

  RETURN json_build_object(
    'success', TRUE,
    'message', 'Notification is_seen updated successfully'
  );

END;$function$
;

CREATE OR REPLACE FUNCTION public.get_is_seen(_sender_username text, _movie_id integer)
 RETURNS JSON
 LANGUAGE plpgsql
AS $function$DECLARE
  is_seen_status BOOLEAN;
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

  -- Retrieve the is_seen status
  SELECT is_seen
  INTO is_seen_status
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
    'is_seen', is_seen_status
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