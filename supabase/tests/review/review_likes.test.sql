BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

-- Planificar 7 pruebas
SELECT plan(7);

-- Configurar el usuario simulado para auth.uid()
SELECT set_config('request.jwt.claims', '{"sub": "5899f99d-a449-4bfa-8769-19c097aaf1f5"}', true);

-- Crear una reseña de prueba
SELECT ok(
  (SELECT public.create_review(1, 5, 'Test review for add_like_dislike', false, '5899f99d-a449-4bfa-8769-19c097aaf1f5') IS NOT NULL), 
  'Create mock review for add_like_dislike'
);

-- Verificar que la reseña fue insertada correctamente
SELECT ok(
  (SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Test review for add_like_dislike') = 1, 
  'Mock review for add_like_dislike inserted'
);

-- Obtener el ID de la reseña recién creada y asignarlo a una variable de sesión
SELECT id AS review_id FROM public."Reviews" WHERE comment = 'Test review for add_like_dislike' \gset

-- Añadir un like cuando no hay ninguna reacción
SELECT public.add_like(:'review_id');
SELECT ok(
  (SELECT likes FROM public."Reviews" WHERE id = :'review_id') = 1,
  'Like added successfully when no reaction exists'
);

-- No duplicar like si el usuario ya ha dado like
SELECT public.add_like(:'review_id');
SELECT ok(
  (SELECT likes FROM public."Reviews" WHERE id = :'review_id') = 1,
  'Like not duplicated when user already liked'
);

-- Cambiar un like a dislike
SELECT public.add_dislike(:'review_id');
SELECT ok(
  (SELECT dislikes FROM public."Reviews" WHERE id = :'review_id') = 1 AND
  (SELECT likes FROM public."Reviews" WHERE id = :'review_id') = 0,
  'Like changed to dislike successfully'
);

-- No duplicar dislike si el usuario ya ha dado dislike
SELECT public.add_dislike(:'review_id');
SELECT ok(
  (SELECT dislikes FROM public."Reviews" WHERE id = :'review_id') = 1,
  'Dislike not duplicated when user already disliked'
);

-- Cambiar un dislike a like
SELECT public.add_like(:'review_id');
SELECT ok(
  (SELECT likes FROM public."Reviews" WHERE id = :'review_id') = 1 AND
  (SELECT dislikes FROM public."Reviews" WHERE id = :'review_id') = 0,
  'Dislike changed to like successfully'
);

-- Restaurar configuración de auth.uid()
SELECT set_config('request.jwt.claims', '', true);

ROLLBACK;
