create table "public"."is_following" (
    "exists" boolean
);


set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.is_user_following_you(_follower_username text)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$DECLARE
  _your_username TEXT;
BEGIN
  -- Fetch the current user's username using auth.uid()
  SELECT username
  INTO _your_username
  FROM public.profiles
  WHERE id = auth.uid();

  -- Check if the follower_username is following _your_username
  IF EXISTS (
    SELECT 1
    FROM public.followers
    WHERE following_username = _your_username 
      AND follower_username = _follower_username
  ) THEN
    RETURN true;
  ELSE RETURN false;
  END if;
END;$function$
;

CREATE OR REPLACE FUNCTION public.get_profile_by_id(_user_id uuid)
 RETURNS json
 LANGUAGE plpgsql
AS $function$DECLARE
  result JSON;
BEGIN
  SELECT row_to_json(p)
  INTO result
  FROM (
    SELECT 
      id,
      username,
      email,
      birth_date, 
      country, 
      bio, 
      real_name, 
      last_name,
      CASE WHEN EXISTS (
        SELECT 1
        FROM public.followers
        WHERE following_id = auth.uid() 
          AND follower_id = _user_id
      ) THEN true
      ELSE false
      END AS is_following
    FROM public.profiles
    WHERE id = _user_id
  ) p;

  RETURN result;
END;$function$
;

CREATE OR REPLACE FUNCTION public.get_profile_by_username(_username text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$DECLARE
  result JSON;
  _your_username TEXT;
BEGIN
  SELECT username
  INTO _your_username
  FROM public.profiles
  WHERE id = auth.uid();

  SELECT row_to_json(p)
  INTO result
  FROM (
    SELECT 
      id,
      username,
      email,
      birth_date, 
      country, 
      bio, 
      real_name, 
      last_name,
      (SELECT COUNT(*) FROM public.followers WHERE following_username = _username) AS followers,
      (SELECT COUNT(*) FROM public.followers WHERE follower_username = _username) AS following,
      CASE WHEN EXISTS (
        SELECT 1
        FROM public.followers
        WHERE following_username = _username 
          AND follower_username = _your_username
      ) THEN true
      ELSE false
      END AS is_following
    FROM public.profiles
    WHERE username = _username
  ) p;

  RETURN result;
END;$function$
;

grant delete on table "public"."is_following" to "anon";

grant insert on table "public"."is_following" to "anon";

grant references on table "public"."is_following" to "anon";

grant select on table "public"."is_following" to "anon";

grant trigger on table "public"."is_following" to "anon";

grant truncate on table "public"."is_following" to "anon";

grant update on table "public"."is_following" to "anon";

grant delete on table "public"."is_following" to "authenticated";

grant insert on table "public"."is_following" to "authenticated";

grant references on table "public"."is_following" to "authenticated";

grant select on table "public"."is_following" to "authenticated";

grant trigger on table "public"."is_following" to "authenticated";

grant truncate on table "public"."is_following" to "authenticated";

grant update on table "public"."is_following" to "authenticated";

grant delete on table "public"."is_following" to "service_role";

grant insert on table "public"."is_following" to "service_role";

grant references on table "public"."is_following" to "service_role";

grant select on table "public"."is_following" to "service_role";

grant trigger on table "public"."is_following" to "service_role";

grant truncate on table "public"."is_following" to "service_role";

grant update on table "public"."is_following" to "service_role";

create policy "Enable read access for all users"
on "public"."followers"
as permissive
for select
to public
using (true);



