/*  ================================================================================================================================
    Создание базовых таблиц для партицирования данных о счёте на оплату.
    Сами партиции будут создаваться динамически из функции smfd_data.create_billing_period(DATE, USER) В схеме smfd_data_partitions.
    ================================================================================================================================ */

DROP TABLE IF EXISTS smfd_data.t_bill_call_details_base CASCADE;
DROP TABLE IF EXISTS smfd_data.t_bill_details_base CASCADE;
DROP TABLE IF EXISTS smfd_data.t_bill_accounts_base CASCADE;
DROP TABLE IF EXISTS smfd_data.t_bill_pay_base CASCADE;
DROP TABLE IF EXISTS smfd_data.t_bill_base CASCADE;
DROP SEQUENCE IF EXISTS smfd_data.t_bill_id_part_seq CASCADE;
DROP SEQUENCE IF EXISTS smfd_data.t_bill_account_id_part_seq CASCADE;

CREATE SEQUENCE IF NOT EXISTS smfd_data.t_bill_id_part_seq AS INTEGER MAXVALUE 2147483647;
CREATE SEQUENCE IF NOT EXISTS smfd_data.t_bill_account_id_part_seq AS INTEGER MAXVALUE 2147483647;
-- todo когда-то заменить на bigint, и выяснить, не сильно ли будет сосать по скорости

/* -================================================================================- */
CREATE TABLE IF NOT EXISTS smfd_data.t_bill_base
(
    id                    INT                       DEFAULT nextval('smfd_data.t_bill_id_part_seq' :: REGCLASS) NOT NULL,
    period_id             INT                                                                                   NOT NULL,
    number                VARCHAR(256)                                                                          NOT NULL,
    bill_date             TIMESTAMP                                                                             NOT NULL,
    target_date           TIMESTAMP                                                                             NOT NULL,
    deadline_date         TIMESTAMP,
    total_pay             INT,
    total_pay_recommended INT,
    qr_code               TEXT,
    barcode_common        VARCHAR(1000),
    barcode_recommended   VARCHAR(1000),
    vendor                INT,
    history_entry         INT,
    delivery_type         INT                       DEFAULT NULL                                                NULL,
    email                 VARCHAR(256),
    region_id             INT                       DEFAULT NULL,
    additional_params     public.S_KEY_VALUE_PAIR[] DEFAULT ARRAY [] :: public.S_KEY_VALUE_PAIR[]               NOT NULL,
    forming_type          INT                                                                                   NOT NULL,
    bill_type             INT                       DEFAULT 1                                                   NOT NULL
) PARTITION BY LIST (period_id);
COMMENT ON COLUMN smfd_data.t_bill_base.period_id IS 'Ссылка на период. Оно же - ключ партицирования.';
COMMENT ON COLUMN smfd_data.t_bill_base.number IS 'Номер счёта';
COMMENT ON COLUMN smfd_data.t_bill_base.bill_date IS 'Дата выставления счёта';
COMMENT ON COLUMN smfd_data.t_bill_base.target_date IS 'Месяц, за который производилось начисление';
COMMENT ON COLUMN smfd_data.t_bill_base.deadline_date IS 'Срок, до которого необходимо произвести оплату';
COMMENT ON COLUMN smfd_data.t_bill_base.total_pay IS 'Итоговая сумма к оплате по счёту';
COMMENT ON COLUMN smfd_data.t_bill_base.total_pay_recommended IS 'Итоговая сумма к оплате, включая рекомендованный платеж';
COMMENT ON COLUMN smfd_data.t_bill_base.qr_code IS 'QR-код';
COMMENT ON COLUMN smfd_data.t_bill_base.barcode_common IS 'Баркод с оплатой без рекомендованного платежа';
COMMENT ON COLUMN smfd_data.t_bill_base.barcode_recommended IS 'Баркод с оплатой, включая рекомендованный платеж';
COMMENT ON COLUMN smfd_data.t_bill_base.history_entry IS 'Ссылка на историю загрузок файлов';
COMMENT ON COLUMN smfd_data.t_bill_base.email IS 'Адрес E-Mail, на который будет осуществлена доставка';
COMMENT ON COLUMN smfd_data.t_bill_base.region_id IS 'Идентификатор региона. Нужен тут для избежания коллизии по номерам, и для ускорения выборки по регионам.';
COMMENT ON COLUMN smfd_data.t_bill_base.additional_params IS 'Дополнительные параметры счёта. Нужны для корректного построения документа.';
COMMENT ON COLUMN smfd_data.t_bill_base.forming_type IS 'Тип формирования, указанный при загрузке XML';
COMMENT ON TABLE smfd_data.t_bill_base IS 'Основная таблица счёта на оплату';

/* -================================================================================- */
CREATE TABLE smfd_data.t_bill_pay_base
(
    period_id     INT          NOT NULL,
    bill_id       INT          NOT NULL,
    pay_type      INT          NOT NULL,
    pay_line_name VARCHAR(256) NULL,
    pay_saldo     INT,
    pay_income    INT,
    pay_invoice   INT,
    pay_total     INT,
    pay_prepaid   INT,
    pay_deferred  INT
) PARTITION BY LIST (period_id);
COMMENT ON COLUMN smfd_data.t_bill_pay_base.period_id IS 'Ссылка на период. Оно же - ключ партицирования.';
COMMENT ON COLUMN smfd_data.t_bill_pay_base.bill_id IS 'Ссылка на счёт к оплате';
COMMENT ON COLUMN smfd_data.t_bill_pay_base.pay_type IS 'Тип строки';
COMMENT ON COLUMN smfd_data.t_bill_pay_base.pay_line_name IS 'Некоторые МРФ сами присылают названия строк';
COMMENT ON COLUMN smfd_data.t_bill_pay_base.pay_saldo IS 'Остаток на ***';
COMMENT ON COLUMN smfd_data.t_bill_pay_base.pay_income IS 'Поступило оплат в ***';
COMMENT ON COLUMN smfd_data.t_bill_pay_base.pay_invoice IS 'Начислено в ***';
COMMENT ON COLUMN smfd_data.t_bill_pay_base.pay_prepaid IS 'Аванс';
COMMENT ON COLUMN smfd_data.t_bill_pay_base.pay_deferred IS 'Рассрочка';
COMMENT ON COLUMN smfd_data.t_bill_pay_base.pay_total IS 'Итого по строке';
COMMENT ON TABLE smfd_data.t_bill_pay_base IS 'Информация об оплатах в счёте';

/* -================================================================================- */
CREATE TABLE smfd_data.t_bill_accounts_base
(
    period_id      INT                                                                     NOT NULL,
    id             INT DEFAULT nextval('smfd_data.t_bill_account_id_part_seq' :: REGCLASS) NOT NULL,
    bill_id        INT                                                                     NOT NULL,
    abonent_id     INT                                                                     NOT NULL,
    account_number VARCHAR(128)                                                            NOT NULL
) PARTITION BY LIST (period_id);
COMMENT ON COLUMN smfd_data.t_bill_accounts_base.bill_id IS 'Ссылка на счёт к оплате';
COMMENT ON COLUMN smfd_data.t_bill_accounts_base.abonent_id IS 'Ссылка на абонента';
COMMENT ON COLUMN smfd_data.t_bill_accounts_base.account_number IS 'Номер лицевого счёта';
COMMENT ON TABLE smfd_data.t_bill_accounts_base IS 'Связка счёта на оплату и лицевых счетов';

/* -================================================================================- */
CREATE TABLE smfd_data.t_bill_details_base
(
    period_id      INT NOT NULL,
    account_id     INT,
    service_number VARCHAR(128),
    service_type   VARCHAR(128),
    detail_name    TEXT,
    priority_order INT DEFAULT NULL,
    quantity       FLOAT,
    quantity_unit  VARCHAR(32),
    detail_sum     INT
) PARTITION BY LIST (period_id);
COMMENT ON COLUMN smfd_data.t_bill_details_base.period_id IS 'Ссылка на период. Оно же - ключ партицирования.';
COMMENT ON COLUMN smfd_data.t_bill_details_base.account_id IS 'Ссылка на лицевой счёт';
COMMENT ON COLUMN smfd_data.t_bill_details_base.service_number IS 'Номер услуги';
COMMENT ON COLUMN smfd_data.t_bill_details_base.service_type IS 'Тип услуги';
COMMENT ON COLUMN smfd_data.t_bill_details_base.detail_name IS 'Цели начисления';
COMMENT ON COLUMN smfd_data.t_bill_details_base.priority_order IS 'Порядок сортировки';
COMMENT ON COLUMN smfd_data.t_bill_details_base.quantity IS 'Количество';
COMMENT ON COLUMN smfd_data.t_bill_details_base.quantity_unit IS 'Единица количества';
COMMENT ON COLUMN smfd_data.t_bill_details_base.detail_sum IS 'Цена, коп.';
COMMENT ON TABLE smfd_data.t_bill_details_base IS 'Детализация счетов на оплату по лицевым счетам';

/* -================================================================================- */
CREATE TABLE smfd_data.t_bill_call_details_base
(
    period_id       INT          NOT NULL,
    account_id      INT          NOT NULL,
    service_number  VARCHAR(128),
    tariff_name     VARCHAR(256) DEFAULT NULL,
    stat_date       TIMESTAMP,
    service_subtype VARCHAR(128) NOT NULL,
    vendor_id       VARCHAR(16),
    connect_type    VARCHAR(1),
    connect_period  INT,
    connect_cost    FLOAT,
    connect_code    VARCHAR(128)
) PARTITION BY LIST (period_id);
COMMENT ON COLUMN smfd_data.t_bill_call_details_base.period_id IS 'Ссылка на период. Оно же - ключ партицирования.';
COMMENT ON COLUMN smfd_data.t_bill_call_details_base.account_id IS 'Ссылка на лицевой счет';
COMMENT ON COLUMN smfd_data.t_bill_call_details_base.service_number IS 'Номер услуги/телефона';
COMMENT ON COLUMN smfd_data.t_bill_call_details_base.tariff_name IS 'Имя тарифа для группировки детализации соединений';
COMMENT ON COLUMN smfd_data.t_bill_call_details_base.stat_date IS 'Время совершения соединения';
COMMENT ON COLUMN smfd_data.t_bill_call_details_base.service_subtype IS 'Тип соединения?';
COMMENT ON COLUMN smfd_data.t_bill_call_details_base.vendor_id IS 'Идентификатор вендора. Пока не внешний ключ.';
COMMENT ON COLUMN smfd_data.t_bill_call_details_base.connect_type IS 'Код типа соединения';
COMMENT ON COLUMN smfd_data.t_bill_call_details_base.connect_period IS 'Длительность соединения';
COMMENT ON COLUMN smfd_data.t_bill_call_details_base.connect_cost IS 'Стоимость соединения';
COMMENT ON COLUMN smfd_data.t_bill_call_details_base.connect_code IS 'Код абонента';
COMMENT ON TABLE smfd_data.t_bill_call_details_base IS 'Детализация вызовов и подобная статистика для счёта';

/* -================================================================================- */
/* Проверка на существование нужной партиции для сохранения счетов */
CREATE OR REPLACE FUNCTION smfd_data_partitions.assert_partition(
    IN pi_partition_id INT /* id партиции */
) RETURNS VOID
    LANGUAGE plpgsql AS
$$
DECLARE
    part_date DATE;
    part_name NAME;
BEGIN
    SELECT p.date
    INTO part_date
    FROM smfd_data.t_billing_period p
    WHERE p.id = pi_partition_id;

    IF (part_date IS NULL)
    THEN
        RAISE SQLSTATE '02000'
            USING MESSAGE = 'Period or partitions not found';
    END IF;

    SELECT pc.relname
    INTO part_name
    FROM pg_catalog.pg_class pc
    WHERE pc.relname = 't_bill_pay_' || to_char(part_date, 'yyyy_MM');

    IF (part_name IS NULL OR part_name = '')
    THEN
        RAISE SQLSTATE '02000'
            USING MESSAGE = 'Period or partitions not found';
    END IF;
END;
$$;
