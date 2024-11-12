drop policy "Usuarios pueden crear reseñas" on "public"."Reviews";

create policy "Enable insert for authenticated users only"
on "public"."Reviews"
as permissive
for insert
to authenticated
with check (true);



