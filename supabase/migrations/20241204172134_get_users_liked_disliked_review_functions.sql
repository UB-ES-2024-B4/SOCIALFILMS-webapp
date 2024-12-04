drop policy "select_reaction" on "public"."Review-Reactions";

create policy "select_reaction"
on "public"."Review-Reactions"
as permissive
for select
to authenticated
using (true);

SET check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_users_liked_review(
  _review_id UUID
)
RETURNS json
LANGUAGE sql
AS $$
  SELECT json_agg(row_to_json(u))
  FROM (
    SELECT 
      p.username,
      p.real_name,
      p.last_name,
      CASE WHEN rr.user_id = auth.uid() THEN 1 ELSE 0 END AS user_priority
    FROM public."Review-Reactions" rr
    JOIN public.profiles p ON rr.user_id = p.id
    WHERE rr.review_id = _review_id
      AND rr.reaction = 'like'
    ORDER BY user_priority DESC, rr.created_at DESC
  ) u;
$$;

CREATE OR REPLACE FUNCTION public.get_users_disliked_review(
  _review_id UUID
)
RETURNS json
LANGUAGE sql
AS $$
  SELECT json_agg(row_to_json(u))
  FROM (
    SELECT 
      p.username,
      p.real_name,
      p.last_name,
      CASE WHEN rr.user_id = auth.uid() THEN 1 ELSE 0 END AS user_priority
    FROM public."Review-Reactions" rr
    JOIN public.profiles p ON rr.user_id = p.id
    WHERE rr.review_id = _review_id
      AND rr.reaction = 'dislike'
    ORDER BY user_priority DESC, rr.created_at DESC
  ) u;
$$;

CREATE OR REPLACE FUNCTION public.get_reviews_liked_by_user(
  _user_id UUID DEFAULT NULL
)
RETURNS json
LANGUAGE sql
AS $$
  SELECT json_agg(row_to_json(r))
  FROM (
    SELECT 
      r.id AS review_id,
      r.created_at AS review_date,
      r.content AS review_content,
      CASE WHEN rr.user_id = auth.uid() THEN 1 ELSE 0 END AS user_priority
    FROM public."Review-Reactions" rr
    JOIN public."Reviews" r ON rr.review_id = r.id
    WHERE rr.user_id = COALESCE(_user_id, auth.uid())
      AND rr.reaction = 'like'
    ORDER BY user_priority DESC, r.created_at DESC
  ) r;
$$;

CREATE OR REPLACE FUNCTION public.get_reviews_disliked_by_user(
  _user_id UUID DEFAULT NULL
)
RETURNS json
LANGUAGE sql
AS $$
  SELECT json_agg(row_to_json(r))
  FROM (
    SELECT 
      r.id AS review_id,
      r.created_at AS review_date,
      r.content AS review_content,
      CASE WHEN rr.user_id = auth.uid() THEN 1 ELSE 0 END AS user_priority
    FROM public."Review-Reactions" rr
    JOIN public."Reviews" r ON rr.review_id = r.id
    WHERE rr.user_id = COALESCE(_user_id, auth.uid())
      AND rr.reaction = 'dislike'
    ORDER BY user_priority DESC, r.created_at DESC
  ) r;
$$;

CREATE OR REPLACE FUNCTION public.get_reviews_disliked_by_user(
  _user_id UUID DEFAULT NULL
)
RETURNS json
LANGUAGE sql
AS $$
  SELECT json_agg(row_to_json(r))
  FROM (
    SELECT 
      r.id AS review_id,
      r.created_at AS review_date,
      r.content AS review_content,
      CASE WHEN rr.user_id = auth.uid() THEN 1 ELSE 0 END AS user_priority
    FROM public."Review-Reactions" rr
    JOIN public."Reviews" r ON rr.review_id = r.id
    WHERE rr.user_id = COALESCE(_user_id, auth.uid())
      AND rr.reaction = 'dislike'
    ORDER BY user_priority DESC, r.created_at DESC
  ) r;
$$;