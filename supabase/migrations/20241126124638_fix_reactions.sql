CREATE POLICY select_reaction
ON public."Review-Reactions"
FOR SELECT
TO authenticated
USING (
    user_id = auth.uid()
);

create policy "Permitir actualizaciones de likes y dislikes"
on "public"."Reviews"
as permissive
for update
to authenticated
using ((id IN ( SELECT "Review-Reactions".review_id
   FROM "Review-Reactions"
  WHERE ("Review-Reactions".user_id = auth.uid()))));

alter type "public"."Reactions" rename to "Reactions__old_version_to_be_dropped";

create type "public"."Reactions" as enum ('like', 'dislike');

alter table "public"."Review-Reactions" alter column reaction type "public"."Reactions" using reaction::text::"public"."Reactions";

drop type "public"."Reactions__old_version_to_be_dropped";