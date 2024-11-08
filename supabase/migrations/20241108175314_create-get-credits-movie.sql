set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_credits_movie(movie_id integer)
 RETURNS json
 LANGUAGE plpgsql
AS $function$declare
  request_url text;
  api_key text := '32ad583d7cdc0ca52e96bd1db9cb4032';
  result json;
BEGIN
  request_url := format('https://api.themoviedb.org/3/movie/%s/credits?language=en-US&api_key=%s', movie_id, api_key);
  select content::json into result
  from http_get(request_url);

  return result;
  
END;$function$
;

CREATE OR REPLACE FUNCTION public.search_movie_by_name(movie_name text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$declare
  request_url text;
  api_key text := '32ad583d7cdc0ca52e96bd1db9cb4032';
  result json;
BEGIN
  request_url := format('https://api.themoviedb.org/3/search/movie?query=%s&include_adult=false&language=en-US&page=1&api_key=%s', movie_name, api_key);
  
  select content::json into result
  from http_get(request_url);

  return result;
  
END;$function$
;


