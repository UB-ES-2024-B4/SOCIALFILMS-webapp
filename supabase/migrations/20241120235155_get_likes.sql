CREATE OR REPLACE FUNCTION public.get_likes_for_review(_review_id UUID)
RETURNS INT
LANGUAGE sql
AS $$
  SELECT likes
  FROM public."Reviews"
  WHERE id = _review_id;
$$;