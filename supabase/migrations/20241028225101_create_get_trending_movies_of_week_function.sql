set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_trending_movies_of_week()
 RETURNS json
 LANGUAGE plpgsql
AS $function$declare
  request_url text;
  api_key text := '32ad583d7cdc0ca52e96bd1db9cb4032';
  result json;
BEGIN
  request_url := format('https://api.themoviedb.org/3/trending/movie/week?api_key=%s', api_key);
  
  select content::json into result
  from http_get(request_url);

  return result;
  
END;$function$
;


