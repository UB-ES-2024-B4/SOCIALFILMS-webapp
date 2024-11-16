BEGIN;
SELECT plan(5);


SELECT ok((SELECT public.create_review(1, 5, 'Mock review to test unique constraints', '5899f99d-a449-4bfa-8769-19c097aaf1f5') IS NOT NULL), 
          'Create review with unique movie_id and user_id');


SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Mock review to test unique constraints') = 1, 
          'Mock review inserted with unique constraints');



-- Intentar insertar una reseña con el mismo user_id ('unique-user-id'), lo cual debería fallar por la restricción de unicidad
DO $$
BEGIN
    BEGIN
        PERFORM public.create_review(1, 5, 'Duplicate user_id test', '5899f99d-a449-4bfa-8769-19c097aaf1f5');
        RAISE EXCEPTION 'Expected unique constraint violation for user_id, but insert succeeded';
    EXCEPTION WHEN unique_violation THEN
        PERFORM NULL;
    END;
END $$;
SELECT ok(TRUE, 'Insertion with duplicate user_id failed as expected');

-- Verificar que no hay duplicados en la tabla después de los intentos fallidos
SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE user_id = '5899f99d-a449-4bfa-8769-19c097aaf1f5' AND comment = 'Mock review to test unique constraints') = 1, 
          'No duplicates inserted for movie_id or user_id');

-- Limpiar la prueba eliminando la reseña creada para este test
SELECT 'Delete function called', public.delete_review((SELECT id FROM public."Reviews" WHERE comment = 'Mock review to test unique constraints'));
SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Mock review to test unique constraints') = 0, 
          'Test review deleted successfully');


SELECT * FROM finish();
ROLLBACK;
