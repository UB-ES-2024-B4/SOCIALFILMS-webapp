CREATE TYPE relation_type_enum AS ENUM ('favorite', 'watch_later');
ALTER TABLE public."User-Movies"
ADD COLUMN relation_type relation_type_enum NOT NULL;
ALTER TABLE public."User-Movies"
DROP CONSTRAINT unique_user_like_movie;
ALTER TABLE public."User-Movies"
ADD CONSTRAINT unique_user_rel_movie UNIQUE (user_id, movie_id, relation_type);

DROP POLICY user_access_policy ON public."User-Movies";
CREATE POLICY user_access_policy
ON public."User-Movies"
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());
