BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

-- Configurar el usuario simulado para auth.uid()
SELECT set_config('request.jwt.claims', '{"sub": "5899f99d-a449-4bfa-8769-19c097aaf1f5"}', true);

SELECT plan(4);

SELECT ok((SELECT public.create_review(1, 5, 'Mock review to test report', false, '5899f99d-a449-4bfa-8769-19c097aaf1f5') IS NOT NULL), 
          'Create review with unique movie_id and user_id');

-- Obtener el ID de la reseña recién creada y asignarlo a una variable de sesión
SELECT id AS review_id FROM public."Reviews" WHERE comment = 'Mock review to test report' \gset

-- Añadir un reporte válido con motivo 'Spam'
SELECT public.add_report(:'review_id', 'Spam', NULL);
SELECT ok(
  (SELECT COUNT(*) FROM public."Report" WHERE review_id = :'review_id' AND reason = 'Spam') = 1,
  'Report added successfully with reason Spam'
);

-- Obtener los reportes de la review
SELECT public.get_reports_for_review(:'review_id');
SELECT ok(
  (SELECT COUNT(*) FROM public.get_reports_for_review(:'review_id')) = 1,
  'Get reports for review returns correct number of reports'
);

-- Eliminar un reporte
SELECT public.delete_report(:'review_id');
SELECT ok(
  (SELECT COUNT(*) FROM public."Report" WHERE review_id = :'review_id') = 0,
  'Report deleted successfully'
);

SELECT set_config('request.jwt.claims', '', true);

ROLLBACK;