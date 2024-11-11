
BEGIN;


SELECT plan(4);


SELECT ok((SELECT public.create_review('062cd767-f3fa-4bcf-9bee-230062f19fb0', 1, 5, 'Great movie!') IS NOT NULL), 'Create review function called');


SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Great movie!') = 1, 'Review inserted');


SELECT ok((SELECT id FROM public."Reviews" WHERE comment = 'Great movie!') IS NOT NULL, 'Returned review ID is valid');


SELECT ok((SELECT comment FROM public."Reviews" WHERE comment = 'Great movie!') = 'Great movie!', 'Inserted review content matches');


SELECT * FROM finish();
ROLLBACK;
