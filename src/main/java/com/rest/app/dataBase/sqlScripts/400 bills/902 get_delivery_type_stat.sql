/* Получение количества счетов по определенным типам доставки */
CREATE OR REPLACE FUNCTION smfd_data.get_delivery_type_stat(IN pi_period_id INT, /* период */
                                                            IN pi_forming_type_id INT, /* тип формирования */
                                                            IN pi_region_id INT, /* регион */

                                                            OUT po_delivery_type_stat refcursor, /* Курсор с результатом */

                                                            OUT po_result_code TEXT,
                                                            OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN po_delivery_type_stat FOR
        SELECT dt.id         as delivery_type,
               DT.dt_code       dt_code,
               sum(bs.count) as count
        FROM smfd_data.t_bill_statistic bs
                 JOIN smfd_data.t_delivery_type DT on bs.delivery_type_id = DT.id
                 JOIN td_region REG ON REG.region_id = bs.region_id
                 JOIN smfd_data.t_forming_type ft on bs.forming_type_id = ft.id
        WHERE bs.period_id = pi_period_id
          AND bs.forming_type_id = pi_forming_type_id
          AND REG.region_id = pi_region_id
          AND (
                pi_forming_type_id > 100
                OR (bs.delivery_type_id not in (1, 2) AND pi_forming_type_id < 100)
                OR (ft.mrf_id = 6 AND pi_forming_type_id < 100)
            )
        GROUP BY dt.id, dt.dt_code;

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