alter table "public"."Reviews" add column "spoilers" boolean not null default false;

CREATE OR REPLACE FUNCTION public.create_review(
  _movie_id INT,
  _rating INT,
  _comment VARCHAR,
  _spoilers BOOLEAN DEFAULT false,
  _user_id UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  new_review_id UUID;
BEGIN
  INSERT INTO public."Reviews" (user_id, movie_id, rating, comment, spoilers, created_at, editable, likes, dislikes, shared_count)
  VALUES (COALESCE(_user_id, auth.uid()), _movie_id, _rating, _comment, _spoilers, NOW(), true, 0, 0, 0)
  RETURNING id INTO new_review_id;

  RETURN new_review_id;
END;
$$;

drop function if exists "public"."create_review"(_movie_id integer, _rating integer, _comment character varying, _user_id UUID);

CREATE OR REPLACE FUNCTION public.update_review(
  _review_id UUID,
  _rating INT,
  _comment VARCHAR,
  _spoilers BOOLEAN DEFAULT false
)
RETURNS TEXT
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
      spoilers = _spoilers,
      created_at = NOW()
    WHERE id = _review_id;

    RETURN 'Review updated successfully.';
  ELSE
    RETURN 'Review cannot be updated because it is not editable.';
  END IF;
END;
$$;

drop function if exists "public"."update_review"(_review_id UUID, _rating INT, _comment VARCHAR);