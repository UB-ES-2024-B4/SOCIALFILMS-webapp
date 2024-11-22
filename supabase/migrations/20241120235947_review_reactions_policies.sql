CREATE POLICY insert_reaction
ON public."Review-Reactions"
FOR INSERT
TO authenticated
WITH CHECK (
    review_id IS DISTINCT FROM ALL (
        SELECT review_id
        FROM public."Review-Reactions"
        WHERE user_id = auth.uid()
    )
);

CREATE POLICY update_reaction
ON public."Review-Reactions"
FOR UPDATE
TO authenticated
USING (
    user_id = auth.uid()
);

CREATE POLICY delete_reaction
ON public."Review-Reactions"
FOR DELETE
TO authenticated
USING (
    user_id = auth.uid()
);

