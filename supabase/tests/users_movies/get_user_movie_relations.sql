BEGIN;


SET "request.jwt.claims" = '{"sub": "00000000-0000-0000-0000-000000000002"}';
-- Declaramos el plan de pruebas
SELECT plan(5);
SET session_replication_role = 'replica';
-- Inserta datos de prueba
INSERT INTO public."User-Movies" (movie_id, user_id, relation_type)
VALUES
  (1, '00000000-0000-0000-0000-000000000001', 'favorite'),
  (1, '00000000-0000-0000-0000-000000000001', 'watch_later'),
  (2, '00000000-0000-0000-0000-000000000001', 'watch_later');

-- Test 1: La función retorna un JSON válido para un usuario y película existentes
SELECT ok(
  (SELECT get_user_movie_relations(1, '00000000-0000-0000-0000-000000000001') IS NOT NULL),
  'get_user_movie_relations retorna un JSON válido'
);

-- Test 2: La función marca como 'favorite' si existe una relación de tipo 'favorite'
SELECT is(
  (SELECT (get_user_movie_relations(1, '00000000-0000-0000-0000-000000000001')->>'favorite')::boolean),
  true,
  'El usuario marcó la película como favorita'
);

-- Test 3: La función marca como 'watch_later' si existe una relación de tipo 'watch_later'
SELECT is(
  (SELECT (get_user_movie_relations(1, '00000000-0000-0000-0000-000000000001')->>'watch_later')::boolean),
  true,
  'El usuario marcó la película para ver más tarde'
);

-- Test 4: La función maneja valores NULL en _user_id y utiliza auth.uid()
SELECT is(
  (SELECT (get_user_movie_relations(1, NULL)->>'favorite')::boolean),
  false,
  'La función usa auth.uid() correctamente cuando _user_id es NULL'
);

-- Test 5: La función retorna false para relaciones inexistentes
SELECT is(
  (SELECT (get_user_movie_relations(999, '00000000-0000-0000-0000-000000000001')->>'favorite')::boolean),
  false,
  'No hay relación favorita para una película inexistente'
);

-- Finalizamos los tests
SELECT * FROM finish();
SET session_replication_role = 'origin';
-- Rollback elimina los datos temporales
ROLLBACK;

