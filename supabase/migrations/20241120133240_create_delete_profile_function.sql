set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.delete_profile(_user_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  DELETE FROM public."profiles"
  WHERE id = _user_id;

  DELETE FROM auth.users
  WHERE id = _user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;
END;
$function$
;

