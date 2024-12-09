--Funcion para obtener las peliculas en relacion a un usario
CREATE OR REPLACE FUNCTION get_user_movies(_relation_type relation_type_enum, _user_id UUID DEFAULT NULL)
RETURNS json AS $$
DECLARE
    movies json;
    target_user_id UUID := COALESCE(_user_id, auth.uid());
BEGIN
    -- Validar que el tipo de relación no esté vacío
    IF _relation_type IS NULL OR _relation_type = '' THEN
        RAISE EXCEPTION 'relation_type no puede ser NULL o vacío';
    END IF;

    -- Crear una lista de películas con detalles y los indicadores de relación
    SELECT json_agg(
        json_build_object(
            'movie', jsonb_set(
                find_movie_by_id(movie_id)::jsonb,
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

    RETURN movies;
END;
$$ LANGUAGE plpgsql;

--Funcion para obtener los usuarios segun la relacion en base a una pelicula
CREATE OR REPLACE FUNCTION get_movie_users(_movie_id INT, _relation_type relation_type_enum)
RETURNS json AS $$
DECLARE
    users_json json;
BEGIN
    -- Validar que el tipo de relación no esté vacío
    IF _relation_type IS NULL OR _relation_type = '' THEN
        RAISE EXCEPTION 'relation_type no puede ser NULL o vacío';
    END IF;

    SELECT json_agg(json_build_object('user_id', user_id))
    INTO users_json
    FROM public."User-Movies"
    WHERE movie_id = _movie_id AND relation_type = _relation_type;

    -- Si no hay resultados, devolver un JSON vacío
    IF users_json IS NULL THEN
        RETURN '[]'::json;
    END IF;
    RETURN users_json;
END;
$$ LANGUAGE plpgsql;

-- Funcion para añadir un registro
CREATE OR REPLACE FUNCTION add_user_movie(_movie_id INT, _relation_type relation_type_enum, _user_id UUID DEFAULT NULL)
RETURNS VOID AS $$
DECLARE
    target_user_id UUID := COALESCE(_user_id, auth.uid());
BEGIN
    INSERT INTO public."User-Movies" (user_id, movie_id, relation_type)
    VALUES (target_user_id, _movie_id, _relation_type);
END;
$$ LANGUAGE plpgsql;

    
-- Funcion para eliminar un registro
CREATE OR REPLACE FUNCTION delete_user_movie(_movie_id INT, _relation_type relation_type_enum, _user_id UUID DEFAULT NULL)
RETURNS VOID AS $$
DECLARE
    target_user_id UUID := COALESCE(_user_id, auth.uid());
BEGIN
    DELETE FROM public."User-Movies"
    WHERE user_id = target_user_id AND movie_id = _movie_id AND relation_type = _relation_type;
END;
$$ LANGUAGE plpgsql;