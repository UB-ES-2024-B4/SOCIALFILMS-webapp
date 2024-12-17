CREATE OR REPLACE FUNCTION get_user_movies(_relation_type relation_type_enum, _user_id UUID DEFAULT NULL)
RETURNS json AS $$
DECLARE
    movies json;
    target_user_id UUID := COALESCE(_user_id, auth.uid());
BEGIN
    IF _relation_type IS NULL THEN
        RAISE EXCEPTION 'relation_type no puede ser NULL'
        USING ERRCODE = 'M0001';
    END IF;


    SELECT json_agg(
        jsonb_set(
            find_movie_by_id(movie_id, 'ca-ES')::jsonb,
            '{relations}',
            jsonb_build_object(
                'is_favorite', relation_type = 'favorite',
                'is_watch_later', relation_type = 'watch_later'
            )
        )
    )
    INTO movies
    FROM public."User-Movies"
    WHERE user_id = target_user_id AND relation_type = _relation_type;

    IF movies IS NULL THEN
        RAISE EXCEPTION 'No movies found'
        USING ERRCODE = 'M0002';
    END IF;

    RETURN movies;
END;
$$ LANGUAGE plpgsql;