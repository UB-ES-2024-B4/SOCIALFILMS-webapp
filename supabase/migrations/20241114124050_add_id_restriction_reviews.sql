alter table "public"."Reviews";

CREATE UNIQUE INDEX unique_user_movie_review ON public."Reviews" USING btree (user_id, movie_id);

alter table "public"."Reviews" add constraint "unique_user_movie_review" UNIQUE using index "unique_user_movie_review";


