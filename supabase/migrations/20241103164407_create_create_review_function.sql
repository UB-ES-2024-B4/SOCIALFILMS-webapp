CREATE OR REPLACE FUNCTION public.create_review(
  _user_id UUID,
  _movie_id INT,
  _rating INT,
  _comment VARCHAR
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  new_review_id UUID;
BEGIN
  INSERT INTO public."Reviews" (user_id, movie_id, rating, comment, created_at, editable, likes, dislikes, shared_count)
  VALUES (_user_id, _movie_id, _rating, _comment, NOW(), true, 0, 0, 0)
  RETURNING id INTO new_review_id;

  RETURN new_review_id;
END;
$$;
