
BEGIN;


SELECT plan(4);


SELECT ok((SELECT public.create_review(1, 5, 'Mock review to delete', '062cd767-f3fa-4bcf-9bee-230062f19fb0') IS NOT NULL), 'Create mock review for deletion');


SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Mock review to delete') = 1, 'Mock review inserted');


SELECT 'Delete function called', public.delete_review((SELECT id FROM public."Reviews" WHERE comment = 'Mock review to delete'));


SELECT ok(TRUE, 'Delete review function called successfully');


SELECT ok((SELECT COUNT(*) FROM public."Reviews" WHERE comment = 'Mock review to delete') = 0, 'Review deleted successfully');


SELECT * FROM finish();
ROLLBACK;
