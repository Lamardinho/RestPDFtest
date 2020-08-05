/* Получение данных о счете для формирования*/
CREATE OR REPLACE FUNCTION smfd_data.get_bills_by_filter(IN pi_region_id INT/*              		Идентификатор региона. Он же кладр. */,
                                                         IN pi_period_id INT/* 		            Идентификатор периода. */,
                                                         IN pi_forming_type INT/* 		            Тип формирования. Влияет на присоединенную рекламу. */,
                                                         IN pi_test_forming_count INT DEFAULT NULL/* 		Количество случайных счетов для тестового формирования*/,
                                                         IN pi_bill_ids BIGINT[] DEFAULT NULL/* 	Список конкретных счетов. При указании - предыдущие 4 поля игнорируются. */,
                                                         OUT po_bills REFCURSOR/*        		Курсор результата (bill_id::int, bill:smfd_data.s_bill, targeting::s_key_value_pair[]) */,
                                                         OUT po_result_code TEXT/*             		Результат операции. */,
                                                         OUT po_result_message TEXT/*             		Сообщение ошибки. */
) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    time_log DOUBLE PRECISION;
BEGIN
    RAISE NOTICE 'Starting smfd_data.get_bills_by_filter... ';

    -- В рамках одной сессии вряд ли будут запущены две функции. Просто сносим временные таблицы.
    DROP TABLE IF EXISTS tmp_bill_by_filter_raw;
    DROP TABLE IF EXISTS tmp_bill_by_filter_bills;
    DROP TABLE IF EXISTS tmp_bill_by_filter_accounts_raw;
    DROP TABLE IF EXISTS tmp_bill_by_filter_accounts_details;
    DROP TABLE IF EXISTS tmp_bill_by_filter_accounts;
    DROP TABLE IF EXISTS tmp_bill_by_filter_bill_objects;

    time_log := extract(EPOCH FROM clock_timestamp());

    -- Выделяем подходящие по периоду и региону счета в отдельную таблицу, чтобы была возможность навесить ПК и индексы.
    CREATE TEMPORARY TABLE tmp_bill_by_filter_raw WITH (OIDS = FALSE)
                                                  ON COMMIT DROP AS
    SELECT bill_row.*
    FROM smfd_data.t_bill_base bill_row
    WHERE (
            pi_bill_ids IS NOT NULL
            AND bill_row.id = ANY (pi_bill_ids)
        )
       OR (
              pi_bill_ids IS NULL
              )
        AND bill_row.period_id = pi_period_id
        AND bill_row.region_id = pi_region_id
        AND bill_row.forming_type = pi_forming_type
        AND (pi_test_forming_count IS NOT NULL OR
             (bill_row.delivery_type = 6 OR bill_row.delivery_type = 10))
    ORDER BY CASE
                 WHEN pi_test_forming_count IS NULL OR pi_test_forming_count = 0 OR pi_bill_ids IS NOT NULL
                     THEN NULL :: INT
                 ELSE random() END
    LIMIT CASE
              WHEN pi_test_forming_count IS NULL OR pi_test_forming_count = 0 OR pi_bill_ids IS NOT NULL
                  THEN NULL :: INT
              ELSE pi_test_forming_count END;
    ALTER TABLE tmp_bill_by_filter_raw
        ADD CONSTRAINT tmp_bill_by_filter_pk PRIMARY KEY (id),
        ADD CONSTRAINT tmp_bill_by_filter_uk UNIQUE (id);
    CREATE INDEX tmp_bill_id_index ON tmp_bill_by_filter_raw (id);

    RAISE NOTICE 'filter bills: % sec', (extract(EPOCH FROM clock_timestamp()) - time_log);
    time_log := extract(EPOCH FROM clock_timestamp());

    -- Присоединяем детализацию платежки к сырым отфильтрованным счетам. Дальше используем эту таблицу как базу.
    CREATE TEMPORARY TABLE tmp_bill_by_filter_bills WITH (OIDS = FALSE)
                                                    ON COMMIT DROP AS (
        SELECT bill_row.*,
               array_agg(DISTINCT (bill_pay.pay_type,
                                   bill_pay.pay_line_name,
                                   bill_pay.pay_saldo,
                                   bill_pay.pay_income,
                                   bill_pay.pay_invoice,
                                   bill_pay.pay_total,
                                   bill_pay.pay_prepaid,
                                   bill_pay.pay_deferred) :: smfd_data.S_BILL_PAY) bill_pays
        FROM tmp_bill_by_filter_raw bill_row
                 JOIN smfd_data.t_bill_pay_base bill_pay ON bill_pay.bill_id = bill_row.id
        GROUP BY bill_row.id
    );
    ALTER TABLE tmp_bill_by_filter_bills
        ADD PRIMARY KEY (id);

    RAISE NOTICE 'making temp bills: % sec', (extract(EPOCH FROM clock_timestamp()) - time_log);
    time_log := extract(EPOCH FROM clock_timestamp());

    -- Присоединяем ЛСы в отдельную таблицу, чтобы была возможность навесить ПК.
    CREATE TEMPORARY TABLE tmp_bill_by_filter_accounts_raw WITH (OIDS = FALSE)
                                                           ON COMMIT DROP AS (
        SELECT acc.*
        FROM tmp_bill_by_filter_bills bills
                 JOIN smfd_data.t_bill_accounts_base acc ON acc.bill_id = bills.id
    );
    ALTER TABLE tmp_bill_by_filter_accounts_raw
        ADD PRIMARY KEY (id);

    RAISE NOTICE 'making temp accoutns: % sec', (extract(EPOCH FROM clock_timestamp()) - time_log);
    time_log := extract(EPOCH FROM clock_timestamp());

    -- Грузим и аггрегируем детали ЛСа в отдельную таблицу, попутно превращая в UDT. Дальше используем эта таблицу как базу для ЛСов.
    CREATE TEMPORARY TABLE tmp_bill_by_filter_accounts_bill_details WITH (OIDS = FALSE)
                                                                    ON COMMIT DROP AS (
        SELECT acc.id                             account_id,
               array_agg((
                          bill_details.service_number,
                          bill_details.service_type,
                          bill_details.detail_name,
                          bill_details.priority_order,
                          bill_details.quantity,
                          bill_details.quantity_unit,
                          bill_details.detail_sum
                   ) :: smfd_data.S_BILL_DETAILS) bill_details
        FROM tmp_bill_by_filter_accounts_raw acc
                 LEFT JOIN smfd_data.t_bill_details_base bill_details ON bill_details.account_id = acc.id
        GROUP BY acc.id
    );
    ALTER TABLE tmp_bill_by_filter_accounts_bill_details
        ADD PRIMARY KEY (account_id);

    CREATE TEMPORARY TABLE tmp_bill_by_filter_accounts_details WITH (OIDS = FALSE)
                                                               ON COMMIT DROP AS (
        SELECT details.account_id                      account_id,
               details.bill_details                    bill_details,
               array_agg((
                          call_details.service_number,
                          call_details.tariff_name,
                          call_details.stat_date,
                          call_details.service_subtype,
                          call_details.vendor_id,
                          call_details.connect_type,
                          call_details.connect_period,
                          call_details.connect_cost,
                          call_details.connect_code
                   ) :: smfd_data.S_BILL_CALL_DETAILS) call_details
        FROM tmp_bill_by_filter_accounts_bill_details details
                 LEFT JOIN smfd_data.t_bill_call_details_base call_details
                           ON call_details.account_id = details.account_id
        GROUP BY details.account_id, details.bill_details
    );
    ALTER TABLE tmp_bill_by_filter_accounts_details
        ADD PRIMARY KEY (account_id);

    RAISE NOTICE 'aggregating account details: % sec', (extract(EPOCH FROM clock_timestamp()) - time_log);
    time_log := extract(EPOCH FROM clock_timestamp());

    -- Собираем полноценные массивы ЛСов сбитым по номеру счёта.
    CREATE TEMPORARY TABLE tmp_bill_by_filter_accounts WITH (OIDS = FALSE)
                                                       ON COMMIT DROP AS (
        SELECT DISTINCT ON (acc.bill_id) acc.bill_id                         bill_id,
                                         array_agg(DISTINCT (
                                                             acc.account_number,
                                                             (
                                                              abonent.full_name,
                                                              abonent.abonent_type,
                                                              (
                                                               address.zip_code,
                                                               address.region_id,
                                                               city.city_type,
                                                               city.city_name,
                                                               address.street_type,
                                                               address.street,
                                                               address.house,
                                                               address.corpus,
                                                               address.flat
                                                                  ) :: smfd_data.S_ADDRESS,
                                                              abonent.abonent_uniq_code,
                                                              abonent.contact_phone
                                                                 ) :: smfd_data.S_ABONENT,
                                                             acc_details.bill_details :: smfd_data.S_BILL_DETAILS[],
                                                             acc_details.call_details :: smfd_data.S_BILL_CALL_DETAILS[]
                                             ) :: smfd_data.S_ACCOUNT)       account_objects,
                                         array_agg(DISTINCT address.city_id) city_ids
        FROM tmp_bill_by_filter_accounts_raw acc
                 LEFT JOIN tmp_bill_by_filter_accounts_details acc_details ON acc_details.account_id = acc.id
                 JOIN smfd_data.t_bill_abonent abonent ON abonent.id = acc.abonent_id
                 JOIN smfd_data.t_address address ON address.id = abonent.address
                 JOIN public.t_city city ON city.id = address.city_id
        GROUP BY acc.bill_id
    );
    ALTER TABLE tmp_bill_by_filter_accounts
        ADD PRIMARY KEY (bill_id);

    RAISE NOTICE 'make full account object: % sec', (extract(EPOCH FROM clock_timestamp()) - time_log);
    time_log := extract(EPOCH FROM clock_timestamp());

    -- Собираем финальные объекта счетов. Вторая по весу операция.
    CREATE TEMPORARY TABLE tmp_bill_by_filter_bill_objects WITH (OIDS = FALSE)
                                                           ON COMMIT DROP AS (
        SELECT bill_row.id               bill_id,
               bill_row.forming_type     forming_type,
               (
                bill_row.number,
                bill_row.bill_date,
                bill_row.target_date,
                bill_row.deadline_date,
                bill_row.total_pay,
                bill_row.total_pay_recommended,
                bill_row.bill_pays,
                bill_row.qr_code,
                bill_row.barcode_common,
                bill_row.barcode_recommended,
                acc.account_objects,
                (
                 ven.vendor_name,
                 ven.call_center_phone,
                 ven.address_string,
                 ven.jur_info_string,
                 ven.jur_info_rs,
                 ven.jur_info_ks,
                 ven.jur_info_inn,
                 ven.jur_info_bank_name,
                 ven.jur_info_bic
                    ) :: smfd_data.S_VENDOR,
                bill_row.additional_params,
                bill_row.history_entry,
                bill_row.delivery_type,
                bill_row.email,
                bill_row.bill_type
                   ) :: smfd_data.S_BILL bill,
               bill_row                  bill_row,
               acc.city_ids              city_ids
        FROM tmp_bill_by_filter_bills bill_row
                 JOIN tmp_bill_by_filter_accounts acc ON acc.bill_id = bill_row.id
                 JOIN smfd_data.t_vendors ven ON ven.id = bill_row.vendor
        GROUP BY bill_row.id, acc.bill_id, ven.id
    );

    RAISE NOTICE 'make full bill object: % sec', (extract(EPOCH FROM clock_timestamp()) - time_log);

    /* ---------------------------------------------- */
    OPEN po_bills FOR
        WITH bill_obj AS (
            SELECT *
            FROM tmp_bill_by_filter_bill_objects)
        SELECT bill_obj.bill_id                                   bill_id,
               bill_obj.bill                                      bill,
               bill_obj.forming_type                              forming_type,
               CASE
                   WHEN advert_compound.has_blocks
                       THEN advert_compound.targeting
                   ELSE ARRAY [] :: public.S_KEY_VALUE_PAIR[] END targeting
        FROM bill_obj
                 LEFT JOIN (
            SELECT filtered_advts.bill_id                                                                 bill_id,
                   array_agg((filtered_advts.block_code, filtered_advts.module_code) :: S_KEY_VALUE_PAIR) targeting,
                   count(filtered_advts.block_code) > 0                                                   has_blocks
            FROM (SELECT DISTINCT ON (compound.bill_id, advt_block.advt_block_code) compound.bill_id           bill_id,
                                                                                    advt_block.advt_block_code block_code,
                                                                                    advt_module.data           module_code
                  FROM (
                           -- region target_by_numbers
                           (
                               SELECT bill_obj.bill_id       bill_id,
                                      by_numbers.advt_block  block_id,
                                      by_numbers.advt_module module_id,
                                      row_number() OVER ()   part_id,
                                      0                      priority
                               FROM bill_obj bill_obj
                                        JOIN smfd_data.t_bill_base bill_base
                                             ON bill_base.id = bill_obj.bill_id
                                        JOIN smfd_advert.t_advert_target_by_numbers by_numbers
                                             ON by_numbers.period_id = bill_base.period_id
                                                 AND by_numbers.forming_type_id = bill_base.forming_type
                                                 AND by_numbers.region_id = bill_base.region_id
                                        JOIN smfd_advert.t_targeting_number_list number_list
                                             ON number_list.numbers_type = 1
                                                 AND number_list.id = by_numbers.number_list_id

                                        JOIN smfd_advert.t_targeting_number_list_numbers list_numbers
                                             ON list_numbers.num_list_id = number_list.id
                                                 AND list_numbers.svc_nls_number = ANY (
                                                     SELECT (a :: smfd_data.S_ACCOUNT).account_number
                                                     FROM unnest((bill_obj).bill.accounts) a
                                                 )

                               ORDER BY number_list.load_date DESC
                           )
                           -- endregion target_by_numbers
                           /*  todo придумать как сделать лист для услуг. */
                           UNION ALL
                           -- region target_by_city
                           (
                               SELECT bill_obj.bill_id       bill_id,
                                      advt_city.advt_block   block_id,
                                      advt_city.advt_module  module_id,
                                      advt_city.city_list_id part_id,
                                      1                      priority
                               FROM bill_obj
                                        JOIN smfd_advert.t_targeting_city_list_cities cities
                                             ON cities.city_id = ANY (bill_obj.city_ids)
                                        JOIN smfd_advert.t_advert_target_by_city advt_city
                                             ON advt_city.city_list_id = cities.city_list_id
                                                 AND advt_city.period_id = (bill_obj.bill_row).period_id
                                                 AND advt_city.forming_type_id = (bill_obj.bill_row).forming_type
                               WHERE advt_city IS NOT NULL
                                 and advt_city.period_id = pi_period_id
                                 and advt_city.forming_type_id = bill_obj.forming_type
                           )
                           -- endregion target_by_city
                           UNION ALL
                           -- region target_by_region
                           (
                               SELECT bill_obj.bill_id     bill_id,
                                      advt_reg.advt_block  block_id,
                                      advt_reg.advt_module module_id,
                                      advt_reg.region_id   part_id,
                                      2                    priority
                               FROM bill_obj
                                        JOIN smfd_advert.t_advert_target_by_region advt_reg
                                             ON advt_reg.region_id = (bill_obj.bill_row).region_id
                                                 AND advt_reg.period_id = (bill_obj.bill_row).period_id
                                                 AND advt_reg.forming_type_id = (bill_obj.bill_row).forming_type
                               where advt_reg.region_id = pi_region_id
                                 and advt_reg.period_id = pi_period_id
                                 and advt_reg.forming_type_id = bill_obj.forming_type
                           )
                           -- endregion target_by_region
                       ) compound
                           LEFT JOIN smfd_advert.t_advt_block advt_block ON (advt_block.id = compound.block_id)
                           LEFT JOIN smfd_advert.t_advt_modules advt_module ON (advt_module.id = compound.module_id)
                  ORDER BY compound.bill_id, block_code, compound.priority, compound.part_id DESC
                 ) filtered_advts
            WHERE filtered_advts.block_code IS NOT NULL
            GROUP BY filtered_advts.bill_id
        ) advert_compound ON advert_compound.bill_id = bill_obj.bill_id;

    po_result_code := 0;
    po_result_message := 'ok';
    RETURN;

EXCEPTION
    WHEN OTHERS
        THEN DECLARE
            exception_diag TEXT;
        BEGIN
            GET STACKED DIAGNOSTICS exception_diag = PG_EXCEPTION_CONTEXT;
            PERFORM public.exception_log(SQLSTATE, SQLERRM, exception_diag);
            po_result_code := SQLSTATE;
            po_result_message := SQLERRM || ' CTX:' || exception_diag;
            RETURN;
        END;
END;
$$;
