BEGIN;
SET "request.jwt.claims" = '{"sub": "00000000-0000-0000-0000-000000000002"}';
SET session_replication_role = 'replica';
-- Plan total para todos los tests
SELECT plan(5);

-- Insertar datos de prueba en la tabla "User-Movies"
INSERT INTO public."User-Movies" (movie_id, user_id, relation_type)
VALUES (1, '00000000-0000-0000-0000-000000000001', 'favorite'),
       (2, '00000000-0000-0000-0000-000000000001', 'watch_later'),
       (1, '00000000-0000-0000-0000-000000000002', 'favorite'),
       (3, '00000000-0000-0000-0000-000000000003', 'watch_later');

-- Test 1: Verificar que devuelve usuarios para una película y un tipo de relación válidos
SELECT ok(
    (SELECT jsonb_array_length(get_movie_users(1, 'favorite')::jsonb)) > 0,
    'Debería devolver usuarios para la película con id 1 y relación "favorite"'
);

-- Test 2: Verificar que lanza una excepción cuando no se encuentran usuarios para una película y relación válida
SELECT throws_ok(
    $$SELECT get_movie_users(999, 'favorite')$$,
    'M0002',
    'No users found',
    'Debería lanzar una excepción cuando no se encuentran usuarios para la película y relación "favorite"'
);

-- Test 3: Verificar que lanza una excepción cuando el tipo de relación es NULL
SELECT throws_ok(
    $$SELECT get_movie_users(1, NULL)$$,
    'M0001',
    'relation_type no puede ser NULL',
    'Debería lanzar una excepción cuando el tipo de relación es NULL'
);

-- Test 4: Verificar que devuelve usuarios para una película con otro tipo de relación
SELECT ok(
    (SELECT jsonb_array_length(get_movie_users(2, 'watch_later')::jsonb)) > 0,
    'Debería devolver usuarios para la película con id 2 y relación "watch_later"'
);

-- Test 5: Verificar que lanza una excepción cuando no se encuentran usuarios para una película y relación válidas
SELECT throws_ok(
    $$SELECT get_movie_users(1, 'watch_later')$$,
    'M0002',
    'No users found',
    'Debería lanzar una excepción cuando no se encuentran usuarios para la película con id 1 y relación "watch_later"'
);

SELECT * FROM finish();
SET session_replication_role = 'origin';
ROLLBACK;
