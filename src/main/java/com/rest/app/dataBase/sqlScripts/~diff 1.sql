DROP INDEX IF EXISTS smfd_data.t_address_hash_code_index RESTRICT;
DROP FUNCTION IF EXISTS smfd_data.get_address_hashcode(smfd_data.T_ADDRESS);
DROP TRIGGER IF EXISTS trg_t_address_insert
    ON smfd_data.t_address;
DROP FUNCTION IF EXISTS smfd_data.trg_func_t_address_insert();
ALTER TABLE smfd_data.t_address
    DROP IF EXISTS hash_code;

CREATE UNIQUE INDEX IF NOT EXISTS t_address_zip_code_region_id_street_type_street_house_corpus_flat_city_id_uindex
    ON smfd_data.t_address (zip_code, region_id, street_type, street, house, corpus, flat, city_id);

DROP FUNCTION IF EXISTS smfd_data.get_address_id(smfd_data.S_ADDRESS);
DROP FUNCTION IF EXISTS smfd_data.get_address_by_id(INT);

DROP INDEX IF EXISTS smfd_data.t_bill_abonent_hash_code_index RESTRICT;
ALTER TABLE smfd_data.t_bill_abonent
    DROP IF EXISTS hash_code;
DROP TRIGGER IF EXISTS trg_t_bill_abonent_insert
    ON smfd_data.t_bill_abonent;
DROP FUNCTION IF EXISTS smfd_data.trg_func_t_bill_abonent_insert();
DROP FUNCTION IF EXISTS smfd_data.get_abonent_hashcode(smfd_data.T_BILL_ABONENT);

CREATE UNIQUE INDEX IF NOT EXISTS t_bill_abonent_full_name_abonent_type_address_abonent_uniq_code_contact_phone_uindex
    ON smfd_data.t_bill_abonent (full_name, abonent_type, address, abonent_uniq_code, contact_phone);

DROP FUNCTION IF EXISTS smfd_data.get_abonent_id(smfd_data.S_ABONENT);
DROP FUNCTION IF EXISTS smfd_data.get_abonent_by_id(INT);

CREATE OR REPLACE FUNCTION smfd_data.get_accounts_by_id(IN pi_period_id INT,
                                                        IN pi_bill_id INT)
    RETURNS smfd_data.S_ACCOUNT
    LANGUAGE plpgsql AS
$$
DECLARE
    account_row             smfd_data.T_BILL_ACCOUNTS_BASE;
    account_object          smfd_data.S_ACCOUNT;
    abonent_object          smfd_data.S_ABONENT;
    p_address_id            INT;
    p_abonent_full_name     TEXT;
    p_abonent_type          INT;
    p_abonent_uniq_code     TEXT;
    p_abonent_contact_phone TEXT;
    address_object          smfd_data.S_ADDRESS;
BEGIN
    SELECT *
    INTO account_row
    FROM smfd_data.t_bill_accounts_base a
    WHERE a.period_id = pi_period_id
      AND a.bill_id = pi_bill_id;

    SELECT abonent.full_name,
           abonent.abonent_type,
           abonent.abonent_uniq_code,
           abonent.contact_phone,
           abonent.address
    INTO p_abonent_full_name, p_abonent_type, p_abonent_uniq_code, p_abonent_contact_phone, p_address_id
    FROM smfd_data.t_bill_abonent abonent
    WHERE abonent.id = account_row.abonent_id;

    SELECT address.zip_code,
           address.region_id,
           city.city_type,
           city.city_name,
           address.street_type,
           address.street,
           address.house,
           address.corpus,
           address.flat
    INTO address_object
    FROM smfd_data.t_address address
             JOIN public.t_city city ON address.city_id = city.id
    WHERE address.id = p_address_id;

    RAISE NOTICE 'add %', address_object;

    abonent_object.full_name := p_abonent_full_name;
    abonent_object.abonent_type := p_abonent_type;
    abonent_object.address := address_object;
    abonent_object.abonent_uniq_code := p_abonent_uniq_code;
    abonent_object.contact_phone := p_abonent_contact_phone;

    IF account_row.id IS NOT NULL
    THEN
        account_object.account_number := account_row.account_number;
        account_object.abonent := abonent_object;
        account_object.details :=
                smfd_data.get_bill_details_by_id(pi_period_id, account_row.id) :: smfd_data.S_BILL_DETAILS[];
        account_object.connect_detainling :=
                smfd_data.get_call_details_by_id(pi_period_id, account_row.id) :: smfd_data.S_BILL_CALL_DETAILS[];
    END IF;

    RETURN account_object;
END;
$$;

/* ------------------------------------------------------------------------------------------------ */
CREATE OR REPLACE FUNCTION smfd_data.save_bills(IN pi_bills smfd_data.S_BILL[],
                                                IN pi_period_id INT,
                                                IN pi_forming_type_id INT,
                                                OUT po_result_code TEXT,
                                                OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    bill               smfd_data.S_BILL;
    account            smfd_data.S_ACCOUNT;
    p_bill_id          INT;
    rec                RECORD;
    last_history_entry INTEGER;
    num_cunter         INT;
    p_city             INT;
    p_address          INT;
    p_abonent          INT;
    p_account_id       INT;
BEGIN
    PERFORM smfd_data_partitions.assert_partition(pi_period_id);

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
                    -- todo пока там, потом можно на чистый sql заменить
                    p_city := public.get_city_id((((account).abonent).address).city_type,
                                                 (((account).abonent).address).city,
                                                 (((account).abonent).address).region_id);

                    -- Получаем идентификатор адреса
                    SELECT address.id
                    INTO p_address
                    FROM smfd_data.t_address address
                    WHERE address.zip_code = (((account).abonent).address).zip_code
                      AND address.region_id = (((account).abonent).address).region_id
                      AND address.street_type = (((account).abonent).address).street_type
                      AND address.street = (((account).abonent).address).street
                      AND address.house = (((account).abonent).address).house
                      AND address.corpus = (((account).abonent).address).corpus
                      AND address.flat = (((account).abonent).address).flat
                      AND address.city_id = p_city;
                    IF (p_address IS NULL)
                    THEN
                        INSERT INTO smfd_data.t_address (zip_code, region_id, street_type, street, house, corpus, flat,
                                                         city_id)
                        VALUES ((((account).abonent).address).zip_code,
                                (((account).abonent).address).region_id,
                                (((account).abonent).address).street_type,
                                (((account).abonent).address).street,
                                (((account).abonent).address).house,
                                (((account).abonent).address).corpus,
                                (((account).abonent).address).flat,
                                p_city)
                        RETURNING id INTO p_address;
                    END IF;

                    -- Получаем идентификатор абонента.
                    SELECT abonent.id
                    INTO p_abonent
                    FROM smfd_data.t_bill_abonent abonent
                    WHERE abonent.full_name = ((account).abonent).full_name
                      AND abonent.abonent_type = ((account).abonent).abonent_type
                      AND abonent.address = p_address
                      AND abonent.abonent_uniq_code = ((account).abonent).abonent_uniq_code
                      AND abonent.contact_phone = ((account).abonent).contact_phone;

                    IF (p_abonent IS NULL)
                    THEN
                        INSERT INTO smfd_data.t_bill_abonent (full_name, abonent_type, address, abonent_uniq_code, contact_phone)
                        VALUES (((account).abonent).full_name,
                                ((account).abonent).abonent_type,
                                p_address,
                                ((account).abonent).abonent_uniq_code,
                                ((account).abonent).contact_phone)
                        RETURNING id INTO p_abonent;
                    END IF;

                    -- записываем ЛС
                    INSERT INTO smfd_data.t_bill_accounts_base (period_id, bill_id, abonent_id, account_number)
                    VALUES (pi_period_id,
                            p_bill_id,
                            p_abonent,
                            account.account_number)
                    RETURNING id INTO p_account_id;

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
                    FROM unnest(account.details) x;

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
                    FROM unnest(account.connect_detainling) x;

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
