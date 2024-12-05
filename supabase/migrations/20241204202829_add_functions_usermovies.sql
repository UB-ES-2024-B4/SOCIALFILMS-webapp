--Funcion para obtener las peliculas que les ha gustado a un usuario
CREATE OR REPLACE FUNCTION get_user_movies(_relation_type TEXT, _user_id UUID DEFAULT NULL)
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

--Funcion para obtener los usuarios que les gusta una pelicula
CREATE OR REPLACE FUNCTION get_movie_users(_movie_id INT)
RETURNS TABLE(user_id UUID) AS $$
BEGIN
    RETURN QUERY
    SELECT user_id
    FROM public."User-Movies"
    WHERE movie_id = _movie_id;
END;
$$ LANGUAGE plpgsql;

-- Funcion para añadir un registro (pelicula que le gusta al usuario)
CREATE OR REPLACE FUNCTION add_user_movie(_movie_id INT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public."User-Movies" (user_id, movie_id)
    VALUES (user_id_input, _movie_id);
END;
$$ LANGUAGE plpgsql;

    
-- Funcion para eliminar un registro (pelicula que le gusta al usuario)
CREATE OR REPLACE FUNCTION delete_user_movie(_movie_id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM public."User-Movies"
    WHERE user_id = auth.uid() AND movie_id = _movie_id;
END;
$$ LANGUAGE plpgsql;