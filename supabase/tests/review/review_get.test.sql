
BEGIN;


SELECT plan(4);


SELECT ok((SELECT public.create_review(1, 5, 'Mock review for get', '5899f99d-a449-4bfa-8769-19c097aaf1f5') IS NOT NULL), 'Create mock review for get_reviews');


SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Mock review for get') = 1, 'Mock review inserted');


SELECT ok((SELECT json_array_length(public.get_reviews('5899f99d-a449-4bfa-8769-19c097aaf1f5', 1)) = 1), 'get_reviews returned one review');


SELECT ok((SELECT (public.get_reviews('5899f99d-a449-4bfa-8769-19c097aaf1f5', 1)->0->>'comment') = 'Mock review for get'), 'Retrieved review content matches');


SELECT * FROM finish();
ROLLBACK;
