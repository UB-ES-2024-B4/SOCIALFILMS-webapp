--Funcion para obtener las peliculas que les ha gustado a un usuario
CREATE OR REPLACE FUNCTION get_user_movies()
RETURNS TABLE(movie_id INT) AS $$
BEGIN
    RETURN QUERY
    SELECT movie_id
    FROM public."User-Movies"
    WHERE user_id = auth.uid();
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