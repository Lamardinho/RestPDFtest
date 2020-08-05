/* Получение списка с информацие о счетах за определенный период */
CREATE OR REPLACE FUNCTION smfd_data.get_bill_list_by_account(IN pi_account_number TEXT, /* лс */
                                                              IN pi_date_from DATE DEFAULT NULL, /* дата от */
                                                              IN pi_date_to DATE DEFAULT NULL, /* дата до */
                                                              OUT po_bill_list REFCURSOR, /* информация о биллах за период */
                                                              OUT po_result_code TEXT,
                                                              OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN po_bill_list FOR
        SELECT bill.id            bill_id,
               bill.number        bill_number,
               bill.bill_date     bill_date,
               bill.target_date   bill_target_date,
               bill.deadline_date bill_deadline_date,
               bill.total_pay     bill_total_pay,
               bill.period_id     period_id,
               acc.account_number account_number,
               acc.abonent_id     abonent_id,
               reg.region_id      region_id,
               reg.mrf_id         mrf_id,
               reg.region_name    region_name,
               reg.region_code    region_code
        FROM smfd_data.t_bill_accounts_base acc
                 JOIN smfd_data.t_bill_base bill ON bill.period_id = acc.period_id AND bill.id = acc.bill_id
                 JOIN public.td_region reg ON reg.region_id = bill.region_id
                 JOIN smfd_data.t_bill_publish_status PS ON PS.region_id = bill.region_id AND
                                                            PS.period_id = bill.period_id AND
                                                            PS.forming_type_id = bill.forming_type
        WHERE acc.account_number = pi_account_number
          AND PS.status = 1
          AND (
            bill.target_date BETWEEN
                CASE
                    WHEN pi_date_from IS NULL THEN '1900-01-01' :: DATE
                    ELSE pi_date_from
                    END AND
                CASE
                    WHEN pi_date_to IS NULL THEN '3000-01-01' :: DATE
                    ELSE pi_date_to
                    END
            );

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

/* Получение списка счетов по номеру ЛС */
CREATE OR REPLACE FUNCTION smfd_data.get_account_bills(IN pi_account_number TEXT, /* ЛС */
                                                       OUT po_bill_list REFCURSOR, /* Курсор с списком счетов */
                                                       OUT po_orders_list REFCURSOR, /* Курсор со списком заказов */
                                                       OUT po_result_code TEXT,
                                                       OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN po_bill_list FOR
        SELECT bill.id             bill_id,
               bill.number         bill_number,
               bill.bill_date      bill_date,
               bill.target_date    bill_target_date,
               bill.period_id      period_id,
               bp.date             period_data,
               bill.email          email,
               bill.delivery_type  dt_id,
               dt.dt_code          delivery_type,
               acc.account_number  account_number,
               acc.abonent_id      abonent_id,
               reg.region_id       region_id,
               reg.mrf_id          mrf_id,
               reg.region_name     region_name,
               reg.region_code     region_code,
               PS.status_change_dt pub_date,
               fpd.send_status,
               fpd.change_status_date,
               fpd.email           delivery_email
        FROM smfd_data.t_bill_accounts_base acc
                 JOIN smfd_data.t_bill_base bill ON bill.period_id = acc.period_id AND bill.id = acc.bill_id
                 JOIN public.td_region reg ON reg.region_id = bill.region_id
                 JOIN smfd_data.t_billing_period bp on bill.period_id = bp.id
                 LEFT JOIN smfd_data.t_forming_publishing_details_base fpd
                           on fpd.bill_id = bill.id AND fpd.period_id = bill.period_id
                 left JOIN smfd_data.t_delivery_type dt on dt.id = bill.delivery_type
                 left JOIN smfd_data.t_bill_publish_status PS ON PS.region_id = bill.region_id AND
                                                                 PS.period_id = bill.period_id AND
                                                                 PS.forming_type_id = bill.forming_type
        WHERE acc.account_number = pi_account_number
          AND PS.status = 1;

    open po_orders_list for
        select tsk.id,
               tsk.task_status,
               tsk.status_change_date,
               dt.dt_code as  delivery_type,
               p1.param_value bill_id,
               p2.param_value email,
               ords.source_id,
               bp.date    as  period_data
        from smfd_task_manager.t_task tsk
                 LEFT join smfd_task_manager.t_task_params p1 on p1.task_id = tsk.id and p1.param_key = 'docXaId'
                 LEFT join smfd_task_manager.t_task_params p2 on p2.task_id = tsk.id and p2.param_key = 'email'
                 LEFT join smfd_data.t_bill_base bill on bill.id = to_number(p1.param_value, '999999999999')
                 LEFT join smfd_data.t_bill_accounts_base acc on acc.bill_id = bill.id
                 LEFT JOIN smfd_data.t_delivery_type dt on dt.id = bill.delivery_type
                 JOIN smfd_data.t_billing_period bp on bill.period_id = bp.id
                 LEFT JOIN smfd_task_manager.t_task_m2m_report ords on ords.task_id = tsk.id
        where tsk.task_type = 30
          and acc.account_number = pi_account_number
        order BY tsk.status_change_date;

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
