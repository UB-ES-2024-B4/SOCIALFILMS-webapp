BEGIN;

-- Planificar 6 pruebas
SELECT plan(5);

-- Configurar el usuario simulado para auth.uid()
SELECT set_config('request.jwt.claims', '{"sub": "5899f99d-a449-4bfa-8769-19c097aaf1f5"}', true);

INSERT INTO public.followers (follower_id, following_id, follower_username, following_username)
VALUES 
  ('5899f99d-a449-4bfa-8769-19c097aaf1f5', '5899f99d-a449-4bfa-8769-19c097aaf1f4', 'Seed user', 'user1'),
  ('5899f99d-a449-4bfa-8769-19c097aaf1f4', '5899f99d-a449-4bfa-8769-19c097aaf1f5', 'user1', 'Seed user');


-- Crear una notificación de prueba
SELECT ok(
  (SELECT public.send_notification('user1', 1) IS NOT NULL),
  'Notification sent successfully for sender'
);

-- Verificar que la notificación se ha insertado correctamente
SELECT ok(
  (SELECT COUNT(*) FROM public.notifications WHERE sender_username = 'Seed user' AND receiver_username = 'user1' AND movie_id = 1) = 1,
  'Notification inserted into notifications table'
);

-- Obtener el ID de la notificación recién creada y asignarlo a una variable de sesión
SELECT id AS notification_id FROM public.notifications WHERE sender_username = 'Seed user' AND receiver_username = 'user1' AND movie_id = 1 \gset

SELECT set_config('request.jwt.claims', '{"sub": "5899f99d-a449-4bfa-8769-19c097aaf1f4"}', true);

-- Obtener notificaciones 
SELECT public.get_notifications();
SELECT ok(
  (SELECT json_typeof(public.get_notifications()) = 'object'),
  'Notifications returned as a JSON object'
);

-- Eliminar una notificación 
SELECT public.delete_notification('Seed user', 1);
SELECT ok(
  (SELECT COUNT(*) FROM public.notifications WHERE id = :'notification_id') = 0,
  'Notification deleted successfully'
);

-- Verificar que la notificación no existe después de la eliminación
SELECT ok(
  (SELECT COUNT(*) FROM public.notifications WHERE sender_username = 'Seed user' AND receiver_username = 'user1' AND movie_id = 1) = 0,
  'Notification no longer exists after deletion'
);

SELECT set_config('request.jwt.claims', '', true);

ROLLBACK;
