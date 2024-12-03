CREATE OR REPLACE FUNCTION public.update_profile(_user_id uuid, _username text, _email text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Check if the profile exists in the profiles table
  IF EXISTS (
    SELECT 1
    FROM public."profiles"
    WHERE id = _user_id
  ) THEN
    -- Update the profile's username and email in the profiles table
    UPDATE public."profiles"
    SET
      username = _username,
      email = _email
    WHERE id = _user_id;

    -- Update the email in the auth.users table
    UPDATE auth.users
    SET email = _email
    WHERE id = _user_id;

    RETURN 'Profile updated successfully.';
  ELSE
    RETURN 'Profile does not exist';
  END IF;
END;
$function$
;


