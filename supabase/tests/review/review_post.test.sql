
BEGIN;


SELECT plan(4);


SELECT ok((SELECT public.create_review(1, 5, 'Great movie!', '5899f99d-a449-4bfa-8769-19c097aaf1f5') IS NOT NULL), 'Create review function called');


SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Great movie!') = 1, 'Review inserted');


SELECT ok((SELECT id FROM public."Reviews" WHERE comment = 'Great movie!') IS NOT NULL, 'Returned review ID is valid');


SELECT ok((SELECT comment FROM public."Reviews" WHERE comment = 'Great movie!') = 'Great movie!', 'Inserted review content matches');


SELECT * FROM finish();
ROLLBACK;
