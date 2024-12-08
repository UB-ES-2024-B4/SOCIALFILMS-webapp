set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_reviews_paginated(
  _movie_id INT DEFAULT NULL,
  _limit INT DEFAULT 10,
  _offset INT DEFAULT 0,
  _sort_by TEXT DEFAULT 'most_recent',
  _filter TEXT DEFAULT NULL
)
RETURNS json
LANGUAGE sql
AS $$
  WITH prioritized_reviews AS (
    SELECT 
      r.*, 
      p.username AS user,

      CASE 
        WHEN r.user_id = auth.uid() THEN 1 ELSE 0 
      END AS user_priority,

      CASE 
        WHEN _sort_by = 'most_recent' THEN EXTRACT(EPOCH FROM r.created_at)
        WHEN _sort_by = 'highest_rating' THEN r.rating
        WHEN _sort_by = 'lowest_rating' THEN -r.rating
        WHEN _sort_by = 'with_spoilers' THEN (CASE WHEN r.spoilers THEN 1 ELSE 0 END)
        WHEN _sort_by = 'without_spoilers' THEN (CASE WHEN r.spoilers THEN 0 ELSE 1 END)
        ELSE 0
      END AS sort_value
    FROM public."Reviews" r
    JOIN public."profiles" p ON r.user_id = p.id
    WHERE (_movie_id IS NULL OR r.movie_id = _movie_id)
      AND (_filter IS NULL OR p.username ILIKE '%' || _filter || '%' OR r.comment ILIKE '%' || _filter || '%')
  )
  SELECT json_build_object(
    'reviews', json_agg(json_build_object(
             'created_at', r.created_at,
             'user_id', r.user_id,
             'rating', r.rating,
             'comment', r.comment,
             'likes', r.likes,
             'dislikes', r.dislikes,
             'shared_count', r.shared_count,
             'id', r.id,
             'editable', r.editable,
             'movie_id', r.movie_id,
             'spoilers', r.spoilers,
             'user', r.user
           )),
    'has_more', EXISTS (
        SELECT 1
        FROM prioritized_reviews
        OFFSET (_offset + _limit)
        LIMIT 1
    )
  )
  FROM (
    SELECT *
    FROM prioritized_reviews
    ORDER BY user_priority DESC, sort_value DESC, EXTRACT(EPOCH FROM created_at) DESC
    LIMIT _limit OFFSET _offset
  ) r;
$$;
