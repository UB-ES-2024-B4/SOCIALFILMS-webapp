set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.add_dislike(_review_id uuid)
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
    -- Verificar si la reacción actual es 'like' antes de actualizar los contadores
    IF EXISTS (
        SELECT 1
        FROM public."Review-Reactions"
        WHERE user_id = auth.uid() AND review_id = _review_id AND reaction = 'like'
    ) THEN
        -- Actualizar contadores en Reviews solo si la reacción era 'like'
        UPDATE public."Review-Reactions"
        SET reaction = 'dislike'
        WHERE user_id = auth.uid() AND review_id = _review_id;

        -- Actualizar contadores en Reviews
        UPDATE public."Reviews"
        SET dislikes = dislikes + 1, likes = likes - 1
        WHERE id = _review_id;

    END IF;
  ELSE
    -- Si no hay reacción, insertar un dislike
    INSERT INTO public."Review-Reactions" (user_id, review_id, reaction)
    VALUES (auth.uid(), _review_id, 'dislike');

    -- Incrementar contador de dislikes
    UPDATE public."Reviews"
    SET dislikes = dislikes + 1
    WHERE id = _review_id;
  END IF;
END;
$function$
;

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
    -- Verificar si la reacción actual es 'dislike' antes de actualizar los contadores
    IF EXISTS (
        SELECT 1
        FROM public."Review-Reactions"
        WHERE user_id = auth.uid() AND review_id = _review_id AND reaction = 'dislike'
    ) THEN
        UPDATE public."Review-Reactions"
        SET reaction = 'like'
        WHERE user_id = auth.uid() AND review_id = _review_id;

        -- Actualizar contadores en Reviews solo si la reacción era 'dislike'
        UPDATE public."Reviews"
        SET likes = likes + 1, dislikes = dislikes - 1
        WHERE id = _review_id;
    END IF;

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


