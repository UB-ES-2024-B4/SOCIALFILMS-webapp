set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.search_movie_by_name(
  movie_name text,
  lang text DEFAULT 'en'
)
 RETURNS json
 LANGUAGE plpgsql
AS $function$declare
  request_url text;
  api_key text := '32ad583d7cdc0ca52e96bd1db9cb4032';
  result json;
BEGIN
  request_url := format('https://api.themoviedb.org/3/search/movie?query=%s&include_adult=false&language=%s&page=1&api_key=%s', movie_name, lang, api_key);
  
  select content::json into result
  from http_get(request_url);

  return result;
  
END;$function$
;

drop function if exists "public"."search_movie_by_name"(movie_name text);