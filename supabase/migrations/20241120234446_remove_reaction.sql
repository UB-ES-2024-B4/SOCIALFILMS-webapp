CREATE OR REPLACE FUNCTION public.remove_reaction(_review_id UUID)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  current_reaction TEXT;
BEGIN
  -- Obtener la reacción actual del usuario
  SELECT reaction INTO current_reaction
  FROM public."Review-Reactions"
  WHERE user_id = auth.uid() AND review_id = _review_id;

  -- Si no hay reacción, salir
  IF current_reaction IS NULL THEN
    RETURN;
  END IF;

  -- Eliminar la reacción
  DELETE FROM public."Review-Reactions"
  WHERE user_id = auth.uid() AND review_id = _review_id;

  -- Actualizar contadores en Reviews
  IF current_reaction = 'like' THEN
    UPDATE public."Reviews"
    SET likes = likes - 1
    WHERE id = _review_id;
  ELSIF current_reaction = 'dislike' THEN
    UPDATE public."Reviews"
    SET dislikes = dislikes - 1
    WHERE id = _review_id;
  END IF;
END;
$$;
