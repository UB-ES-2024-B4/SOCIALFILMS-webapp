set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.add_like(_review_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Verificar si ya existe una reacción del usuario
  IF EXISTS (
    SELECT 1
    FROM public."Review-Reactions"
    WHERE user_id = auth.uid() AND review_id = _review_id
  ) THEN
    -- Si la reacción actual es dislike, cambiar a like
    UPDATE public."Review-Reactions"
    SET reaction = 'like'
    WHERE user_id = auth.uid() AND review_id = _review_id AND reaction = 'dislike';

    -- Actualizar contadores en Reviews
    UPDATE public."Reviews"
    SET likes = likes + 1, dislikes = dislikes - 1
    WHERE id = _review_id;
  ELSE
    -- Si no hay reacción, insertar un like
    INSERT INTO public."Review-Reactions" (user_id, review_id, reaction)
    VALUES (auth.uid(), _review_id, 'like');

    -- Incrementar contador de likes
    UPDATE public."Reviews"
    SET likes = likes + 1
    WHERE id = _review_id;
  END IF;
END;
$function$
;


