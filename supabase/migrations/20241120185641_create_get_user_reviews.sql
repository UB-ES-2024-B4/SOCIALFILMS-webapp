
--Retorna tosas las reviews que ha hecho un usuario 
CREATE OR REPLACE FUNCTION public.get_user_reviews(_user_id uuid)
 RETURNS TABLE(review_id uuid)
 LANGUAGE plpgsql
AS $function$
BEGIN

    IF EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE id = _user_id
    ) THEN

        RETURN QUERY
        SELECT id
        FROM public."Reviews"
        WHERE user_id = _user_id;
    ELSE

        RETURN;
    END IF;
END;
$function$
;


