CREATE OR REPLACE FUNCTION public.get_user_reaction_review(_review_id UUID)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  user_reaction TEXT;
BEGIN
  -- Consultar la reacción del usuario autenticado para la reseña especificada
  SELECT reaction
  INTO user_reaction
  FROM public."Review-Reactions"
  WHERE user_id = auth.uid() AND review_id = _review_id;

  -- Si no se encuentra la reacción, lanzar un error personalizado
  IF user_reaction IS NULL THEN
    RAISE EXCEPTION 'No reaction found for user % and review %', auth.uid(), _review_id
      USING ERRCODE = 'R0001'; -- Código de error personalizado
  END IF;

  -- Retornar la reacción encontrada
  RETURN user_reaction;
END;
$$;