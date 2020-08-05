/* ------------------------------------------------------------------------------------------------------------------------
	Расчётный период. Отправная точка всего сервиса.
    Обработка и формирование документов, таргетинг рекламы и прочие действия настраиваются на основе периода.
    При создании периода должны быть сгенерированы все партиции, основанные на периоде и перестроены индексы. */
CREATE TABLE if not exists smfd_data.t_billing_period
(
    id              SERIAL PRIMARY KEY NOT NULL,
    date            DATE               NOT NULL,
    created_by_user INT                NOT NULL,
    active          BOOL               NOT NULL DEFAULT FALSE,
    CONSTRAINT t_billing_period_t_user_id_fk FOREIGN KEY (created_by_user) REFERENCES smfd_user.t_user (id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX if not exists t_billing_period_date_uindex ON smfd_data.t_billing_period (date);
COMMENT ON TABLE smfd_data.t_billing_period IS 'Расчётный период. Добавление записи должно быть дополнено созданием партиций.';
COMMENT ON COLUMN smfd_data.t_billing_period.id IS 'Идентификатор периода.';
COMMENT ON COLUMN smfd_data.t_billing_period.date IS 'Дата начала действия периода (длительность 1 месяц).';
COMMENT ON COLUMN smfd_data.t_billing_period.created_by_user IS 'Пользователь, создавший период.';
COMMENT ON COLUMN smfd_data.t_billing_period.active IS 'Период активен на данный момент. Если по каким-либо причинам активны несколько - учтен будет период с максимальной датой';

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Создание периода */
CREATE OR REPLACE FUNCTION smfd_data.create_billing_period(IN pi_date DATE, /* дата */
                                                           IN pi_user_id INT, /* пользователь */

                                                           OUT po_period_id INT, /* период */
                                                           OUT po_result_code TEXT,
                                                           OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    period     DATE := date_trunc('month', cast(pi_date AS DATE));
    period_str TEXT := to_char(period, 'yyyy_MM');
    -- period_seq_start BIGINT := (to_char(period, 'yyyyMM1000000000000'))::BIGINT;
    period_id  INT;
BEGIN
    -- todo! PERFORM smfd_user.user_get_r aw(pi_user_id);

    INSERT INTO smfd_data.t_billing_period (date, created_by_user, active)
    VALUES (period, pi_user_id, FALSE)
    RETURNING id INTO period_id;


    -- todo! один раз, плюс в файлы:
    -- ALTER TABLE smfd_data.t_bill_base ALTER COLUMN id TYPE BIGINT USING id::BIGINT;
    -- ALTER TABLE smfd_data.t_bill_base ALTER COLUMN id SET DEFAULT 1;

    -- todo! EXECUTE 'CREATE SEQUENCE IF NOT EXISTS smfd_data_partitions.seq_bill_'|| period_str ||' as BIGINT START WITH '||period_seq_start||';';

    -- @formatter:off
    -- Понять и простить...
    -- Создание партиционной таблицы T_BILL
    EXECUTE 'CREATE TABLE smfd_data_partitions.t_bill_' || period_str ||
            ' PARTITION OF smfd_data.t_bill_base FOR VALUES IN (' || period_id || ');';

    -- todo! у t_bill_base убрать дефолтное значение (1)
    -- todo! EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_' || period_str || ' ALTER COLUMN id SET DEFAULT nextval(''smfd_data_partitions.seq_bill_'|| period_str ||''' :: REGCLASS);';

    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_' || period_str || ' ADD CONSTRAINT t_bill_' || period_str ||
            '_id_pk PRIMARY KEY (id);';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_' || period_str || ' ADD CONSTRAINT t_bill_' || period_str ||
            '_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_' || period_str || ' ADD CONSTRAINT t_bill_' || period_str ||
            '_t_vendors_id_fk FOREIGN KEY (vendor) REFERENCES smfd_data.t_vendors (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_' || period_str || ' ADD CONSTRAINT t_bill_' || period_str ||
            '_t_delivery_type_id_fk FOREIGN KEY (delivery_type) REFERENCES smfd_data.t_delivery_type (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_' || period_str || ' ADD CONSTRAINT t_bill_' || period_str ||
            '_t_forming_type_id_fk FOREIGN KEY (forming_type) REFERENCES smfd_data.t_forming_type (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'CREATE INDEX t_bill_' || period_str ||
            '_number_date_delivery_region_index ON smfd_data_partitions.t_bill_' || period_str ||
            ' (number, bill_date, delivery_type, region_id);';
    -- Индекс для отфильтрации уже добавленных ранее (save_bills).
    EXECUTE 'CREATE INDEX t_bill_' || period_str || '_number_index ON smfd_data_partitions.t_bill_' || period_str ||
            ' (number);';
    -- Индекс для запроса на формирование (get_bills_by_filter). todo не забудь заменить на проверку деливери+емейл
    EXECUTE 'CREATE INDEX t_bill_' || period_str || '_FILTER_index ON smfd_data_partitions.t_bill_' || period_str ||
            ' (id, period_id, region_id) WHERE (email is not null);';
    -- Индекс для первоначального фильтрования по ФТ
    EXECUTE 'CREATE INDEX t_bill_' || period_str || '_forming_type_index ON smfd_data_partitions.t_bill_' ||
            period_str || ' (forming_type) WHERE (email IS NOT NULL);';
    -- Индекс для запросов статистики счетов
    EXECUTE 'CREATE INDEX t_bill_' || period_str ||
            '_period_id_region_id_forming_type_index ON smfd_data_partitions.t_bill_' || period_str ||
            ' (period_id, region_id, forming_type);';

    EXECUTE 'CREATE INDEX t_bill_' || period_str || '_task_entry ON smfd_data_partitions.t_bill_' || period_str ||
            ' (history_entry);';

    EXECUTE 'CREATE TABLE smfd_data_partitions.t_bill_pay_' || period_str ||
            ' PARTITION OF smfd_data.t_bill_pay_base FOR VALUES IN (' || period_id || ');';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_pay_' || period_str || ' ADD CONSTRAINT t_bill_pay_' ||
            period_str ||
            '_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_pay_' || period_str || ' ADD CONSTRAINT t_bill_pay_' ||
            period_str || '_t_bill_' || period_str ||
            '_id_fk FOREIGN KEY (bill_id) REFERENCES smfd_data_partitions.t_bill_' || period_str ||
            ' (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_pay_' || period_str || ' ADD CONSTRAINT t_bill_pay_' ||
            period_str ||
            '_t_bill_pay_types_id_fk FOREIGN KEY (pay_type) REFERENCES smfd_data.t_bill_pay_types (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'CREATE INDEX t_bill_pay_' || period_str || '_bill_id_pay_type_index ON smfd_data_partitions.t_bill_pay_' ||
            period_str || ' (bill_id, pay_type);';

    EXECUTE 'CREATE TABLE smfd_data_partitions.t_bill_accounts_' || period_str ||
            ' PARTITION OF smfd_data.t_bill_accounts_base FOR VALUES IN (' || period_id || ');';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_accounts_' || period_str || ' ADD CONSTRAINT t_bill_accounts_' ||
            period_str || '_id_pk PRIMARY KEY (id);';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_accounts_' || period_str || ' ADD CONSTRAINT t_bill_accounts_' ||
            period_str ||
            '_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_accounts_' || period_str || ' ADD CONSTRAINT t_bill_accounts_' ||
            period_str || '_t_bill_' || period_str ||
            '_id_fk FOREIGN KEY (bill_id) REFERENCES smfd_data_partitions.t_bill_' || period_str ||
            ' (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_accounts_' || period_str || ' ADD CONSTRAINT t_bill_accounts_' ||
            period_str ||
            '_t_bill_abonent_id_fk FOREIGN KEY (abonent_id) REFERENCES smfd_data.t_bill_abonent (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'CREATE UNIQUE INDEX t_bill_accounts_' || period_str ||
            '_abonent_id_bill_id_account_number_uindex ON smfd_data_partitions.t_bill_accounts_' || period_str ||
            ' (abonent_id, bill_id, account_number);';
    EXECUTE 'CREATE INDEX t_bill_accounts_' || period_str ||
            '_bill_id_index ON smfd_data_partitions.t_bill_accounts_' || period_str || ' (bill_id);';
    EXECUTE 'CREATE INDEX t_bill_accounts_' || period_str ||
            '_account_number_index ON smfd_data_partitions.t_bill_accounts_' || period_str || ' (account_number);';

    EXECUTE 'CREATE TABLE smfd_data_partitions.t_bill_details_' || period_str ||
            ' PARTITION OF smfd_data.t_bill_details_base FOR VALUES IN (' || period_id || ');';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_details_' || period_str || ' ADD CONSTRAINT t_bill_details_' ||
            period_str ||
            '_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_details_' || period_str || ' ADD CONSTRAINT t_bill_details_' ||
            period_str || '_t_bill_accounts_' || period_str ||
            '_period_id_fk FOREIGN KEY (account_id) REFERENCES smfd_data_partitions.t_bill_accounts_' || period_str ||
            ' (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'CREATE INDEX t_bill_details_' || period_str ||
            '_account_id_service_number_index ON smfd_data_partitions.t_bill_details_' || period_str ||
            ' (account_id, service_number);';

    EXECUTE 'CREATE TABLE smfd_data_partitions.t_bill_call_details_' || period_str ||
            ' PARTITION OF smfd_data.t_bill_call_details_base FOR VALUES IN (' || period_id || ');';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_call_details_' || period_str ||
            ' ADD CONSTRAINT t_bill_call_details_' || period_str ||
            '_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'ALTER  TABLE smfd_data_partitions.t_bill_call_details_' || period_str ||
            ' ADD CONSTRAINT t_bill_call_details_' || period_str || '_t_bill_accounts_' || period_str ||
            '_period_id_fk FOREIGN KEY (account_id) REFERENCES smfd_data_partitions.t_bill_accounts_' || period_str ||
            ' (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'CREATE INDEX t_bill_call_details_' || period_str ||
            '_account_id_index ON smfd_data_partitions.t_bill_call_details_' || period_str || ' (account_id);';

    EXECUTE 'CREATE TABLE smfd_data_partitions.t_forming_publishing_details_' || period_str ||
            ' PARTITION OF smfd_data.t_forming_publishing_details_base FOR VALUES IN (' || period_id || ');';
    EXECUTE 'CREATE INDEX t_forming_publishing_details_' || period_str ||
            '_message_id_index ON smfd_data_partitions.t_forming_publishing_details_' || period_str || ' (message_id);';
    EXECUTE 'ALTER TABLE smfd_data_partitions.t_forming_publishing_details_' || period_str ||
            ' ADD CONSTRAINT t_forming_publishing_details_' || period_str ||
            '_t_forming_publishing_id_fk FOREIGN KEY (publishing_id) REFERENCES smfd_data.t_forming_publishing (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'ALTER TABLE smfd_data_partitions.t_forming_publishing_details_' || period_str ||
            ' ADD CONSTRAINT t_forming_publishing_details_' || period_str ||
            '_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'ALTER TABLE smfd_data_partitions.t_forming_publishing_details_' || period_str ||
            ' ADD CONSTRAINT t_forming_publishing_details_' || period_str || '_t_bill_' || period_str ||
            '_id_fk FOREIGN KEY (bill_id) REFERENCES smfd_data_partitions.t_bill_' || period_str ||
            ' (id) ON DELETE CASCADE ON UPDATE CASCADE;';
    EXECUTE 'CREATE UNIQUE INDEX t_forming_publishing_details_' || period_str ||
            '_period_id_publishing_id_bill_id_uindex ON smfd_data_partitions.t_forming_publishing_details_' ||
            period_str || ' (period_id, publishing_id, bill_id);';
    -- @formatter:on

    PERFORM audit(pi_user_id, 'BILLING_PERIOD_CREATE', 'period=' || period);
    po_result_code := 0;
    po_result_message := 'ok';
    po_period_id := period_id;
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

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Удаление периода */
CREATE OR REPLACE FUNCTION smfd_data.delete_billing_period(IN pi_period_id INT, /* период */
                                                           IN pi_user_id INT, /* пользователь */
                                                           OUT po_result_code TEXT,
                                                           OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    period_str TEXT;
BEGIN
    IF (smfd_data.get_current_billing_period() = pi_period_id)
    THEN
        RAISE SQLSTATE '21000'
            USING MESSAGE = 'Cannot delete currently active period';
    END IF;

    -- Удаление из таблицы периодов
    DELETE
    FROM smfd_data.t_billing_period bp
    WHERE bp.id = pi_period_id
    RETURNING to_char(bp.date, 'yyyy_MM') INTO period_str;

    IF (period_str IS NULL)
    THEN
        RAISE SQLSTATE '02000'
            USING MESSAGE = 'Period not found';
    END IF;

    -- Удаление связанных с периодом партиций таблиц.
    EXECUTE 'DROP TABLE IF EXISTS smfd_data_partitions.t_bill_' || period_str || ' CASCADE';
    EXECUTE 'DROP TABLE IF EXISTS smfd_data_partitions.t_bill_pay_' || period_str || ' CASCADE;';
    EXECUTE 'DROP TABLE IF EXISTS smfd_data_partitions.t_bill_accounts_' || period_str || ' CASCADE;';
    EXECUTE 'DROP TABLE IF EXISTS smfd_data_partitions.t_bill_details_' || period_str || ' CASCADE;';
    EXECUTE 'DROP TABLE IF EXISTS smfd_data_partitions.t_bill_call_details_' || period_str || ' CASCADE;';
    EXECUTE 'DROP TABLE IF EXISTS smfd_data_partitions.t_forming_publishing_details_' || period_str || ' CASCADE;';

    PERFORM audit(pi_user_id, 'BILLING_PERIOD_DELETE', 'period=' || period_str);
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

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Активация периода */
CREATE OR REPLACE FUNCTION smfd_data.activate_billing_period(IN pi_period_id INT, /* период */
                                                             IN pi_user_id INT, /* пользователь */
                                                             OUT po_result_code TEXT,
                                                             OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    -- todo PERFORM smfd_user.user_get_r aw(pi_user_id);

    IF NOT exists(SELECT *
                  FROM smfd_data.t_billing_period
                  WHERE id = pi_period_id)
    THEN
        RAISE SQLSTATE '02000'
            USING MESSAGE = 'Period not found';
    END IF;

    UPDATE smfd_data.t_billing_period
    SET active = (id = pi_period_id);

    PERFORM audit(pi_user_id, 'BILLING_PERIOD_ACTIVATE', 'period_id=' || pi_period_id);

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

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Возвращаем текущий активный период */
CREATE OR REPLACE FUNCTION smfd_data.get_current_billing_period(
    OUT period_id INT /* id периода */
) RETURNS INT
    LANGUAGE plpgsql AS
$$
BEGIN
    SELECT p.id
    INTO period_id
    FROM smfd_data.t_billing_period p
    WHERE p.active = TRUE
    ORDER BY p.date DESC
    LIMIT 1;
END;
$$;

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Получение информации о всех периодах */
CREATE OR REPLACE FUNCTION smfd_data.get_billing_periods(OUT po_eriods REFCURSOR, /* Курсор с результатом */
                                                         OUT po_result_code TEXT,
                                                         OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN

    OPEN po_eriods FOR
        SELECT p.id         AS period_id,
               p.date       AS period_date,
               p.active     AS is_active,
               u.user_login AS created_by
        FROM smfd_data.t_billing_period p
                 JOIN smfd_user.t_user u ON u.id = p.created_by_user
        ORDER BY p.date;

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
