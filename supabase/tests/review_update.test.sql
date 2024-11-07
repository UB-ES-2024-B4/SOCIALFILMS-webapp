-- Start the test set
BEGIN;

-- Plan the number of tests
SELECT plan(5);

-- Test: Insert a review first for updating
-- (This setup is needed to have an existing review to update)
SELECT public.create_review('ea02ab60-fdd0-4913-ad27-8d472a89ac0c', 1, 5, 'Great movie!');

-- Get the review ID for later use
SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Great movie!') = 1, 'Initial review inserted for update');

-- Fetch the review ID and update
-- Update the review
DO $$
DECLARE
  review_id UUID;
BEGIN
  SELECT id INTO review_id FROM public."Reviews" WHERE comment = 'Great movie!';
  PERFORM public.update_review(review_id, 4, 'Updated great movie!');
END $$;

-- Test: Check if review is updated
SELECT ok((SELECT comment FROM public."Reviews" WHERE comment = 'Updated great movie!') = 'Updated great movie!', 'Review updated in database');

-- Test: Check if the rating is updated
SELECT ok((SELECT rating FROM public."Reviews" WHERE comment = 'Updated great movie!') = 4, 'Review rating updated in database');

-- Test: Attempt to update a non-editable review
-- First, update the review to make it non-editable
UPDATE public."Reviews" SET editable = false WHERE comment = 'Updated great movie!';

-- Test: Call update_review function on non-editable review
SELECT ok((SELECT public.update_review((SELECT id FROM public."Reviews" WHERE comment = 'Updated great movie!'), 5, 'Another update attempt')) = 'Review cannot be updated because it is not editable.', 'Attempt to update non-editable review returns correct message');

-- Finish the test set
SELECT * FROM finish();
ROLLBACK;
