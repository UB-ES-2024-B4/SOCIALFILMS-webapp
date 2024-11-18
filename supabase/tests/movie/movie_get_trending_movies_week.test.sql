BEGIN;


SELECT plan(2);


SELECT ok(
  (SELECT public.get_trending_movies_of_week() IS NOT NULL), 
  'get_trending_movies_of_week function returns a result for the trending movies of the week'
);


SELECT ok(
  (SELECT COUNT(*) > 0
   FROM json_array_elements(public.get_trending_movies_of_week()->'results') AS result),
  'get_trending_movies_of_week result contains more than 0 movies'
);


SELECT * FROM finish();
ROLLBACK;
