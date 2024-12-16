CREATE OR REPLACE FUNCTION get_user_movies(_relation_type relation_type_enum, _user_id UUID DEFAULT NULL)
RETURNS json AS $$
DECLARE
    movies json;
    target_user_id UUID := COALESCE(_user_id, auth.uid());
BEGIN
    -- Validar que el tipo de relación no esté vacío
    IF _relation_type IS NULL THEN
        RAISE EXCEPTION 'relation_type no puede ser NULL'
        USING ERRCODE = 'M0001';
    END IF;


        -- Crear una lista de películas con detalles y los indicadores de relación
    SELECT json_agg(
        json_build_object(
            'movie', jsonb_set(
                find_movie_by_id(movie_id,'en')::jsonb,
                '{relations}',
                jsonb_build_object(
                    'is_favorite', relation_type = 'favorite',
                    'is_watch_later', relation_type = 'watch_later'
                )
            )
        )
    )
    INTO movies
    FROM public."User-Movies"
    WHERE user_id = _user_id AND relation_type = _relation_type;
    IF movies IS NULL THEN
        RAISE EXCEPTION 'No movies found'
        USING ERRCODE = 'M0002';
    END IF;

    RETURN movies;
END;
$$ LANGUAGE plpgsql;