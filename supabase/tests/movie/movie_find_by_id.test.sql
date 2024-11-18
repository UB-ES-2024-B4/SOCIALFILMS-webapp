BEGIN;


SELECT plan(3);


SELECT ok(
  (SELECT public.find_movie_by_id(98) IS NOT NULL), 
  'find_movie_by_id function returns a result for a valid movie ID'
);


SELECT ok(
  (SELECT (result->>'title') IS NOT NULL 
   FROM (SELECT public.find_movie_by_id(98) AS result) AS subquery),
  'find_movie_by_id result contains the title field'
);


SELECT ok(
  (SELECT (result->>'title')
   FROM (SELECT public.find_movie_by_id(98) AS result) AS subquery) = 'Gladiator',
  'find_movie_by_id result contains the title "Gladiator"'
);



SELECT * FROM finish();

ROLLBACK;
