/* ------------------------------------------------------------------------------------------------ */
DROP FUNCTION IF EXISTS smfd_data.save_bills(smfd_data.s_bill[], INT, INT);
/* Сохранение распарсенных биллов в БД */
CREATE OR REPLACE FUNCTION smfd_data.save_bills(IN pi_bills smfd_data.S_BILL[], /* Массив входных данных-биллов */
                                                IN pi_period_id INT, /* Id периода */
                                                IN pi_forming_type_id INT, /* Id типа формирования */
                                                OUT po_count_bill INT, /* Кол-во счетов успешно загруженных в БД */
                                                OUT po_delivery_stat VARCHAR[], /* Массив типов доставки для подсчета статистики */
                                                OUT po_account_stat INT[], /* Массив для подсчета статистики (Account) */
                                                OUT po_client_stat INT[], /* Массив для подсчета статистики (Client) */
                                                OUT po_email_acc INT[], /* Массив для подсчета статистики (email_acc) */
                                                OUT po_site_acc INT[], /* Массив для подсчета статистики (site_acc) */
                                                OUT po_result_code TEXT, /* Код */
                                                OUT po_result_message TEXT /* Сообщение */
)
    RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    bill               smfd_data.S_BILL;
    account            smfd_data.S_ACCOUNT;
    p_bill_id          INT;
    last_history_entry INTEGER;
    num_cunter         INT;
    p_abonent          INT;
    p_account_id       INT;
    p_count            INT DEFAULT 0;
    l_delivery_stat    TEXT[] DEFAULT '{}';
    l_account_stat     INT[] DEFAULT '{}';
    l_client_stat      INT[] DEFAULT '{}';
    l_email_acc        INT[] DEFAULT '{}';
    l_site_acc         INT[] DEFAULT '{}';

BEGIN
    PERFORM smfd_data_partitions.assert_partition(pi_period_id);
    p_count := 0;

    FOREACH bill IN ARRAY pi_bills
        LOOP
            last_history_entry := bill.history_entry;
            -- Добавляем сам счёт в базу партиции
            BEGIN
                INSERT INTO smfd_data.t_bill_base (period_id, number, bill_date, target_date, deadline_date, total_pay,
                                                   total_pay_recommended,
                                                   qr_code, barcode_common, barcode_recommended, vendor, history_entry,
                                                   delivery_type, email,
                                                   region_id, additional_params, forming_type, bill_type)
                VALUES (pi_period_id, coalesce(bill.number), bill.bill_date, bill.target_date, bill.deadline_date,
                        bill.total_pay,
                        bill.total_pay_recommended, bill.qr_code, bill.barcode_common, bill.barcode_recommended,
                        smfd_data.get_vendor_id(bill.vendor), bill.history_entry,
                        smfd_data.get_delivery_type_id(bill.delivery_type), bill.email,
                        bill.accounts[1].abonent.address.region_id, -- считаем, что ЛС хотя бы один всегда есть
                        bill.additional_parameters, pi_forming_type_id, coalesce(bill.bill_type, 1))
                RETURNING id INTO p_bill_id;
                p_count := p_count + 1;
                l_delivery_stat := array_append(l_delivery_stat, bill.delivery_type);
            EXCEPTION
                WHEN integrity_constraint_violation
                    THEN
                        po_result_message := po_result_message || ' CONSTRAINT_BILL=' || coalesce(bill.number);
                        CONTINUE;
            END;

            -- каждая строка информации о платежах
            INSERT INTO smfd_data.t_bill_pay_base (period_id, bill_id, pay_type, pay_line_name, pay_saldo, pay_income,
                                                   pay_invoice, pay_total, pay_prepaid, pay_deferred)
            SELECT pi_period_id      period_id,
                   p_bill_id         bill_id,
                   (x).pay_type      pay_type,
                   (x).pay_line_name pay_line_name,
                   (x).pay_saldo     pay_saldo,
                   (x).pay_income    pay_income,
                   (x).pay_invoice   pay_invoice,
                   (x).pay_total     pay_total,
                   (x).pay_prepaid   pay_prepaid,
                   (x).pay_deferred  pay_deferred
            FROM unnest(bill.pays) x;

            num_cunter := 0;
            FOREACH account IN ARRAY bill.accounts
                LOOP
                    p_abonent := smfd_data.get_abonent_id((account).abonent);
                    l_client_stat := l_client_stat || p_abonent;
                    IF (pi_forming_type_id = 50) THEN
                        CASE bill.delivery_type
                            WHEN 'email_acc' THEN l_email_acc := l_email_acc || p_abonent;
                            WHEN 'site_acc' THEN l_site_acc := l_site_acc || p_abonent;
                            END CASE;
                    END IF;

                    -- записываем ЛС
                    INSERT INTO smfd_data.t_bill_accounts_base (period_id, bill_id, abonent_id, account_number)
                    VALUES (pi_period_id, p_bill_id, p_abonent, (account).account_number)
                    RETURNING id INTO p_account_id;
                    l_account_stat := l_account_stat || p_account_id;

                    -- Каждая строка детализации счёта для полученного ЛСа.
                    INSERT INTO smfd_data.t_bill_details_base (period_id, account_id, service_number, service_type,
                                                               detail_name,
                                                               priority_order, quantity, quantity_unit, detail_sum)
                    SELECT pi_period_id       period_id,
                           p_account_id       account_id,
                           (x).service_number service_number,
                           (x).service_type   service_type,
                           (x).detail_name    detail_name,
                           (x).priority_order priority_order,
                           (x).quantity       quantity,
                           (x).quantity_unit  quantity_unit,
                           (x).detail_sum     detail_sum
                    FROM unnest((account).details) x;

                    -- Каждая строка детализации соединения для полученного ЛСа.
                    INSERT INTO smfd_data.t_bill_call_details_base (period_id, account_id, service_number, tariff_name,
                                                                    stat_date, service_subtype,
                                                                    vendor_id, connect_type, connect_period,
                                                                    connect_cost, connect_code)
                    SELECT pi_period_id        period_id,
                           p_account_id        account_id,
                           (x).service_number  service_number,
                           (x).tariff_name     tariff_name,
                           (x).stat_date       stat_date,
                           (x).service_subtype service_subtype,
                           (x).vendor_id       vendor_id,
                           (x).connect_type    connect_type,
                           (x).connect_period  connect_period,
                           (x).connect_cost    connect_cost,
                           (x).connect_code    connect_code
                    FROM unnest((account).connect_detainling) x;

                    -- От первого ЛС берем регион и ставим биллу. Оптимайз.
                    IF (num_cunter = 0)
                    THEN
                        UPDATE smfd_data.t_bill_base
                        SET region_id = (((account).abonent).address).region_id
                        WHERE period_id = pi_period_id
                          AND id = p_bill_id;
                    END IF;

                    num_cunter := num_cunter + 1;
                END LOOP;

        END LOOP;

    po_count_bill := p_count;
    po_delivery_stat := l_delivery_stat;
    po_account_stat := l_account_stat;
    po_client_stat := l_client_stat;
    po_email_acc := l_email_acc;
    po_site_acc := l_site_acc;

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
            po_result_message := SQLERRM || ' BILL_NUMBER=' || coalesce(bill.number, 'null') || ' TASK: ' ||
                                 last_history_entry || ' CTX:' || exception_diag;
            PERFORM public.exception_log(SQLSTATE, po_result_message, exception_diag);
            RETURN;
        END;
END;
$$;

