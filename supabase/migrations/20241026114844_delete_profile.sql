revoke delete on table "public"."Profile" from "anon";

revoke insert on table "public"."Profile" from "anon";

revoke references on table "public"."Profile" from "anon";

revoke select on table "public"."Profile" from "anon";

revoke trigger on table "public"."Profile" from "anon";

revoke truncate on table "public"."Profile" from "anon";

revoke update on table "public"."Profile" from "anon";

revoke delete on table "public"."Profile" from "authenticated";

revoke insert on table "public"."Profile" from "authenticated";

revoke references on table "public"."Profile" from "authenticated";

revoke select on table "public"."Profile" from "authenticated";

revoke trigger on table "public"."Profile" from "authenticated";

revoke truncate on table "public"."Profile" from "authenticated";

revoke update on table "public"."Profile" from "authenticated";

revoke delete on table "public"."Profile" from "service_role";

revoke insert on table "public"."Profile" from "service_role";

revoke references on table "public"."Profile" from "service_role";

revoke select on table "public"."Profile" from "service_role";

revoke trigger on table "public"."Profile" from "service_role";

revoke truncate on table "public"."Profile" from "service_role";

revoke update on table "public"."Profile" from "service_role";

alter table "public"."Profile" drop constraint "Profile_pkey";

drop index if exists "public"."Profile_pkey";

drop table "public"."Profile";


