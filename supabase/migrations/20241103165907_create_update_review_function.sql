CREATE OR REPLACE FUNCTION public.update_review(
  _review_id UUID,
  _rating INT,
  _comment VARCHAR,
  _spoilers BOOLEAN -- Nuevo parámetro para la columna spoilers
)
RETURNS TEXT -- Mensaje de estado
LANGUAGE plpgsql
AS $$
BEGIN
  -- Verificar si la reseña es editable
  IF EXISTS (
    SELECT 1
    FROM public."Reviews"
    WHERE id = _review_id AND editable = true
  ) THEN
    -- Realizar la actualización si editable es true
    UPDATE public."Reviews"
    SET
      rating = _rating,
      comment = _comment,
      spoilers = _spoilers, -- Actualización de la columna spoilers
      created_at = NOW()
    WHERE id = _review_id;

    RETURN 'Review updated successfully.';
  ELSE
    RETURN 'Review cannot be updated because it is not editable.';
  END IF;
END;
$$;
