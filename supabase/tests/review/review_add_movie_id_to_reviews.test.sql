BEGIN;
SELECT plan(5);


<<<<<<< HEAD:supabase/tests/review_addMovieIdToReviews_test.sql
SELECT ok((SELECT public.create_review(1, 5, 'Mock review to test unique constraints', '062cd767-f3fa-4bcf-9bee-230062f19fb0') IS NOT NULL), 
=======
SELECT ok((SELECT public.create_review(1, 5, 'Mock review to test unique constraints', '5899f99d-a449-4bfa-8769-19c097aaf1f5') IS NOT NULL), 
>>>>>>> df26dbdb92f93d8d857656c412eddc574f27c724:supabase/tests/review/review_add_movie_id_to_reviews.test.sql
          'Create review with unique movie_id and user_id');


SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Mock review to test unique constraints') = 1, 
          'Mock review inserted with unique constraints');


DO $$
BEGIN
    BEGIN
<<<<<<< HEAD:supabase/tests/review_addMovieIdToReviews_test.sql
        PERFORM public.create_review(1, 5, 'Duplicate user_id test', '062cd767-f3fa-4bcf-9bee-230062f19fb0');
=======
        PERFORM public.create_review(1, 5, 'Duplicate user_id test', '5899f99d-a449-4bfa-8769-19c097aaf1f5');
>>>>>>> df26dbdb92f93d8d857656c412eddc574f27c724:supabase/tests/review/review_add_movie_id_to_reviews.test.sql
        RAISE EXCEPTION 'Expected unique constraint violation for user_id, but insert succeeded';
    EXCEPTION WHEN unique_violation THEN
        PERFORM NULL;
    END;
END $$;
SELECT ok(TRUE, 'Insertion with duplicate user_id failed as expected');

<<<<<<< HEAD:supabase/tests/review_addMovieIdToReviews_test.sql
-- Verificar que no hay duplicados en la tabla después de los intentos fallidos
SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE user_id = '062cd767-f3fa-4bcf-9bee-230062f19fb0' AND comment = 'Mock review to test unique constraints') = 1, 
=======

SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE user_id = '5899f99d-a449-4bfa-8769-19c097aaf1f5' AND comment = 'Mock review to test unique constraints') = 1, 
>>>>>>> df26dbdb92f93d8d857656c412eddc574f27c724:supabase/tests/review/review_add_movie_id_to_reviews.test.sql
          'No duplicates inserted for movie_id or user_id');


SELECT 'Delete function called', public.delete_review((SELECT id FROM public."Reviews" WHERE comment = 'Mock review to test unique constraints'));
SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Mock review to test unique constraints') = 0, 
          'Test review deleted successfully');


SELECT * FROM finish();
ROLLBACK;
