CREATE OR REPLACE FUNCTION public.add_dislike(_user_id UUID, _review_id UUID)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  -- Verificar si ya existe una reacción del usuario
  IF EXISTS (
    SELECT 1
    FROM public."Review-Reactions"
    WHERE user_id = _user_id AND review_id = _review_id
  ) THEN
    -- Si la reacción actual es like, cambiar a dislike
    UPDATE public."Review-Reactions"
    SET reaction = 'dislike'
    WHERE user_id = _user_id AND review_id = _review_id AND reaction = 'like';

    -- Actualizar contadores en Reviews
    UPDATE public."Reviews"
    SET dislikes = dislikes + 1, likes = likes - 1
    WHERE id = _review_id;
  ELSE
    -- Si no hay reacción, insertar un dislike
    INSERT INTO public."Review-Reactions" (user_id, review_id, reaction)
    VALUES (_user_id, _review_id, 'dislike');

    -- Incrementar contador de dislikes
    UPDATE public."Reviews"
    SET dislikes = dislikes + 1
    WHERE id = _review_id;
  END IF;
END;
$$;
