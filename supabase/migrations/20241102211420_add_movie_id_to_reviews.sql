alter table "public"."Reviews" add column "movie_id" integer not null;

CREATE UNIQUE INDEX "Reviews_movie_id_key" ON public."Reviews" USING btree (movie_id);

CREATE UNIQUE INDEX "Reviews_user_id_key" ON public."Reviews" USING btree (user_id);

alter table "public"."Reviews" add constraint "Reviews_movie_id_key" UNIQUE using index "Reviews_movie_id_key";

alter table "public"."Reviews" add constraint "Reviews_user_id_key" UNIQUE using index "Reviews_user_id_key";


