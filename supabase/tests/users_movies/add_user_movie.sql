BEGIN;
SET "request.jwt.claims" = '{"sub": "00000000-0000-0000-0000-000000000002"}';
SET session_replication_role = 'replica';
-- Plan total para todos los tests
SELECT plan(3);

-- Insertar un usuario y una película de prueba para el test
INSERT INTO public."User-Movies" (movie_id, user_id, relation_type)
VALUES (1, '00000000-0000-0000-0000-000000000001', 'favorite');

-- Test 1: Verificar que se inserta un nuevo registro cuando no existe para el `user_id`, `movie_id`, y `relation_type`
DO $$
BEGIN
    PERFORM add_user_movie(2, 'watch_later', '00000000-0000-0000-0000-000000000003');
END $$;
SELECT ok(
    (SELECT COUNT(*) FROM public."User-Movies" WHERE movie_id = 2 AND relation_type = 'watch_later' AND user_id = '00000000-0000-0000-0000-000000000003') = 1,
    'Debería haber un registro agregado para la película 2 y relación "watch_later" para el usuario 00000000-0000-0000-0000-000000000003'
);

-- Test 2: Verificar que se inserta un nuevo registro cuando no existe para el `user_id` (auth), `movie_id`, y `relation_type`
DO $$
BEGIN
    PERFORM add_user_movie(3, 'watch_later', NULL);
END $$;
SELECT ok(
    (SELECT COUNT(*) FROM public."User-Movies" WHERE movie_id = 3 AND relation_type = 'watch_later' AND user_id = '00000000-0000-0000-0000-000000000002') = 1,
    'Debería haber un registro agregado para la película 3 y relación "watch_later" para el usuario 00000000-0000-0000-0000-000000000002'
);


SELECT throws_ok(
    $$SELECT add_user_movie(1, 'favorite', '00000000-0000-0000-0000-000000000001')$$,
    'El registro ya existe para user_id 00000000-0000-0000-0000-000000000001, movie_id 1, relation_type favorite',
    'Debería lanzar una excepción cuando el registro ya existe para el mismo usuario, película y tipo de relación'
);





SELECT * FROM finish();
SET session_replication_role = 'origin';
ROLLBACK;
