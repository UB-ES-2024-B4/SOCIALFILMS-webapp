CREATE OR REPLACE FUNCTION public.get_popular_movies(limit integer)
RETURNS json
LANGUAGE plpgsql
AS $function$
DECLARE
  request_url text;
  api_key text := '32ad583d7cdc0ca52e96bd1db9cb4032';
  result json := '[]'; -- Inicializa como un array vacío
  page integer := 1;
  total_movies integer := 0;
BEGIN
  -- Mientras no se haya alcanzado el límite deseado
  WHILE total_movies < limit LOOP
    -- Construir la URL de la solicitud para la página actual
    request_url := format('https://api.themoviedb.org/3/movie/popular?api_key=%s&language=en-US&page=%s', api_key, page);

    -- Realizar la solicitud HTTP
    SELECT content::json INTO result
    FROM http_get(request_url);

    -- Manejo básico de errores
    IF result IS NULL THEN
      RAISE EXCEPTION 'Error al obtener datos de la API de TMDb';
    END IF;

    -- Aumentar el contador de películas obtenidas
    total_movies := jsonb_array_length(result->'results');

    -- Agregar los resultados a la lista final
    IF total_movies > 0 THEN
      result := jsonb_concat(result::jsonb, (SELECT content::jsonb FROM http_get(request_url)::jsonb->'results'));
    END IF;

    -- Incrementar el número de página
    page := page + 1;

    -- Si hemos alcanzado el límite, salimos del bucle
    IF page > 5 THEN  -- Ya que cada página tiene 20 resultados, y queremos 100
      EXIT;
    END IF;
  END LOOP;

  -- Retornar el resultado
  RETURN result;

END;
$function$;