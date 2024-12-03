create table "public"."followers" (
    "id" uuid not null default gen_random_uuid(),
    "followed_at" timestamp with time zone not null default now(),
    "follower_id" uuid not null default gen_random_uuid(),
    "following_id" uuid not null default gen_random_uuid(),
    "follower_username" text not null,
    "following_username" text not null,
    UNIQUE (follower_id, following_id)
);


alter table "public"."followers" enable row level security;

CREATE UNIQUE INDEX followers_pkey ON public.followers USING btree (id);

alter table "public"."followers" add constraint "followers_pkey" PRIMARY KEY using index "followers_pkey";

alter table "public"."followers" add constraint "followers_follower_id_fkey" FOREIGN KEY (follower_id) REFERENCES profiles(id) not valid;

alter table "public"."followers" validate constraint "followers_follower_id_fkey";

alter table "public"."followers" add constraint "followers_following_id_fkey" FOREIGN KEY (following_id) REFERENCES profiles(id) not valid;

alter table "public"."followers" validate constraint "followers_following_id_fkey";

alter table "public"."followers" add constraint "followers_follower_username_fkey" FOREIGN KEY (follower_username) REFERENCES profiles(username) not valid;

alter table "public"."followers" validate constraint "followers_follower_username_fkey";

alter table "public"."followers" add constraint "followers_following_username_fkey" FOREIGN KEY (following_username) REFERENCES profiles(username) not valid;

alter table "public"."followers" validate constraint "followers_following_username_fkey";

grant delete on table "public"."followers" to "anon";

grant insert on table "public"."followers" to "anon";

grant references on table "public"."followers" to "anon";

grant select on table "public"."followers" to "anon";

grant trigger on table "public"."followers" to "anon";

grant truncate on table "public"."followers" to "anon";

grant update on table "public"."followers" to "anon";

grant delete on table "public"."followers" to "authenticated";

grant insert on table "public"."followers" to "authenticated";

grant references on table "public"."followers" to "authenticated";

grant select on table "public"."followers" to "authenticated";

grant trigger on table "public"."followers" to "authenticated";

grant truncate on table "public"."followers" to "authenticated";

grant update on table "public"."followers" to "authenticated";

grant delete on table "public"."followers" to "service_role";

grant insert on table "public"."followers" to "service_role";

grant references on table "public"."followers" to "service_role";

grant select on table "public"."followers" to "service_role";

grant trigger on table "public"."followers" to "service_role";

grant truncate on table "public"."followers" to "service_role";

grant update on table "public"."followers" to "service_role";


