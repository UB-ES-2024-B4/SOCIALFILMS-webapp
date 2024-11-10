CREATE OR REPLACE FUNCTION public.delete_review(_review_id UUID)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM public."Reviews"
  WHERE id = _review_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Review not found';
  END IF;
END;
$$;
