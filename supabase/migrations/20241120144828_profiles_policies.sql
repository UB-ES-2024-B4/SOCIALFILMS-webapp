create policy "Enable delete for users based on user_id"
on "public"."profiles"
as permissive
for delete
to public
using ((( SELECT auth.uid() AS uid) = id));


create policy "Enable insert for authenticated users only"
on "public"."profiles"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for all users"
on "public"."profiles"
as permissive
for select
to public
using (true);


create policy "Enable update for users based on id"
on "public"."profiles"
as permissive
for update
to public
using ((( SELECT auth.uid() AS uid) = id));



