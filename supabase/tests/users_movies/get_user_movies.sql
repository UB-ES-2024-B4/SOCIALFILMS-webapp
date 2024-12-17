BEGIN;
SET "request.jwt.claims" = '{"sub": "00000000-0000-0000-0000-000000000002"}';
SET session_replication_role = 'replica';
-- Plan total para todos los tests
SELECT plan(5);
INSERT INTO public."User-Movies" (movie_id, user_id, relation_type)
VALUES (1, '00000000-0000-0000-0000-000000000001', 'favorite'),
       (2, '00000000-0000-0000-0000-000000000001', 'watch_later');

SELECT ok(
    (SELECT jsonb_array_length(get_user_movies('favorite', '00000000-0000-0000-0000-000000000001')::jsonb)) > 0,
    'Debería devolver películas para un tipo de relación "favorite" y un usuario existente'
);

SELECT throws_ok(
    $$SELECT get_user_movies('favorite', '00000000-0000-0000-0000-000000000003')$$,
    'M0002',
    'No movies found',
    'Debería lanzar una excepción cuando no se encuentran películas para la relación "favorite"'
);

SELECT throws_ok(
    $$SELECT get_user_movies(NULL, '00000000-0000-0000-0000-000000000003')$$,
    'M0001',
    'relation_type no puede ser NULL',
    'Debería lanzar una excepción cuando no se encuentran películas para la relación "favorite"'
);

SELECT ok(
    (SELECT jsonb_array_length(get_user_movies('watch_later', '00000000-0000-0000-0000-000000000001')::jsonb)) > 0,
    'Debería devolver películas para el tipo de relación "watch_later" y un usuario válido'
);

SELECT throws_ok(
    $$SELECT get_user_movies('favorite', NULL)$$,
    'M0002',
    'No movies found',
    'Debería lanzar una excepción cuando no se encuentran películas para la relación "favorite"'
);
SELECT * FROM finish();
SET session_replication_role = 'origin';
ROLLBACK;
