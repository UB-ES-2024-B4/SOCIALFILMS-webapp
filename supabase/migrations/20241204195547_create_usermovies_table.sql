CREATE TABLE public."User-Movies" (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY, -- ID único
    user_id UUID NOT NULL,                        -- ID del usuario
    movie_id INT NOT NULL,                      -- ID de la pelicula

    -- Restricción: Un usuario no puede dar like a una pelicula mas de una vez
    CONSTRAINT unique_user_like_movie UNIQUE (user_id, movie_id),
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);
ALTER TABLE public."User-Movies" ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_access_policy
ON public."User-Movies"
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

