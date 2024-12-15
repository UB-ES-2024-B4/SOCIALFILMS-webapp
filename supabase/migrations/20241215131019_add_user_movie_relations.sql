set check_function_bodies = off;

CREATE OR REPLACE FUNCTION get_user_movie_relations(_movie_id INTEGER, _user_id UUID DEFAULT NULL)
RETURNS json AS $$
DECLARE
    relations json;
    target_user_id UUID := COALESCE(_user_id, auth.uid());
BEGIN
    SELECT json_build_object(
        'favorite', EXISTS(
            SELECT 1 
            FROM public."User-Movies" 
            WHERE movie_id = _movie_id 
            AND user_id = target_user_id 
            AND relation_type = 'favorite'
        ),
        'watch_later', EXISTS(
            SELECT 1 
            FROM public."User-Movies" 
            WHERE movie_id = _movie_id 
            AND user_id = target_user_id 
            AND relation_type = 'watch_later'
        )
    ) INTO relations;

    RETURN relations;
END;
$$ LANGUAGE plpgsql;