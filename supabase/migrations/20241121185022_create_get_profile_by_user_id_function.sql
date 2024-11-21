set check_function_bodies = off;

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
      usr_birth,
      usr_description,
      usr_gender
    FROM public.profiles
    WHERE id = _user_id
  ) p;

  RETURN result;
END;$function$
;

create policy "Enable read access for all users"
on "public"."profiles"
as permissive
for select
to public
using (true);



