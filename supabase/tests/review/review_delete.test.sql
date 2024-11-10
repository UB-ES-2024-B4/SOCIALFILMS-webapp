
BEGIN;


SELECT plan(4);


SELECT ok((SELECT public.create_review('ea02ab60-fdd0-4913-ad27-8d472a89ac0c', 1, 5, 'Mock review to delete') IS NOT NULL), 'Create mock review for deletion');


SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Mock review to delete') = 1, 'Mock review inserted');


SELECT 'Delete function called', public.delete_review((SELECT id FROM public."Reviews" WHERE comment = 'Mock review to delete'));


SELECT ok(TRUE, 'Delete review function called successfully');


SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Mock review to delete') = 0, 'Review deleted successfully');


SELECT * FROM finish();
ROLLBACK;
