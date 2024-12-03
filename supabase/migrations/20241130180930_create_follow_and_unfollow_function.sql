set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.follow_user(_following_username text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$DECLARE
  _follower_id UUID;
  _following_id UUID;
  _follower_username TEXT;
BEGIN
  -- Lookup user IDs based on provided usernames
  SELECT auth.uid() INTO _follower_id;
  SELECT username INTO _follower_username FROM public.profiles WHERE id = _follower_id;
  SELECT id INTO _following_id FROM public.profiles WHERE username = _following_username;

  -- Check if either username does not exist
  IF _following_id IS NULL THEN
    RAISE EXCEPTION 'User % does not exist', _following_username
    USING ERRCODE = 'F0002';
  END IF;

  -- Prevent users from following themselves
  IF _follower_id = _following_id THEN
    RAISE EXCEPTION 'A user cannot follow themselves'
    USING ERRCODE = 'F0003';
  END IF;

  -- Insert the follow relationship
  INSERT INTO public.followers (followed_at, follower_id, following_id, follower_username, following_username)
  VALUES (NOW(), _follower_id, _following_id, _follower_username, _following_username);

  -- If successful, return a success message
  RETURN json_build_object(
    'success', TRUE,
    'message', 'Follow relationship created successfully'
  );

  EXCEPTION
    WHEN unique_violation THEN
      -- Handle duplicate relationships gracefully
      RAISE EXCEPTION 'Follow already exists'
      USING ERRCODE = 'F0001';
END;$function$
;

CREATE OR REPLACE FUNCTION public.unfollow_user(_following_username text)
  RETURNS json
  LANGUAGE plpgsql
AS $function$
DECLARE
  _follower_id UUID;
  _following_id UUID;
BEGIN
  -- Lookup user IDs based on provided usernames
  SELECT auth.uid() INTO _follower_id;
  SELECT id INTO _following_id FROM public.profiles WHERE username = _following_username;

  -- Check if either username does not exist
  IF _following_id IS NULL THEN
    RAISE EXCEPTION 'User % does not exist', _following_username
    USING ERRCODE = 'F0002';
  END IF;

  -- Eliminar la relación de seguimiento
  DELETE FROM public.followers
  WHERE follower_id = _follower_id
  AND following_id = _following_id;

  -- Si se eliminó alguna fila, significa que la relación existía
  IF FOUND THEN
    RETURN json_build_object(
      'success', TRUE,
      'message', 'Follow relationship removed successfully'
    );
  ELSE
    RAISE EXCEPTION 'Follow relationship does not exist'
    USING ERRCODE = 'F0004';
  END IF;
END;
$function$;

create policy "Enable insert for users based on user_id"
on "public"."followers"
as permissive
for insert
to authenticated
with check ((( SELECT auth.uid() AS uid) = follower_id));



