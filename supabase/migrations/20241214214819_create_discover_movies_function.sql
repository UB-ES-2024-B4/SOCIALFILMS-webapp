set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.discover_movies(with_genres text, with_origin_country text, sort_by text, with_original_language text, year integer, lang text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$declare
  request_url text;
  api_key text := '32ad583d7cdc0ca52e96bd1db9cb4032';
  result json;
BEGIN
  request_url := format('https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=%s&page=1&sort_by=%s&with_genres=%s&with_origin_country=%s&with_original_language=%s&year=%s&api_key=%s',lang,sort_by,with_genres,with_origin_country,with_original_language,year,api_key);

  select content::json into result
  from http_get(request_url);

  return result;
  
END;$function$
;


