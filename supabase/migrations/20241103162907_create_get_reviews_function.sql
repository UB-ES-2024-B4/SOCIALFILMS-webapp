CREATE OR REPLACE FUNCTION public.get_reviews(_user_id UUID DEFAULT NULL, _movie_id INT DEFAULT NULL)
RETURNS json
LANGUAGE sql
AS $$
  SELECT json_agg(row_to_json(r))
  FROM (
    SELECT *
    FROM public."Reviews"
    WHERE (_user_id IS NULL OR user_id = _user_id)
      AND (_movie_id IS NULL OR movie_id = _movie_id)
  ) r;
$$;
