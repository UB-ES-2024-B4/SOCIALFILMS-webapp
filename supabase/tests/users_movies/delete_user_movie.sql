BEGIN;
SET "request.jwt.claims" = '{"sub": "00000000-0000-0000-0000-000000000002"}';
SET session_replication_role = 'replica';

-- Plan total para todos los tests
SELECT plan(3);

-- Insertar un usuario y una película de prueba para el test
INSERT INTO public."User-Movies" (movie_id, user_id, relation_type)
VALUES (1, '00000000-0000-0000-0000-000000000001', 'favorite'),
       (2, '00000000-0000-0000-0000-000000000002', 'watch_later');

-- Test 1: Verificar que se elimina un registro existente para un `user_id`, `movie_id`, y `relation_type`
DO $$
BEGIN
    PERFORM delete_user_movie(1, 'favorite', '00000000-0000-0000-0000-000000000001');
END $$;
SELECT ok(
    (SELECT COUNT(*) FROM public."User-Movies" WHERE movie_id = 1 AND relation_type = 'favorite' AND user_id = '00000000-0000-0000-0000-000000000001') = 0,
    'Debería eliminar el registro para la película 1 y relación "favorite" para el usuario 00000000-0000-0000-0000-000000000001'
);

-- Test 2: Verificar que lanza una excepción cuando intentamos eliminar un registro que no existe
SELECT throws_ok(
    $$SELECT delete_user_movie(1, 'favorite', '00000000-0000-0000-0000-000000000002')$$,
    'El registro no existe para user_id 00000000-0000-0000-0000-000000000002, movie_id 1, relation_type favorite',
    'Debería lanzar una excepción cuando no existe el registro a eliminar'
);

-- Test 3: Verificar que se elimina un registro correctamente para el `user_id` autenticado
DO $$
BEGIN
    PERFORM delete_user_movie(2, 'watch_later', NULL);
END $$;
SELECT ok(
    (SELECT COUNT(*) FROM public."User-Movies" WHERE movie_id = 2 AND relation_type = 'watch_later' AND user_id = '00000000-0000-0000-0000-000000000002') = 0,
    'Debería eliminar el registro para la película 2 y relación "watch_later" para el usuario 00000000-0000-0000-0000-000000000002'
);

-- Finalizar la ejecución de los tests
SELECT * FROM finish();

SET session_replication_role = 'origin';
ROLLBACK;
