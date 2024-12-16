  set check_function_bodies = off;

  drop function if exists "public"."find_movie_by_id"(movie_id integer);

  CREATE OR REPLACE FUNCTION public.find_movie_by_id(movie_id integer, lang text)
  RETURNS json
  LANGUAGE plpgsql
  AS $function$declare
    request_url text;
    api_key text := '32ad583d7cdc0ca52e96bd1db9cb4032';
    result json;
  BEGIN
    request_url := format('https://api.themoviedb.org/3/movie/%s?language=%s&api_key=%s', movie_id, lang, api_key);
    
    select content::json into result
    from http_get(request_url);

    return result;
    
  END;$function$
  ;

