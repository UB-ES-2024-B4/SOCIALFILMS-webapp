alter table "public"."Reviews" drop constraint "Reviews_movie_id_key";

alter table "public"."Reviews" drop constraint "Reviews_user_id_key";

drop index if exists "public"."Reviews_movie_id_key";

drop index if exists "public"."Reviews_user_id_key";


