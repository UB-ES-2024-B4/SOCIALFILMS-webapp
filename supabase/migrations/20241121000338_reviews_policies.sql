CREATE POLICY select_reviews
ON public."Reviews"
FOR SELECT
TO authenticated, anon
USING (TRUE);

