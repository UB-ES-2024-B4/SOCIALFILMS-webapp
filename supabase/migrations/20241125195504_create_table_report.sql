DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'report_reason_enum') THEN
        DROP TYPE report_reason_enum;
    END IF;

    CREATE TYPE report_reason_enum AS ENUM (
        'Contenido Ofensivo',
        'Spam',
        'Desinformación',
        'Otros'
    );
END $$;

CREATE TABLE public."Report" (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY, -- ID único para cada reporte
    user_id UUID NOT NULL,                        -- ID del usuario que reporta
    review_id UUID NOT NULL,                      -- ID de la review reportada
    reason report_reason_enum NOT NULL,           -- Motivo predefinido
    other_reason VARCHAR(254),                   -- Texto personalizado para "Otros"
    created_at TIMESTAMP DEFAULT NOW(),          -- Fecha de creación del reporte

    -- Restricción: Un usuario no puede reportar la misma review más de una vez
    CONSTRAINT unique_user_review_report UNIQUE (user_id, review_id),

    -- Restricción: Cuando 'reason' sea 'Otros', 'other_reason' debe estar relleno
    CONSTRAINT check_other_reason CHECK (
        (reason != 'Otros' OR (other_reason IS NOT NULL AND LENGTH(other_reason) > 0))
    )
);

ALTER TABLE public."Report"
ADD CONSTRAINT report_user_id_fkey FOREIGN KEY (user_id)
REFERENCES auth.users (id) ON DELETE CASCADE;

ALTER TABLE public."Report"
ADD CONSTRAINT report_review_id_fkey FOREIGN KEY (review_id)
REFERENCES public."Reviews" (id) ON DELETE CASCADE;