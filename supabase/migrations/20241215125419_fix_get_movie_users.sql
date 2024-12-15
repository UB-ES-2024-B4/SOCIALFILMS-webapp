set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_movie_users(
    _movie_id integer,
    _relation_type relation_type_enum
)
RETURNS json
LANGUAGE plpgsql
AS $function$
DECLARE
    users_json json;
BEGIN
    IF _relation_type IS NULL THEN
        RAISE EXCEPTION 'relation_type no puede ser NULL'
        USING ERRCODE = 'M0001';
    END IF;

    SELECT json_agg(json_build_object('user_id', user_id))
    INTO users_json
    FROM public."User-Movies"
    WHERE movie_id = _movie_id AND relation_type = _relation_type;

    IF users_json IS NULL THEN
        RAISE EXCEPTION 'No users found'
        USING ERRCODE = 'M0002';
    END IF;
    
    RETURN users_json;
END;
$function$;


drop function if exists "public"."get_user_movies"(movie_id INT);
drop function if exists "public"."get_movie_users"(movie_id INT);
drop function if exists "public"."add_user_movie"(movie_id INT);
drop function if exists "public"."delete_user_movie"(movie_id INT);