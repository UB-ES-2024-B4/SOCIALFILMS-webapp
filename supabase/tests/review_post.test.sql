-- Start the test set
BEGIN;

-- Plan the number of tests
SELECT plan(4);

-- Test: Call create_review function
SELECT ok((SELECT public.create_review('ea02ab60-fdd0-4913-ad27-8d472a89ac0c', 1, 5, 'Great movie!') IS NOT NULL), 'Create review function called');

-- Test: Check if review is inserted
SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Great movie!') = 1, 'Review inserted');

-- Test: Check returned review ID
SELECT ok((SELECT id FROM public."Reviews" WHERE comment = 'Great movie!') IS NOT NULL, 'Returned review ID is valid');

-- Test: Check the content of the inserted review
SELECT ok((SELECT comment FROM public."Reviews" WHERE comment = 'Great movie!') = 'Great movie!', 'Inserted review content matches');

-- Finish the test set
SELECT * FROM finish();
ROLLBACK;
