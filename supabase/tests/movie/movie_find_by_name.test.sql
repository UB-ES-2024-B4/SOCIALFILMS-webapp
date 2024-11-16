BEGIN;


SELECT plan(3);


SELECT ok(
  (SELECT public.search_movie_by_name('Gladiator') IS NOT NULL), 
  'search_movie_by_name function returns a result for a valid movie name'
);


SELECT ok(
  (SELECT COUNT(*) > 0
   FROM json_array_elements(public.search_movie_by_name('Gladiator')->'results') AS result
   WHERE result->>'title' = 'Gladiator'),
  'search_movie_by_name result contains more than 0 results with the name Gladiator'
);


SELECT ok(
  (SELECT EXISTS (
      SELECT 1
      FROM json_array_elements(public.search_movie_by_name('Gladiator')->'results') AS result
      WHERE (result->>'id')::int = 98
  )),
  'search_movie_by_name result contains a movie with id 98'
);

SELECT * FROM finish();
ROLLBACK;
