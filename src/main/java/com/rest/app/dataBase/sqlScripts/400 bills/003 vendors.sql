/* ------------------------------------------------------------------------------------------------------------------------ */
DROP TYPE IF EXISTS smfd_data.S_VENDOR CASCADE;
CREATE TYPE smfd_data.S_VENDOR AS
(
    vendor_name        TEXT,
    call_center_phone  TEXT,
    address_string     TEXT,
    jur_info_string    TEXT,
    jur_info_rs        TEXT,
    jur_info_ks        TEXT,
    jur_info_inn       TEXT,
    jur_info_bank_name TEXT,
    jur_info_bic       TEXT
);

/* ------------------------------------------------------------------------------------------------------------------------ */
DROP TABLE IF EXISTS smfd_data.t_vendors CASCADE;
CREATE TABLE IF NOT EXISTS smfd_data.t_vendors
(
    id                 SERIAL PRIMARY KEY NOT NULL,
    vendor_name        VARCHAR            NOT NULL,
    call_center_phone  VARCHAR,
    address_string     VARCHAR,
    jur_info_string    TEXT,
    jur_info_rs        VARCHAR,
    jur_info_ks        VARCHAR,
    jur_info_inn       VARCHAR,
    jur_info_bank_name VARCHAR,
    jur_info_bic       VARCHAR,
    hash_code          INT                NOT NULL DEFAULT 0

);
COMMENT ON COLUMN smfd_data.t_vendors.id IS 'Идентификатор вендора';
COMMENT ON COLUMN smfd_data.t_vendors.vendor_name IS 'Наименование вендора';
COMMENT ON COLUMN smfd_data.t_vendors.call_center_phone IS 'Телефон колл-центра или контактный телефон';
COMMENT ON COLUMN smfd_data.t_vendors.address_string IS 'Строка адреса. Справочник не решились использовать пока...';
COMMENT ON COLUMN smfd_data.t_vendors.jur_info_string IS 'Строка с юридическими и платежными рекыизитами';
COMMENT ON COLUMN smfd_data.t_vendors.jur_info_rs IS 'Реквизиты: расчетный счёт';
COMMENT ON COLUMN smfd_data.t_vendors.jur_info_ks IS 'Реквизиты: кассовый счёт';
COMMENT ON COLUMN smfd_data.t_vendors.jur_info_inn IS 'Реквизиты: ИНН';
COMMENT ON COLUMN smfd_data.t_vendors.jur_info_bank_name IS 'Реквизиты: обслуживающий банк';
COMMENT ON COLUMN smfd_data.t_vendors.jur_info_bic IS 'Реквизиты: БИК';
COMMENT ON TABLE smfd_data.t_vendors IS 'Справочник вендоров';

CREATE INDEX IF NOT EXISTS t_vendors_hash_code_index ON smfd_data.t_vendors (hash_code);

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Генерация хеша для вендора */
CREATE OR REPLACE FUNCTION smfd_data.get_vendor_hashcode(
    pi_vendor_row smfd_data.T_VENDORS /* вендор */
) RETURNS INT
    LANGUAGE plpgsql AS
$$
BEGIN
    RETURN hashtext(
                            coalesce(pi_vendor_row.address_string, pi_vendor_row.vendor_name, '') || '~' ||
                            coalesce(pi_vendor_row.call_center_phone, '') || '~' ||
                            coalesce(
                                    pi_vendor_row.jur_info_string,
                                    pi_vendor_row.jur_info_ks || '~' || pi_vendor_row.jur_info_rs || '~' ||
                                    pi_vendor_row.jur_info_bic || '~' || pi_vendor_row.jur_info_inn,
                                    ''
                                )
        );
END;
$$;

/* ------------------------------------------------------------------------------------------------------------------------
	Функция триггера, которая вычисляет хешкод при добавлении и обновлении записей. */
CREATE OR REPLACE FUNCTION smfd_data.trg_func_t_vendor_iu_calc_hash() RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    NEW.hash_code := smfd_data.get_vendor_hashcode(NEW);
    RETURN NEW;
END;
$$;

/* ------------------------------------------------------------------------------------------------------------------------
	Собственно триггер, осуществляющий подсчет и пересчет хешкода. */
CREATE TRIGGER trg_t_vendors_insert_update
    BEFORE INSERT OR UPDATE
    ON smfd_data.t_vendors
    FOR EACH ROW
EXECUTE PROCEDURE smfd_data.trg_func_t_vendor_iu_calc_hash();

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Получеине id вендора */
CREATE OR REPLACE FUNCTION smfd_data.get_vendor_id(
    pi_vendor smfd_data.S_VENDOR /* вендор */
) RETURNS INT
    LANGUAGE plpgsql AS
$$
DECLARE
    po_vendor_id    INT;
    vendor_hashcode INT;
BEGIN
    vendor_hashcode := smfd_data.get_vendor_hashcode((NULL, pi_vendor.vendor_name, pi_vendor.call_center_phone,
                                                      pi_vendor.address_string, pi_vendor.jur_info_string,
                                                      pi_vendor.jur_info_rs,
                                                      pi_vendor.jur_info_ks, pi_vendor.jur_info_inn,
                                                      pi_vendor.jur_info_bank_name,
                                                      pi_vendor.jur_info_bic, 0) :: smfd_data.T_VENDORS);

    SELECT v.id
    INTO po_vendor_id
    FROM smfd_data.t_vendors v
    WHERE v.hash_code = vendor_hashcode
      AND coalesce(v.vendor_name, '') = coalesce(pi_vendor.vendor_name, '')
      AND coalesce(v.call_center_phone, '') = coalesce(pi_vendor.call_center_phone, '')
      AND coalesce(lower(v.address_string), '') = coalesce(lower(pi_vendor.address_string), '')
      AND coalesce(lower(v.jur_info_string), '') = coalesce(lower(pi_vendor.jur_info_string), '')
      AND coalesce(v.jur_info_rs, '') = coalesce(pi_vendor.jur_info_rs, '')
      AND coalesce(v.jur_info_ks, '') = coalesce(pi_vendor.jur_info_ks, '')
      AND coalesce(v.jur_info_inn, '') = coalesce(pi_vendor.jur_info_inn, '')
      AND coalesce(v.jur_info_bank_name, '') = coalesce(pi_vendor.jur_info_bank_name, '')
      AND coalesce(v.jur_info_bic, '') = coalesce(pi_vendor.jur_info_bic, '');

    IF po_vendor_id IS NULL
    THEN
        INSERT INTO smfd_data.t_vendors (vendor_name, call_center_phone, address_string,
                                         jur_info_string, jur_info_rs, jur_info_ks,
                                         jur_info_inn, jur_info_bank_name, jur_info_bic, hash_code)
        VALUES (pi_vendor.vendor_name, pi_vendor.call_center_phone, pi_vendor.address_string,
                pi_vendor.jur_info_string, pi_vendor.jur_info_rs, pi_vendor.jur_info_ks,
                pi_vendor.jur_info_inn, pi_vendor.jur_info_bank_name, pi_vendor.jur_info_bic, vendor_hashcode)
        RETURNING id INTO po_vendor_id;
    END IF;

    RETURN po_vendor_id;
END;
$$;

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Получение вендора по id */
CREATE OR REPLACE FUNCTION smfd_data.get_vendor_by_id(
    IN pi_vendor_id INT /* id вендора */
) RETURNS smfd_data.S_VENDOR
    LANGUAGE plpgsql AS
$$
DECLARE
    vendor_row    smfd_data.T_VENDORS;
    vendor_object smfd_data.S_VENDOR;
BEGIN
    SELECT *
    INTO vendor_row
    FROM smfd_data.t_vendors v
    WHERE v.id = pi_vendor_id;

    vendor_object.vendor_name := vendor_row.vendor_name;
    vendor_object.call_center_phone := vendor_row.call_center_phone;
    vendor_object.address_string := vendor_row.address_string;
    vendor_object.jur_info_string := vendor_row.jur_info_string;
    vendor_object.jur_info_rs := vendor_row.jur_info_rs;
    vendor_object.jur_info_ks := vendor_row.jur_info_ks;
    vendor_object.jur_info_inn := vendor_row.jur_info_inn;
    vendor_object.jur_info_bank_name := vendor_row.jur_info_bank_name;
    vendor_object.jur_info_bic := vendor_row.jur_info_bic;

    RETURN vendor_object;
END;
$$;