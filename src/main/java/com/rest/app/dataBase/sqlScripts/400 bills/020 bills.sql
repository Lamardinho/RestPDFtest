DROP TYPE IF EXISTS smfd_data.S_BILL CASCADE;
DROP TYPE IF EXISTS smfd_data.S_ACCOUNT CASCADE;
DROP TYPE IF EXISTS smfd_data.S_BILL_DETAILS CASCADE;
DROP TYPE IF EXISTS smfd_data.S_BILL_CALL_DETAILS CASCADE;
DROP TYPE IF EXISTS smfd_data.S_BILL_PAY CASCADE;
-- /!\ После пересоздания объектов не забудь пересоздать функции /!\

/* Представление элемента (строки) детализации */
CREATE TYPE smfd_data.S_BILL_DETAILS AS
(
    service_number TEXT,
    service_type   TEXT,
    detail_name    TEXT,
    priority_order INT,
    quantity       FLOAT,
    quantity_unit  TEXT,
    detail_sum     INT
);

/* Представление детализации соединения */
CREATE TYPE smfd_data.S_BILL_CALL_DETAILS AS
(
    service_number  TEXT /* Номер услуги */,
    tariff_name     TEXT/* Имя тарифа для группировки детализации соединений */,
    stat_date       TIMESTAMP /* Время совершения соединения */,
    service_subtype TEXT /* Тип соединения */,
    vendor_id       TEXT /* Ссылка на вендора */,
    connect_type    TEXT /* Код типа соединения */,
    connect_period  INT /* Длительность соединения */,
    connect_cost    INT /* Стоимость соединения */,
    connect_code    VARCHAR(128) /* Код абонента */
);

/* Представление лицевого счёта */
CREATE TYPE smfd_data.S_ACCOUNT AS
(
    account_number     TEXT /*  */,
    abonent            smfd_data.S_ABONENT /*  */,
    details            smfd_data.S_BILL_DETAILS[] /* Детализация счёта */,
    connect_detainling smfd_data.S_BILL_CALL_DETAILS[] /* Детализация соединений (в т.ч. звонков) */
);

/* Представление информации о платежах счёта */
CREATE TYPE smfd_data.S_BILL_PAY AS
(
    pay_type      INT,
    pay_line_name TEXT,
    pay_saldo     INT,
    pay_income    INT,
    pay_invoice   INT,
    pay_total     INT,
    pay_prepaid   INT,
    pay_deferred  INT
);

/* Представление счёта (документа) к оплате */
CREATE TYPE smfd_data.S_BILL AS
(
    number                TEXT,
    bill_date             TIMESTAMP,
    target_date           TIMESTAMP,
    deadline_date         TIMESTAMP,
    total_pay             INTEGER,
    total_pay_recommended INTEGER,
    pays                  smfd_data.S_BILL_PAY[],
    qr_code               TEXT,
    barcode_common        TEXT,
    barcode_recommended   TEXT,
    accounts              smfd_data.S_ACCOUNT[],
    vendor                smfd_data.S_VENDOR,
    additional_parameters PUBLIC.S_KEY_VALUE_PAIR[],
    history_entry         INT, /* Ссылка на историю загрузок файлов */
    delivery_type         TEXT,
    email                 TEXT,
    bill_type             INT
);

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Возвращаем инфо об аккаунте по id билла */
CREATE OR REPLACE FUNCTION smfd_data.get_accounts_by_id(IN pi_period_id INT, /* период */
                                                        IN pi_bill_id INT /* id билла */
)
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

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Получение детализации билла по периоду и аккаунту */
CREATE OR REPLACE FUNCTION smfd_data.get_bill_details_by_id(IN pi_period_id INT, /* период */
                                                            IN pi_account_id INT /* id аккаунта */
)
    RETURNS smfd_data.S_BILL_DETAILS[]
    LANGUAGE plpgsql AS
$$
DECLARE
    detail_row     smfd_data.T_BILL_DETAILS_BASE;
    details_object smfd_data.S_BILL_DETAILS;
    array_object   smfd_data.S_BILL_DETAILS[];
BEGIN
    FOR detail_row IN
        SELECT *
        FROM smfd_data.t_bill_details_base d
        WHERE d.period_id = pi_period_id
          AND d.account_id = pi_account_id
        LOOP
            IF detail_row IS NOT NULL
            THEN
                details_object.service_number := detail_row.service_number;
                details_object.service_type := detail_row.service_type;
                details_object.detail_name := detail_row.detail_name;
                details_object.priority_order := detail_row.priority_order;
                details_object.quantity := detail_row.quantity;
                details_object.quantity_unit := detail_row.quantity_unit;
                details_object.detail_sum := detail_row.detail_sum;

                array_object := array_append(array_object, details_object);
            END IF;
        END LOOP;

    RETURN array_object;
END;
$$;

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Получаем детализацию по звонкам */
CREATE OR REPLACE FUNCTION smfd_data.get_call_details_by_id(IN pi_period_id INT, /* период */
                                                            IN pi_account_id INT /* id аккаунта */
)
    RETURNS smfd_data.S_BILL_CALL_DETAILS[]
    LANGUAGE plpgsql AS
$$
DECLARE
    call_row     smfd_data.T_BILL_CALL_DETAILS_BASE;
    call_object  smfd_data.S_BILL_CALL_DETAILS;
    array_object smfd_data.S_BILL_CALL_DETAILS[];
BEGIN
    FOR call_row IN
        SELECT *
        FROM smfd_data.t_bill_call_details_base c
        WHERE c.period_id = pi_period_id
          AND c.account_id = pi_account_id
        LOOP
            IF call_row IS NOT NULL
            THEN
                call_object.service_number := call_row.service_number;
                call_object.tariff_name := call_row.tariff_name;
                call_object.stat_date := call_row.stat_date;
                call_object.service_subtype := call_row.service_subtype;
                call_object.vendor_id := call_row.vendor_id;
                call_object.connect_type := call_row.connect_type;
                call_object.connect_period := call_row.connect_period;
                call_object.connect_cost := call_row.connect_cost;
                call_object.connect_code := call_row.connect_code;

                array_object := array_append(array_object, call_object);
            END IF;
        END LOOP;

    RETURN array_object;
END;
$$;

/* ------------------------------------------------------------------------------------------------------------------------ */
DROP TABLE IF EXISTS smfd_data.t_bill_pay_types CASCADE;
CREATE TABLE smfd_data.t_bill_pay_types
(
    id        SERIAL PRIMARY KEY NOT NULL,
    type_name VARCHAR(256)       NOT NULL
);
COMMENT ON COLUMN smfd_data.t_bill_pay_types.id IS 'Идентификатор типа';
COMMENT ON COLUMN smfd_data.t_bill_pay_types.type_name IS 'Наименование типа';
COMMENT ON TABLE smfd_data.t_bill_pay_types IS 'Типы данных о платежах в счете на оплату';

CREATE UNIQUE INDEX t_bill_pay_type_type_name_uindex
    ON smfd_data.t_bill_pay_types (type_name);

INSERT INTO smfd_data.t_bill_pay_types (id, type_name)
VALUES (0, 'Manual');
INSERT INTO smfd_data.t_bill_pay_types (type_name)
VALUES ('Итого'),
       ('По оказанным услугам'),
       ('Пени'),
       ('Перерасчеты'),
       ('Аванс');

/* ------------------------------------------------------------------------------------------------------------------------ */
CREATE TABLE IF NOT EXISTS smfd_data.t_delivery_type
(
    id      SERIAL PRIMARY KEY NOT NULL,
    dt_code VARCHAR(32)        NOT NULL
);
COMMENT ON TABLE smfd_data.t_delivery_type IS 'Справочник типов доставки';

CREATE UNIQUE INDEX IF NOT EXISTS t_delivery_type_dt_code_uindex
    ON smfd_data.t_delivery_type (dt_code);

/* Возвращаем id типа доставки */
CREATE OR REPLACE FUNCTION smfd_data.get_delivery_type_id(
    IN pi_delivery_type_code TEXT /* код типа доставки */
)
    RETURNS INT
    LANGUAGE plpgsql AS
$$
DECLARE
    dt_id INT;
BEGIN
    IF (pi_delivery_type_code IS NULL)
    THEN
        RETURN NULL;
    END IF;

    SELECT dt.id
    INTO dt_id
    FROM smfd_data.t_delivery_type dt
    WHERE dt.dt_code = pi_delivery_type_code
    LIMIT 1;

    IF (dt_id IS NULL)
    THEN
        INSERT INTO smfd_data.t_delivery_type (dt_code)
        VALUES (pi_delivery_type_code)
        RETURNING id INTO dt_id;
    END IF;

    RETURN dt_id;
END;
$$;

/* ------------------------------------------------------------------------------------------------------------------------
	Таблица-справочник типов услуг. */
CREATE TABLE IF NOT EXISTS smfd_data.td_service_types
(
    id      VARCHAR(16) PRIMARY KEY NOT NULL,
    st_name VARCHAR(64)             NOT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS td_service_type_id_uindex
    ON smfd_data.td_service_types (id);
COMMENT ON TABLE smfd_data.td_service_types IS 'Типы услуг';

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Функция-кеш (не используется) */
CREATE OR REPLACE FUNCTION smfd_data.get_service_type_id(pi_st_name VARCHAR(64), /*  */
                                                         pi_default_st_id VARCHAR(16) /*  */
)
    RETURNS VARCHAR(16)
    LANGUAGE plpgsql AS
$$
DECLARE
    po_service_type_id VARCHAR(16);
BEGIN
    SELECT st.id
    INTO po_service_type_id
    FROM smfd_data.td_service_types st
    WHERE st.st_name = pi_st_name;

    IF po_service_type_id IS NULL
    THEN
        INSERT INTO smfd_data.td_service_types (id, st_name)
        VALUES (pi_default_st_id, pi_st_name)
        RETURNING id INTO po_service_type_id;
    END IF;

    RETURN po_service_type_id;
END;
$$;

/* Получение курсора со статистикой по типу доставки для региона */
CREATE OR REPLACE FUNCTION smfd_data.get_statistic(IN pi_period_id INT, /* период */
                                                   IN pi_mrf_id INT, /* мрф */
                                                   IN pi_region_id INT, /* регион */
                                                   OUT po_stat REFCURSOR, /* резульат */
                                                   OUT po_result_code TEXT,
                                                   OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
DECLARE
BEGIN
    OPEN po_stat FOR
        SELECT DT.dt_code         dt_code,
               bs.region_id       region_id,
               bs.forming_type_id forming_type,
               sum(bs.count) as   count
        FROM smfd_data.t_bill_statistic bs
                 JOIN smfd_data.t_delivery_type DT ON bs.delivery_type_id = DT.id
                 JOIN td_region REG ON REG.region_id = bs.region_id
                 JOIN smfd_data.t_forming_type ft ON ft.id = bs.forming_type_id
        WHERE bs.period_id = pi_period_id
          AND REG.mrf_id = pi_mrf_id
          AND (pi_region_id = 0 OR REG.region_id = pi_region_id)
          -- типы "доставки" Account и Client сохраняем только для типов формирования mvno
          AND (bs.forming_type_id > 100 AND dt.id in (1, 2)
            -- для отсатльных типов формирования соответственно сохраняем все кроме типов "доставки" Account и Client
            OR (bs.forming_type_id < 100 AND dt.id not in (1, 2))
            -- кроме урала, для него грузим все
            OR (ft.mrf_id = 6 AND bs.forming_type_id < 100))
        GROUP BY dt.dt_code, bs.region_id, bs.forming_type_id, bs.period_id;

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

/* Получение билла по id */
create or replace function smfd_data.get_bill_details_by_id(in pi_bill_id int, /* id билла */
                                                            out po_bill_info refcursor, /* сам билл */
                                                            OUT po_result_code text,
                                                            OUT po_result_message text) returns record
    language plpgsql
as
$$
begin
    open po_bill_info for
        select bb.period_id, bb.region_id, bb.forming_type, bb.delivery_type
        from smfd_data.t_bill_base bb
        where bb.id = pi_bill_id;
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
end;
$$;