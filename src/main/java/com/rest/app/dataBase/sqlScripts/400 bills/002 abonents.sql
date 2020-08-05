/* ------------------------------------------------------------------------------------------------------------------------
	Представление абонента. */
DROP TYPE IF EXISTS smfd_data.S_ABONENT CASCADE;
CREATE TYPE smfd_data.S_ABONENT AS
(
    full_name         TEXT,
    abonent_type      INTEGER,
    address           smfd_data.S_ADDRESS,
    abonent_uniq_code TEXT,
    contact_phone     TEXT
);

/* ------------------------------------------------------------------------------------------------------------------------
	Таблица-справочник абонентов. */
DROP TABLE IF EXISTS smfd_data.t_bill_abonent CASCADE;
CREATE TABLE IF NOT EXISTS smfd_data.t_bill_abonent
(
    id                SERIAL PRIMARY KEY   NOT NULL,
    full_name         VARCHAR              NOT NULL,
    abonent_type      INT     DEFAULT 0    NOT NULL,
    address           INT,
    abonent_uniq_code VARCHAR,
    contact_phone     VARCHAR DEFAULT NULL NULL,
    CONSTRAINT t_bill_abonent_t_address_id_fk FOREIGN KEY (address) REFERENCES smfd_data.t_address (id) ON DELETE SET NULL ON UPDATE CASCADE
);
COMMENT ON COLUMN smfd_data.t_bill_abonent.id IS 'Идентификатор абонента';
COMMENT ON COLUMN smfd_data.t_bill_abonent.full_name IS 'Полное имя/название, включая титулы';
COMMENT ON COLUMN smfd_data.t_bill_abonent.abonent_type IS 'Тип абонента. 0 - ФЛ, 1 - ЮЛ, ...';
COMMENT ON COLUMN smfd_data.t_bill_abonent.address IS 'Ссылка на почтовый адрес';
COMMENT ON COLUMN smfd_data.t_bill_abonent.abonent_uniq_code IS 'Уникальный идентификатор абонента в АСР';
COMMENT ON COLUMN smfd_data.t_bill_abonent.contact_phone IS 'Контактный телефон абонента';
COMMENT ON TABLE smfd_data.t_bill_abonent IS 'Справочник абонентов, которым выставлены счета на оплату';

CREATE INDEX IF NOT EXISTS t_bill_abonent_address_index
    ON smfd_data.t_bill_abonent (address);
CREATE UNIQUE INDEX t_bill_abonent_full_name_abonent_type_address_abonent_uniq_code_contact_phone_uindex
    ON smfd_data.t_bill_abonent (full_name, abonent_type, address, abonent_uniq_code, contact_phone);

/* Получение id абонента */
CREATE OR REPLACE FUNCTION smfd_data.get_abonent_id(
    IN pi_abonent smfd_data.S_ABONENT /* абонент */
)
    RETURNS INT
    LANGUAGE plpgsql AS
$$
DECLARE
    p_address INT;
    p_abonent INT;
BEGIN
    p_address := smfd_data.get_address_id((pi_abonent).address);

    -- Получаем идентификатор абонента.
    SELECT abonent.id
    INTO p_abonent
    FROM smfd_data.t_bill_abonent abonent
    WHERE abonent.full_name = (pi_abonent).full_name
      AND abonent.abonent_type = (pi_abonent).abonent_type
      AND abonent.address = p_address
      AND abonent.abonent_uniq_code = (pi_abonent).abonent_uniq_code
      AND abonent.contact_phone = (pi_abonent).contact_phone;

    IF (p_abonent IS NULL)
    THEN
        INSERT INTO smfd_data.t_bill_abonent (full_name, abonent_type, address, abonent_uniq_code, contact_phone)
        VALUES ((pi_abonent).full_name,
                (pi_abonent).abonent_type,
                p_address,
                (pi_abonent).abonent_uniq_code,
                (pi_abonent).contact_phone)
        RETURNING id INTO p_abonent;
    END IF;

    RETURN p_abonent;
END;
$$;