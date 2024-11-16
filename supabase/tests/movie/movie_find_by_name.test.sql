BEGIN;

-- Planificamos 3 tests
SELECT plan(3);

-- Primer test: Verificamos que la función 'search_movie_by_name' no es NULL
SELECT ok(
  (SELECT public.search_movie_by_name('Gladiator') IS NOT NULL), 
  'search_movie_by_name function returns a result for a valid movie name'
);

-- Segundo test: Verificamos que hay más de 0 resultados con el nombre "Gladiator"
SELECT ok(
  (SELECT COUNT(*) > 0
   FROM json_array_elements(public.search_movie_by_name('Gladiator')->'results') AS result
   WHERE result->>'title' = 'Gladiator'),
  'search_movie_by_name result contains more than 0 results with the name Gladiator'
);

-- Tercer test: Verificamos que uno de los resultados tiene el id igual a 98
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
