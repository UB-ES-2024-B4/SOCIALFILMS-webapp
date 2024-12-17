BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

-- Planificar 7 pruebas
SELECT plan(4);

-- Configurar el usuario simulado para auth.uid()
SELECT set_config('request.jwt.claims', '{"sub": "5899f99d-a449-4bfa-8769-19c097aaf1f5"}', true);

-- Crear usuarios de prueba (en este caso, aseguramos que existan en la tabla profiles)
-- Aquí asumimos que las tablas `profiles` y las funciones necesarias ya están configuradas.

-- Probar la función follow_user
SELECT ok(
  (SELECT public.follow_user('user1') IS NOT NULL),
  'Follow relationship created successfully'
);

-- Verificar que la relación de seguimiento ha sido insertada
SELECT ok(
  (SELECT COUNT(*) FROM public.followers WHERE follower_username = 'Seed user' AND following_username = 'user1') = 1, 
  'Follow relationship inserted into followers table'
);

-- Probar la función unfollow_user
SELECT ok(
  (SELECT public.unfollow_user('user1') IS NOT NULL),
  'Follow relationship removed successfully'
);

-- Verificar que la relación de seguimiento ha sido eliminada
SELECT ok(
  (SELECT COUNT(*) FROM public.followers WHERE follower_username = 'Seed user' AND following_username = 'user1') = 0,
  'Follow relationship removed from followers table'
);

-- Restaurar configuración de auth.uid()
SELECT set_config('request.jwt.claims', '', true);

ROLLBACK;
