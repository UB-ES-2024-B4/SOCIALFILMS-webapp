set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_review(_movie_id integer, _rating integer, _comment character varying, _user_id UUID DEFAULT NULL)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
  new_review_id UUID;
BEGIN
  INSERT INTO public."Reviews" (user_id, movie_id, rating, comment, created_at, editable, likes, dislikes, shared_count)
  VALUES (COALESCE(_user_id, auth.uid()), _movie_id, _rating, _comment, NOW(), true, 0, 0, 0)
  RETURNING id INTO new_review_id;

  RETURN new_review_id;
END;
$function$
;

create policy "Enable read access for all users"
on "public"."Reviews"
as permissive
for select
to public
using (true);



