set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_follow(_follower_username text, _following_username text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$DECLARE
  _follower_id UUID;
  _following_id UUID;
BEGIN
  -- Lookup user IDs based on provided usernames
  SELECT id INTO _follower_id FROM public.profiles WHERE username = _follower_username;
  SELECT id INTO _following_id FROM public.profiles WHERE username = _following_username;

  -- Check if either username does not exist
  IF _follower_id IS NULL OR _following_id IS NULL THEN
    RAISE EXCEPTION 'One or both usernames do not exist';
  END IF;

  -- Prevent users from following themselves
  IF _follower_id = _following_id THEN
    RAISE EXCEPTION 'A user cannot follow themselves';
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
      RETURN json_build_object(
        'success', FALSE,
        'message', 'Follow relationship already exists'
      );
END;$function$
;

create policy "Enable insert for users based on user_id"
on "public"."followers"
as permissive
for insert
to authenticated
with check ((( SELECT auth.uid() AS uid) = follower_id));



