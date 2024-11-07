-- Start the test set
BEGIN;

-- Plan the number of tests
SELECT plan(4);

-- Test: Insert a review
INSERT INTO public."Reviews" (id, user_id, rating, comment, movie_id) VALUES (gen_random_uuid(), 'ea02ab60-fdd0-4913-ad27-8d472a89ac0c', 5, 'Great product!', 1);
SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Great product!') = 1, 'Insert review');

-- Test: Read a review
SELECT ok((SELECT comment FROM public."Reviews" WHERE comment = 'Great product!') = 'Great product!', 'Read review');

-- Test: Update a review
UPDATE public."Reviews" SET comment = 'Updated review' WHERE comment = 'Great product!';
SELECT ok((SELECT comment FROM public."Reviews" WHERE comment = 'Updated review') = 'Updated review', 'Update review');

-- Test: Delete a review
DELETE FROM public."Reviews" WHERE comment = 'Updated review';
SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Updated review') = 0, 'Delete review');

-- Finish the test set
SELECT * FROM finish();
ROLLBACK;
