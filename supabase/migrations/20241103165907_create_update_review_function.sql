CREATE OR REPLACE FUNCTION public.update_review(
  _review_id UUID,
  _rating INT,
  _comment VARCHAR,
  _spoilers BOOLEAN
)
RETURNS TEXT -- Return a status message
LANGUAGE plpgsql
AS $$
BEGIN
  -- Check if the review is editable
  IF EXISTS (
    SELECT 1
    FROM public."Reviews"
    WHERE id = _review_id AND editable = true
  ) THEN
    -- Perform the update if editable is true
    UPDATE public."Reviews"
    SET
      rating = _rating,
      comment = _comment,
      spoilers = _spoilers,
      created_at = NOW()
    WHERE id = _review_id;

    RETURN 'Review updated successfully.';
  ELSE
    RETURN 'Review cannot be updated because it is not editable.';
  END IF;
END;
$$;
