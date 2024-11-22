CREATE POLICY insert_reaction
ON public."Review-Reactions"
FOR INSERT
TO authenticated
WITH CHECK (
    NOT EXISTS (
        SELECT 1
        FROM public."Review-Reactions"
        WHERE user_id = auth.uid() AND review_id = NEW.review_id
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

