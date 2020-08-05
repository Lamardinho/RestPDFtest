CREATE TABLE IF NOT EXISTS public.t_sdp_log
(
    id        SERIAL PRIMARY KEY                  NOT NULL,
    region_id INT                                 NOT NULL,
    url       VARCHAR(512)                        NOT NULL,
    date      TIMESTAMP DEFAULT current_timestamp NOT NULL,
    status    INT                                 NOT NULL
);
COMMENT ON TABLE public.t_audit_log IS 'Логи информирования sdp-системы о публикации региона';

/* Сохранение истории оповещания сдп-систем о публикации */
CREATE OR REPLACE FUNCTION public.save_sdp_log(IN pi_region INT, /* id региона */
                                               IN pi_url TEXT, /* ip адрес */
                                               IN pi_date TIMESTAMP, /* дата */
                                               IN pi_status INT, /* статус */
                                               OUT po_result_code TEXT, /* Код */
                                               OUT po_result_message TEXT /* Сообщение */
)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO public.t_sdp_log (region_id, url, date, status)
    VALUES (pi_region, pi_url, pi_date, pi_status);

    po_result_code := 0;
    po_result_message := 'ok';
    RETURN;

EXCEPTION
    WHEN OTHERS
        THEN DECLARE
            exception_diag TEXT;
        BEGIN
            GET STACKED DIAGNOSTICS exception_diag = PG_EXCEPTION_CONTEXT;
            po_result_code := SQLSTATE;
            po_result_message := SQLERRM || ' CTX:' || exception_diag;
            PERFORM public.exception_log(SQLSTATE, SQLERRM, exception_diag);
            RETURN;
        END;
END;
$$;