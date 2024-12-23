CREATE OR REPLACE FUNCTION public.add_report(
    _review_id UUID,
    _reason report_reason_enum,
    _other_reason VARCHAR(254) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar que, si el motivo es 'Otros', el campo other_reason no esté vacío
    IF _reason = 'Otros' AND (_other_reason IS NULL OR LENGTH(_other_reason) = 0) THEN
        RAISE EXCEPTION 'El motivo "Otros" requiere una descripción';
    END IF;

    -- Insertar el reporte
    INSERT INTO public."Report" (user_id, review_id, reason, other_reason)
    VALUES (auth.uid(), _review_id, _reason, _other_reason);
END;
$$;

CREATE OR REPLACE FUNCTION public.delete_report(
    _review_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Eliminar el reporte del usuario actual sobre la review
    DELETE FROM public."Report"
    WHERE user_id = auth.uid()
      AND review_id = _review_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_reports_for_review(
    _review_id UUID
)
RETURNS TABLE(
    user_id UUID,
    reason report_reason_enum,
    other_reason VARCHAR(254),
    created_at TIMESTAMP
)
LANGUAGE sql
AS $$
    SELECT user_id, reason, other_reason, created_at
    FROM public."Report"
    WHERE review_id = _review_id;
$$;

CREATE OR REPLACE FUNCTION notify_report_insert()
RETURNS trigger AS
$$
BEGIN
  -- Enviar notificación HTTP a la Edge Function (URL de la función)
  PERFORM http_post(
    'https://jxbspkcbkgmtnrvylrqa.supabase.co/functions/v1/send-mail',  -- URL de tu función Edge
    json_build_object(
      'user_id', NEW.user_id,
      'review_id', NEW.review_id,
      'motivo', NEW.reason,
      'motivo_ad', COALESCE(NEW.other_reason, '')
    )::text,
    'Content-Type: application/json'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER report_insert_trigger
AFTER INSERT ON public."Report"
FOR EACH ROW
EXECUTE FUNCTION notify_report_insert();