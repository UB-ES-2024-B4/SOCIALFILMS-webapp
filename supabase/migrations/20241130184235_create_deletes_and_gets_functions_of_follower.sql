set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.delete_follower(_username text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$DECLARE
  rows_deleted int8;
BEGIN
  DELETE FROM public.followers
  WHERE following_username = _username
  RETURNING 1 INTO rows_deleted;

  IF rows_deleted IS NULL THEN
    RETURN json_build_object(
      'success', FALSE,
      'message', 'No followers found to be deleted'
    );
  END IF;

  RETURN json_build_object(
    'success', TRUE,
    'message', 'All followers deleted successfully'
  );
END;$function$
;

CREATE OR REPLACE FUNCTION public.delete_following(_username text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$DECLARE
  rows_deleted int8;
BEGIN
  DELETE FROM public.followers
  WHERE follower_username = _username
  RETURNING 1 INTO rows_deleted;

  IF rows_deleted IS NULL THEN
    RETURN json_build_object(
      'success', FALSE,
      'message', 'No followings found to be deleted'
    );
  END IF;

  RETURN json_build_object(
    'success', TRUE,
    'message', 'All followings deleted successfully'
  );
END;$function$
;

CREATE OR REPLACE FUNCTION public.get_followers(_username text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(f))
  INTO result
  FROM (
    SELECT 
      f.follower_id,
      f.follower_username,
      f.followed_at
    FROM public.followers f
    WHERE f.following_username = _username
  ) f;

  IF result IS NULL THEN
    RETURN json_build_object(
      'success', TRUE,
      'message', 'No followers found',
      'data', '[]'::JSON
    );
  END IF;

  RETURN json_build_object(
    'success', TRUE,
    'message', 'Followers retrieved successfully',
    'data', result
  );
END$function$
;

CREATE OR REPLACE FUNCTION public.get_following(_username text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(f))
  INTO result
  FROM (
    SELECT 
      f.following_id,
      f.following_username,
      f.followed_at
    FROM public.followers f
    WHERE f.follower_username = _username
  ) f;

  IF result IS NULL THEN
    RETURN json_build_object(
      'success', TRUE,
      'message', 'No following found',
      'data', '[]'::JSON
    );
  END IF;

  RETURN json_build_object(
    'success', TRUE,
    'message', 'Following retrieved successfully',
    'data', result
  );
END$function$
;

create policy "Enable delete for users based on user_id"
on "public"."followers"
as permissive
for delete
to public
using ((( SELECT auth.uid() AS uid) = follower_id));



