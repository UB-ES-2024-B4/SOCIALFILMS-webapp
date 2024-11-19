drop policy "Administradores pueden actualizar peliculas" on "public"."Movies";

drop policy "Administradores pueden añadir peliculas" on "public"."Movies";

drop policy "Administradores pueden eliminar peliculas" on "public"."Movies";

revoke delete on table "public"."Movies" from "anon";

revoke insert on table "public"."Movies" from "anon";

revoke references on table "public"."Movies" from "anon";

revoke select on table "public"."Movies" from "anon";

revoke trigger on table "public"."Movies" from "anon";

revoke truncate on table "public"."Movies" from "anon";

revoke update on table "public"."Movies" from "anon";

revoke delete on table "public"."Movies" from "authenticated";

revoke insert on table "public"."Movies" from "authenticated";

revoke references on table "public"."Movies" from "authenticated";

revoke select on table "public"."Movies" from "authenticated";

revoke trigger on table "public"."Movies" from "authenticated";

revoke truncate on table "public"."Movies" from "authenticated";

revoke update on table "public"."Movies" from "authenticated";

revoke delete on table "public"."Movies" from "service_role";

revoke insert on table "public"."Movies" from "service_role";

revoke references on table "public"."Movies" from "service_role";

revoke select on table "public"."Movies" from "service_role";

revoke trigger on table "public"."Movies" from "service_role";

revoke truncate on table "public"."Movies" from "service_role";

revoke update on table "public"."Movies" from "service_role";

alter table "public"."Reviews" drop constraint "Reviews_movie_id_fkey";

alter table "public"."Movies" drop constraint "Movies_pkey";

drop index if exists "public"."Movies_pkey";

drop table "public"."Movies";


