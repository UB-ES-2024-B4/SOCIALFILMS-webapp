CREATE OR REPLACE FUNCTION public.get_reviews(_user_id UUID DEFAULT NULL, _movie_id INT DEFAULT NULL)
RETURNS json
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT json_agg(row_to_json(r))
  FROM (
    SELECT 
      r.*,
      p.username AS user
    FROM public."Reviews" r
    LEFT JOIN public.profiles p
      ON r.user_id = p.id
    WHERE (_user_id IS NULL OR r.user_id = _user_id)
      AND (_movie_id IS NULL OR r.movie_id = _movie_id)
  ) r;
$$;
