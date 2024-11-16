BEGIN;


SELECT plan(3);


SELECT ok(
  (SELECT public.get_credits_movie(98) IS NOT NULL), 
  'get_credits_movie returns a result for a valid movie_id'
);


SELECT ok(
  (SELECT COUNT(*) > 0
   FROM json_array_elements(public.get_credits_movie(98)->'cast') AS cast_member),
  'get_credits_movie result contains at least one cast member'
);


SELECT ok(
  (SELECT EXISTS (
      SELECT 1
      FROM json_array_elements(public.get_credits_movie(98)->'cast') AS cast_member
      WHERE cast_member->>'name' = 'Russell Crowe'
  )),
  'get_credits_movie result contains an actor named "Russell Crowe"'
);

SELECT * FROM finish();
ROLLBACK;
