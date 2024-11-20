CREATE OR REPLACE FUNCTION public.get_profile(_user_id uuid)
 RETURNS json
 LANGUAGE sql
AS $function$
  SELECT json_agg(row_to_json(r))
  FROM (
    SELECT *
    FROM public."profiles"
    WHERE id = _user_id
  ) r;
$function$
;


