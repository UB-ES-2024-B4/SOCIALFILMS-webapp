
BEGIN;


SELECT plan(4);


SELECT ok((SELECT public.create_review('ea02ab60-fdd0-4913-ad27-8d472a89ac0c', 1, 5, 'Great movie!') IS NOT NULL), 'Create review function called');


SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Great movie!') = 1, 'Review inserted');


SELECT ok((SELECT id FROM public."Reviews" WHERE comment = 'Great movie!') IS NOT NULL, 'Returned review ID is valid');


SELECT ok((SELECT comment FROM public."Reviews" WHERE comment = 'Great movie!') = 'Great movie!', 'Inserted review content matches');


SELECT * FROM finish();
ROLLBACK;
