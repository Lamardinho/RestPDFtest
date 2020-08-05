/* Использовалась раньше для получения статистики (не используется) */
CREATE OR REPLACE FUNCTION smfd_data.get_bills_stats(IN pi_period_id INT, /*  */
                                                     IN pi_forming_type_id INT, /*  */
                                                     IN pi_region_id INT, /*  */

                                                     OUT po_bills_with_email INT, /*  */
                                                     OUT po_bills_wo_email INT, /*  */
                                                     OUT po_last_load_date TIMESTAMP, /*  */
                                                     OUT po_user_name TEXT, /*  */

                                                     OUT po_result_code TEXT,
                                                     OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    _isEmail BOOL;
    _count   INT;
BEGIN
    po_bills_with_email := 0;
    po_bills_wo_email := 0;

    FOR _isEmail, _count, po_last_load_date, po_user_name IN (
        SELECT raw.is_delivery_type_email,
               count(bill_id),
               module__utils.first(raw.last_load_date),
               module__utils.first(raw.user_name)
        FROM (
                 SELECT bill_row.id             bill_id,
                        CASE bill_row.delivery_type
                            WHEN 12
                                THEN TRUE
                            ELSE FALSE END      is_delivery_type_email,
                        task.status_change_date last_load_date,
                        us.last_name || ' ' || substr(us.first_name, 1, 1) || '.' || substr(us.middle_name, 1, 1) ||
                        '.'                     user_name
                 FROM smfd_data.t_bill_base bill_row
                          LEFT OUTER JOIN smfd_task_manager.t_task task ON task.id = bill_row.history_entry
                          LEFT OUTER JOIN smfd_user.t_user us ON task.task_initiator = us.id
                 WHERE bill_row.period_id = pi_period_id
                   AND bill_row.region_id = pi_region_id
                   AND bill_row.forming_type = pi_forming_type_id
                   AND (task.task_status IN (2, 3) OR task.id IS NULL)
                 ORDER BY (bill_row.delivery_type = 12) DESC, task.status_change_date DESC
             ) raw
        GROUP BY raw.is_delivery_type_email
    )
        LOOP
            IF (_isEmail)
            THEN
                po_bills_with_email := _count;
            ELSE
                po_bills_wo_email := _count;
            END IF;
        END LOOP;

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
