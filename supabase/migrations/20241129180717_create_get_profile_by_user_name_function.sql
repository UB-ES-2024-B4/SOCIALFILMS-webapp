set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_profile_by_username(_username text)
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
    WHERE username = _username
  ) p;

  RETURN result;
END;$function$
;