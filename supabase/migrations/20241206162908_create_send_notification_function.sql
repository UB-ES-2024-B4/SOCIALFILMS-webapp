alter table "public"."notifications" add column "receiver_username" text not null;

alter table "public"."notifications" add column "sender_username" text not null;

alter table "public"."notifications" add constraint "notifications_receiver_username_fkey" FOREIGN KEY (receiver_username) REFERENCES profiles(username) not valid;

alter table "public"."notifications" validate constraint "notifications_receiver_username_fkey";

alter table "public"."notifications" add constraint "notifications_sender_username_fkey" FOREIGN KEY (sender_username) REFERENCES profiles(username) not valid;

alter table "public"."notifications" validate constraint "notifications_sender_username_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.send_notification(_receiver_username text, _movie_id integer)
 RETURNS json
 LANGUAGE plpgsql
AS $function$DECLARE
  _receiver_id UUID;
  _sender_id UUID;
  _sender_username TEXT;
  existing_notification_count int2;
BEGIN
  -- get sender user id and username
  SELECT auth.uid() INTO _sender_id;
  SELECT username INTO _sender_username FROM public.profiles WHERE id = _sender_id;
  -- get receiver user id
  SELECT id INTO _receiver_id FROM public.profiles WHERE username = _receiver_username;

  -- Check if username does not exist
  IF _receiver_id IS NULL THEN
    RAISE EXCEPTION 'User % does not exist', _receiver_username
    USING ERRCODE = 'F0002';
  END IF;

  -- Prevent users send notifications to themselves
  IF _sender_id = _receiver_id THEN
    RAISE EXCEPTION 'A user cannot send notifications to themselves'
    USING ERRCODE = 'F0003';
  END IF;

  -- Check if the notification already exists
  SELECT COUNT(*)
  INTO existing_notification_count
  FROM public.notifications
  WHERE sender_id = _sender_id
    AND receiver_id = _receiver_id
    AND movie_id = _movie_id;

  IF existing_notification_count > 0 THEN
    RAISE EXCEPTION 'Notification for this movie already sent by % to %', _sender_username, _receiver_username
    USING ERRCODE = 'F0004';
  END IF;

  -- Check if sender and receiver are mutually following each other
  IF NOT EXISTS (
    SELECT 1
    FROM public.followers
    WHERE follower_id = _sender_id
      AND following_id = _receiver_id
  ) OR NOT EXISTS (
    SELECT 1
    FROM public.followers
    WHERE follower_id = _receiver_id
      AND following_id = _sender_id
  ) THEN
    RAISE EXCEPTION 'Sender and receiver must be mutually following each other to send notifications'
    USING ERRCODE = 'F0005';
  END IF;

  -- Insert the follow relationship
  INSERT INTO public.notifications (created_at, sender_id, receiver_id, movie_id, is_read, sender_username, receiver_username)
  VALUES (NOW(), _sender_id, _receiver_id, _movie_id, false, _sender_username, _receiver_username);

  -- If successful, return a success message
  RETURN json_build_object(
    'success', TRUE,
    'message', 'Notification created successfully'
  );

END;$function$
;

create policy "Enable insert for authenticated users only"
on "public"."notifications"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for all users"
on "public"."notifications"
as permissive
for select
to public
using (true);

create policy "Enable delete for users based on receiver_id"
on "public"."notifications"
as permissive
for delete
to public
using ((( SELECT auth.uid() AS uid) = receiver_id));

