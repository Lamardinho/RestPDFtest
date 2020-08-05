/* ------------------------------------------------------------------------------------------------------------------------
	Представление почтового адреса */
DROP TYPE IF EXISTS smfd_data.S_ADDRESS CASCADE;
CREATE TYPE smfd_data.S_ADDRESS AS
(
    zip_code    INT,
    region_id   INT,
    city_type   TEXT,
    city        TEXT,
    street_type TEXT,
    street      TEXT,
    house       TEXT,
    corpus      TEXT,
    flat        TEXT
);

/* ------------------------------------------------------------------------------------------------------------------------
	Таблица-справочник адресов. */
DROP TABLE IF EXISTS smfd_data.t_address CASCADE;
CREATE TABLE IF NOT EXISTS smfd_data.t_address
(
    id          SERIAL PRIMARY KEY NOT NULL,
    zip_code    INT,
    region_id   INT                NOT NULL DEFAULT 0,
    street_type VARCHAR,
    street      VARCHAR            NOT NULL,
    house       VARCHAR,
    corpus      VARCHAR,
    flat        VARCHAR /* для общаги может приходить "8 комната 1" */,
    hash_code   INT                NOT NULL DEFAULT 0,
    city_id     INT                NOT NULL,
    CONSTRAINT t_address_public_t_region_id_fk FOREIGN KEY (region_id) REFERENCES public.td_region (region_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_address_t_city_id_fk FOREIGN KEY (city_id) REFERENCES public.t_city (id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON COLUMN smfd_data.t_address.zip_code IS 'Почтовый индекс';
COMMENT ON COLUMN smfd_data.t_address.region_id IS 'Ссылка на регион';
COMMENT ON COLUMN smfd_data.t_address.city_id IS 'Ссылка на справочник городов';
COMMENT ON COLUMN smfd_data.t_address.street_type IS 'Тип улицы';
COMMENT ON COLUMN smfd_data.t_address.street IS 'Название улицы';
COMMENT ON COLUMN smfd_data.t_address.house IS 'Номер дома (без дробной части и корпуса)';
COMMENT ON COLUMN smfd_data.t_address.corpus IS 'Корпус или дробь';
COMMENT ON COLUMN smfd_data.t_address.flat IS 'Номер квартиры/офиса (если не указано - единственная)';
COMMENT ON TABLE smfd_data.t_address IS 'Справочник почтовых адресов';

CREATE UNIQUE INDEX t_address_zip_code_region_id_street_type_street_house_corpus_flat_city_id_uindex
    ON smfd_data.t_address (zip_code, region_id, street_type, street, house, corpus, flat, city_id);

/* Получаем id адреса */
CREATE OR REPLACE FUNCTION smfd_data.get_address_id(
    IN pi_address smfd_data.S_ADDRESS /* инфо об адресе */
)
    RETURNS INT
    LANGUAGE plpgsql AS
$$
DECLARE
    p_city    INT;
    p_address INT;
BEGIN
    -- todo пока там, потом можно на чистый sql заменить
    p_city := public.get_city_id((pi_address).city_type, (pi_address).city, (pi_address).region_id);

    SELECT address.id
    INTO p_address
    FROM smfd_data.t_address address
    WHERE address.zip_code = (pi_address).zip_code
      AND address.region_id = (pi_address).region_id
      AND address.street_type = (pi_address).street_type
      AND address.street = (pi_address).street
      AND address.house = (pi_address).house
      AND address.corpus = (pi_address).corpus
      AND address.flat = (pi_address).flat
      AND address.city_id = p_city;

    IF (p_address IS NULL)
    THEN
        INSERT INTO smfd_data.t_address (zip_code, region_id, street_type, street, house, corpus, flat, city_id)
        VALUES ((pi_address).zip_code,
                (pi_address).region_id,
                (pi_address).street_type,
                (pi_address).street,
                (pi_address).house,
                (pi_address).corpus,
                (pi_address).flat,
                p_city)
        ON CONFLICT (zip_code, region_id, street_type, street, house, corpus, flat, city_id)
            DO NOTHING
        RETURNING id INTO p_address;
    END IF;

    RETURN p_address;
END;
$$;