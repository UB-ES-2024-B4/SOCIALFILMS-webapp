CREATE OR REPLACE FUNCTION public.get_mutual_followers(_username text)
RETURNS json
LANGUAGE plpgsql
AS $function$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(row_to_json(m))
  INTO result
  FROM (
    SELECT 
      f1.following_id,
      f1.following_username,
      f1.followed_at
    FROM public.followers f1
    INNER JOIN public.followers f2 ON 
      f1.following_username = f2.follower_username AND 
      f1.follower_username = f2.following_username
    WHERE f1.follower_username = _username
  ) m;

  IF result IS NULL THEN
    RETURN json_build_object(
      'success', TRUE,
      'message', 'No mutual followers found',
      'data', '[]'::JSON
    );
  END IF;

  RETURN json_build_object(
    'success', TRUE,
    'message', 'Mutual followers retrieved successfully',
    'data', result
  );
END;
$function$;

CREATE POLICY "Permitir actualizar notificaciones"
ON public.notifications
FOR UPDATE
TO authenticated
USING (auth.uid() = receiver_id)
WITH CHECK (auth.uid() = receiver_id);