
BEGIN;


SELECT plan(4);



SELECT public.create_review(1, 5, 'Great movie!', '062cd767-f3fa-4bcf-9bee-230062f19fb0');


SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Great movie!') = 1, 'Initial review inserted for update');



DO $$
DECLARE
  review_id UUID;
BEGIN
  SELECT id INTO review_id FROM public."Reviews" WHERE comment = 'Great movie!';
  PERFORM public.update_review(review_id, 4, 'Updated great movie!');
END $$;


SELECT ok((SELECT comment FROM public."Reviews" WHERE comment = 'Updated great movie!') = 'Updated great movie!', 'Review updated in database');


SELECT ok((SELECT rating FROM public."Reviews" WHERE comment = 'Updated great movie!') = 4, 'Review rating updated in database');



UPDATE public."Reviews" SET editable = false WHERE comment = 'Updated great movie!';


SELECT ok((SELECT public.update_review((SELECT id FROM public."Reviews" WHERE comment = 'Updated great movie!'), 5, 'Another update attempt')) = 'Review cannot be updated because it is not editable.', 'Attempt to update non-editable review returns correct message');


SELECT * FROM finish();
ROLLBACK;
