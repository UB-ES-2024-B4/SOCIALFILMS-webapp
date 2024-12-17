CREATE OR REPLACE FUNCTION public.search_profiles(_search_term TEXT)
RETURNS json AS $$
DECLARE
    result json;
BEGIN
    IF _search_term IS NULL OR trim(_search_term) = '' THEN
        RETURN '[]'::json;
    END IF;

    SELECT json_agg(
        json_build_object(
            'id', id,
            'username', username,
            'real_name', real_name,
            'last_name', last_name,
            'bio', bio,
            'country', country
        )
    )
    INTO result
    FROM public.profiles
    WHERE username ILIKE '%' || _search_term || '%'
    LIMIT 10;

    RETURN COALESCE(result, '[]'::json);
END;
$$ LANGUAGE plpgsql;