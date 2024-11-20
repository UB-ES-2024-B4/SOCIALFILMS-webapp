CREATE OR REPLACE FUNCTION public.get_dislikes_for_review(_review_id UUID)
RETURNS INT
LANGUAGE sql
AS $$
  SELECT dislikes
  FROM public."Reviews"
  WHERE id = _review_id;
$$;