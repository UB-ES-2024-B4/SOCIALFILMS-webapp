set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_now_playing_movies(lang text, region text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$declare
  request_url text;
  api_key text := '32ad583d7cdc0ca52e96bd1db9cb4032';
  result json;
BEGIN
  request_url := format('https://api.themoviedb.org/3/movie/now_playing?language=%s&page=1&region=%s&api_key=%s', lang, region, api_key);
  
  select content::json into result
  from http_get(request_url);

  return result;
  
END;$function$
;

CREATE OR REPLACE FUNCTION public.get_top_rated_movies(lang text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$declare
  request_url text;
  api_key text := '32ad583d7cdc0ca52e96bd1db9cb4032';
  result json;
BEGIN
  request_url := format('https://api.themoviedb.org/3/movie/top_rated?language=%s&page=1&api_key=%s', lang, api_key);
  
  select content::json into result
  from http_get(request_url);

  return result;
  
END;$function$
;

CREATE OR REPLACE FUNCTION public.get_popular_movies(lang text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$declare
  request_url text;
  api_key text := '32ad583d7cdc0ca52e96bd1db9cb4032';
  result json;
BEGIN
  request_url := format('https://api.themoviedb.org/3/movie/popular?language=%s&page=1&api_key=%s', lang, api_key);
  
  select content::json into result
  from http_get(request_url);

  return result;
  
END;$function$
;


