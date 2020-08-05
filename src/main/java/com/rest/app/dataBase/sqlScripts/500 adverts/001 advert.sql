-- region <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<BLOCK
CREATE TABLE IF NOT EXISTS smfd_advert.t_advt_block
(
    id                     SERIAL PRIMARY KEY NOT NULL,
    advt_block_code        VARCHAR(128)       NOT NULL,
    advt_block_description VARCHAR(128)       NOT NULL
);
COMMENT ON COLUMN smfd_advert.t_advt_block.id IS 'Идентификатор записи';
COMMENT ON COLUMN smfd_advert.t_advt_block.advt_block_code IS 'Идентификатор блока';
COMMENT ON COLUMN smfd_advert.t_advt_block.advt_block_description IS 'Имя блока';
COMMENT ON TABLE smfd_advert.t_advt_block IS 'Таблица рекламных блоков';
CREATE UNIQUE INDEX advt_block_advt_block_code_uindex ON smfd_advert.t_advt_block (advt_block_code);

/* Добавление или удаление рекламных блоков */
CREATE OR REPLACE FUNCTION smfd_advert.edit_advert_block(IN pi_block_code TEXT, /* Код блока */
                                                         IN pi_block_description TEXT, /* Описание блока */
                                                         IN pi_do_delete BOOL, /* нужно ли удалить */
                                                         IN pi_user_id INT, /* id пользователя */
                                                         OUT po_result_code TEXT,
                                                         OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    PERFORM smfd_user.assert_user_permit(pi_user_id, pi_access_object := 'smfd_advert.edit_advert_block');

    IF (pi_do_delete)
    THEN
        DELETE
        FROM smfd_advert.t_advt_block
        WHERE advt_block_code = pi_block_code;
        PERFORM audit(pi_user_id, 'DELETE ADVERT BLOCK', 'block_code=' || pi_block_code);
        po_result_code := 0;
        po_result_message := 'ok';
        RETURN;
    END IF;

    INSERT INTO smfd_advert.t_advt_block (advt_block_code, advt_block_description)
    VALUES (pi_block_code, pi_block_description)
    ON CONFLICT (advt_block_code) DO UPDATE SET advt_block_description = pi_block_description;

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
-- endregion <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<BLOCK

-- region <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<MODULE
CREATE TABLE smfd_advert.t_advt_modules
(
    id   SERIAL PRIMARY KEY NOT NULL,
    code VARCHAR(128)       NOT NULL,
    data TEXT               NOT NULL,
    type INT                NOT NULL DEFAULT 0
);
COMMENT ON TABLE smfd_advert.t_advt_modules IS 'Рекламные модули (изображения и тексты)';
COMMENT ON COLUMN smfd_advert.t_advt_modules.id IS 'Идентификатор модуля';
COMMENT ON COLUMN smfd_advert.t_advt_modules.code IS 'Отображаемый код модуля';
COMMENT ON COLUMN smfd_advert.t_advt_modules.data IS 'Данные (текст или ссылка)';
COMMENT ON COLUMN smfd_advert.t_advt_modules.type IS 'Тип модуля (0 = текст, 1 = изображение)';

CREATE UNIQUE INDEX t_advt_modules_code_uindex ON smfd_advert.t_advt_modules (code);

/* ----------------------------------------------------------------------------------- */
/* Добавление рекламных модулей */
CREATE OR REPLACE FUNCTION smfd_advert.edit_advt_module(IN pi_module_type INT, /* тип модуля (текст, картинка) */
                                                        IN pi_modile_code TEXT, /* Код модуля */
                                                        IN pi_module_data TEXT, /* Содержание модуля (ссылка на файл, сообщение) */
                                                        IN pi_user_id INT, /* id юзера */
                                                        OUT po_result_code TEXT,
                                                        OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    PERFORM smfd_user.assert_user_permit(pi_user_id, pi_access_object := 'smfd_advert.edit_advt_module');

    IF (pi_module_data IS NULL OR pi_module_data = '')
    THEN
        PERFORM audit(pi_user_id, 'DELETE ADVERT MODULE', 'pi_modile_code=' || pi_modile_code);
        DELETE
        FROM smfd_advert.t_advt_modules
        WHERE code = pi_modile_code
          AND type = pi_module_type;
        po_result_code := 0;
        po_result_message := 'ok';
        RETURN;
    END IF;

    INSERT INTO smfd_advert.t_advt_modules (code, data, type)
    VALUES (pi_modile_code, pi_module_data, pi_module_type)
    ON CONFLICT (code) DO UPDATE SET data = pi_module_data, type = pi_module_type;

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
-- endregion <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<MODULE

/* ------------------------------------------------------------------------------------------------ */
--  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<TARGET_TEMPLATE
CREATE TABLE smfd_advert.t_advert_template
(
    period_id       INT NOT NULL,
    forming_type_id INT NOT NULL,
    region_id       INT NOT NULL,
    advt_block      INT NOT NULL,
    CONSTRAINT t_advt_tmpl_by_region_region_id_period_id_forming_type_id_advt_block_pk PRIMARY KEY (period_id, forming_type_id, region_id, advt_block),
    CONSTRAINT t_advt_tmpl_by_region_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advt_tmpl_by_region_t_forming_type_id_fk FOREIGN KEY (forming_type_id) REFERENCES smfd_data.t_forming_type (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advt_tmpl_by_region_td_region_region_id_fk FOREIGN KEY (region_id) REFERENCES public.td_region (region_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advt_tmpl_by_region_t_advt_block_id_fk FOREIGN KEY (advt_block) REFERENCES smfd_advert.t_advt_block (id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON COLUMN smfd_advert.t_advert_template.region_id IS 'Ссылка на регион';
COMMENT ON COLUMN smfd_advert.t_advert_template.period_id IS 'Ссылка на период';
COMMENT ON COLUMN smfd_advert.t_advert_template.forming_type_id IS 'Ссылка на тип формирования';
COMMENT ON COLUMN smfd_advert.t_advert_template.advt_block IS 'Ссылка на рекламный блок (место в PDF)';
COMMENT ON TABLE smfd_advert.t_advert_template IS 'Таблица шаблонов рекламных блоков, используется для фитрации при таргетировании по регионам, городам, спискам';


-- region <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<TARGET_BY_REGION
CREATE TABLE smfd_advert.t_advert_target_by_region
(
    period_id       INT NOT NULL,
    forming_type_id INT NOT NULL,
    region_id       INT NOT NULL,
    advt_block      INT NOT NULL,
    advt_module     INT NOT NULL,
    CONSTRAINT t_advt_by_region_region_id_period_id_forming_type_id_advt_block_pk PRIMARY KEY (period_id, forming_type_id, region_id, advt_block),
    CONSTRAINT t_advt_by_region_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advt_by_region_t_forming_type_id_fk FOREIGN KEY (forming_type_id) REFERENCES smfd_data.t_forming_type (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advt_by_region_td_region_region_id_fk FOREIGN KEY (region_id) REFERENCES public.td_region (region_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advt_by_region_t_advt_block_id_fk FOREIGN KEY (advt_block) REFERENCES smfd_advert.t_advt_block (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advt_by_region_t_advt_modules_id_fk FOREIGN KEY (advt_module) REFERENCES smfd_advert.t_advt_modules (id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON COLUMN smfd_advert.t_advert_target_by_region.region_id IS 'Ссылка на регион';
COMMENT ON COLUMN smfd_advert.t_advert_target_by_region.period_id IS 'Ссылка на период';
COMMENT ON COLUMN smfd_advert.t_advert_target_by_region.forming_type_id IS 'Ссылка на тип формирования';
COMMENT ON COLUMN smfd_advert.t_advert_target_by_region.advt_block IS 'Ссылка на рекламный блок (место в PDF)';
COMMENT ON COLUMN smfd_advert.t_advert_target_by_region.advt_module IS 'Ссылка на рекламный модуль (картинка или текст)';
COMMENT ON TABLE smfd_advert.t_advert_target_by_region IS 'Таблица таргетирования по-умолчанию. Содержит настройки для регионов и/или МРФ.';

CREATE TABLE smfd_advert.t_phone_in_bills
(
    id             SERIAL PRIMARY KEY NOT NULL,
    period_id      INT                NOT NULL,
    region_id      INT                NOT NULL,
    phone          varchar,
    account_number varchar,
    anp_fio        text,
    anp_sum_text   text,
    CONSTRAINT t_phone_in_bills_t_period_fk foreign key (period_id) references smfd_data.t_billing_period (id),
    CONSTRAINT t_phone_in_bills_td_region_fk foreign key (region_id) references td_region (region_id)
);
comment on column smfd_advert.t_phone_in_bills.period_id is 'Ссылка на период';
comment on column smfd_advert.t_phone_in_bills.region_id is 'Ссылка на регион';
comment on column smfd_advert.t_phone_in_bills.phone is 'новый телефон';
comment on column smfd_advert.t_phone_in_bills.account_number is 'Номер лицевого счета';
comment on column smfd_advert.t_phone_in_bills.anp_fio is 'Текстовое поле (для обращения к абоненту)';
comment on column smfd_advert.t_phone_in_bills.anp_sum_text is 'Текстовое поле (для указания нового номера телефона)';
comment on table smfd_advert.t_phone_in_bills is 'данные персональных обращений в счете';
CREATE UNIQUE INDEX phone_in_bills_uindex ON smfd_advert.t_phone_in_bills (period_id, region_id, account_number);


/* Добавление, удаление записи таргетинг по регионам */
CREATE OR REPLACE FUNCTION smfd_advert.edit_targeting_by_region(IN pi_period_id INT, /* период */
                                                                IN pi_forming_type_id INT, /* тип формирования */
                                                                IN pi_region_id INT, /* регион */
                                                                IN pi_block_id INT, /* блок */
                                                                IN pi_module_id INT, /* модуль */
                                                                IN pi_user_id INT, /* пользователь */
                                                                OUT po_result_code TEXT,
                                                                OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    PERFORM smfd_user.assert_user_permit(pi_user_id, pi_access_object := 'smfd_advert.edit_targeting_by_region');

    IF (pi_module_id IS NULL)
    THEN
        PERFORM audit(pi_user_id, 'DELETE TARGETING BY REGION',
                      'pi_region_id=' || pi_region_id || ', pi_forming_type_id=' || pi_forming_type_id ||
                      ', pi_period_id=' || pi_period_id);
        DELETE
        FROM smfd_advert.t_advert_target_by_region
        WHERE region_id = pi_region_id
          AND forming_type_id = pi_forming_type_id
          AND period_id = pi_period_id
          AND advt_block = pi_block_id;
        po_result_code := 0;
        po_result_message := 'ok';
        RETURN;
    END IF;

    INSERT INTO smfd_advert.t_advert_target_by_region (period_id, forming_type_id, region_id, advt_block, advt_module)
    VALUES (pi_period_id, pi_forming_type_id, pi_region_id, pi_block_id, pi_module_id)
    ON CONFLICT (period_id, region_id, forming_type_id, advt_block)
        DO UPDATE SET advt_module = pi_module_id;

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

/* Получения списка таргетирования по регионам по параметрам (период, мрф) */
CREATE OR REPLACE FUNCTION smfd_advert.get_targeting_by_region_all(IN pi_period_id INT, /* период */
                                                                   IN pi_forming_type_id INT, /* тип формирования */
                                                                   OUT po_targeting_list REFCURSOR, /* Курсор с результатом */
                                                                   OUT po_result_code TEXT,
                                                                   OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
BEGIN
    OPEN po_targeting_list FOR
        SELECT reg.region_id             region_id,
               reg.region_name           region_name,
               array_remove(array_agg(
                                    CASE
                                        WHEN block.id IS NULL
                                            THEN NULL
                                        ELSE (block.id,
                                              block.advt_block_code,
                                              block.advt_block_description,
                                              module.id,
                                              module.code,
                                              CASE module.type
                                                  WHEN 0
                                                      THEN 'TEXT'
                                                  WHEN 1
                                                      THEN 'IMAGE'
                                                  ELSE 'UNK' END,
                                              module.data) END
                                ), NULL) advt_settings
        FROM public.td_region reg
                 LEFT JOIN smfd_advert.t_advert_target_by_region tar_region ON tar_region.period_id = pi_period_id
            AND tar_region.forming_type_id = pi_forming_type_id
            AND tar_region.region_id = reg.region_id
                 LEFT JOIN smfd_advert.t_advt_block block ON block.id = tar_region.advt_block
                 LEFT JOIN smfd_advert.t_advt_modules module ON module.id = tar_region.advt_module
        WHERE reg.region_id > 0
        GROUP BY reg.region_id
        ORDER BY reg.region_id;

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
-- endregion <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<TARGET_BY_REGION

-- region <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<TARGET_BY_CITY
CREATE TABLE IF NOT EXISTS smfd_advert.t_targeting_city_list
(
    id          SERIAL PRIMARY KEY NOT NULL,
    description TEXT
);
COMMENT ON COLUMN smfd_advert.t_targeting_city_list.id IS 'Идентификатор списка';
COMMENT ON COLUMN smfd_advert.t_targeting_city_list.description IS 'Человековое описание';
COMMENT ON TABLE smfd_advert.t_targeting_city_list IS 'Списки населенных пунктов для таргетинга "по городу".';

CREATE TABLE IF NOT EXISTS smfd_advert.t_targeting_city_list_cities
(
    city_list_id INT NOT NULL,
    city_id      INT NOT NULL,
    CONSTRAINT t_targeting_cities_city_list_id_city_id_pk PRIMARY KEY (city_list_id, city_id),
    CONSTRAINT t_targeting_cities_t_city_id_fk FOREIGN KEY (city_id) REFERENCES public.t_city (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_targeting_cities_t_targeting_city_list_id_fk FOREIGN KEY (city_list_id) REFERENCES smfd_advert.t_targeting_city_list (id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON COLUMN smfd_advert.t_targeting_city_list_cities.city_list_id IS 'Ссылка на лист городов';
COMMENT ON COLUMN smfd_advert.t_targeting_city_list_cities.city_id IS 'Ссылка на населенный пункт';
COMMENT ON TABLE smfd_advert.t_targeting_city_list_cities IS 'Соотношение списка городов к населенным пунктам для таргетинга "по городу"';

/* Получение списка городов для таргетинга */
CREATE OR REPLACE FUNCTION smfd_advert.get_city_lists(OUT po_city_lists REFCURSOR, /* курсор со список городов в таргетинге */
                                                      OUT po_result_code TEXT,
                                                      OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN po_city_lists FOR
        SELECT lists.id          list_id,
               lists.description list_description,
               array_agg((
                          city.id,
                          city.city_type,
                          city.city_name,
                          city.region_id,
                          reg.region_name,
                          mrf.mrf_code,
                          mrf.mrf_name
                   ))            cities
        FROM smfd_advert.t_targeting_city_list lists
                 JOIN smfd_advert.t_targeting_city_list_cities cities ON cities.city_list_id = lists.id
                 JOIN public.t_city city ON cities.city_id = city.id
                 JOIN public.td_region reg ON reg.region_id = city.region_id
                 JOIN public.td_mrf mrf ON mrf.mrf_id = reg.mrf_id
        GROUP BY lists.id;

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

/* Создание набора городов для таргетинга */
CREATE OR REPLACE FUNCTION smfd_advert.edit_city_list(IN pi_list_id INT, /* id набора (если пустой, создаем новый) */
                                                      IN pi_list_description TEXT, /* Описание набора */
                                                      IN pi_cities_list INT[], /* Список городов входящих в этот набор */
                                                      OUT po_list_id INT, /* id листа */
                                                      OUT po_result_code TEXT,
                                                      OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    list_id INT := pi_list_id;
BEGIN
    -- Если номер листа не передан - надо создать новый.
    IF pi_list_id IS NULL
    THEN
        INSERT INTO smfd_advert.t_targeting_city_list (description)
        VALUES (pi_list_description)
        RETURNING id INTO list_id;
    END IF;
    -- Удаляем все города из листа
    DELETE
    FROM smfd_advert.t_targeting_city_list_cities
    WHERE city_list_id = list_id;
    -- Добавляем все города из входящего массива
    INSERT INTO smfd_advert.t_targeting_city_list_cities (city_list_id, city_id)
    SELECT DISTINCT ON (c_id) list_id,
                              c_id
    FROM unnest(pi_cities_list) c_id;

    po_list_id := list_id;
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

CREATE TABLE IF NOT EXISTS smfd_advert.t_advert_target_by_city
(
    period_id       INT NOT NULL,
    forming_type_id INT NOT NULL,
    city_list_id    INT NOT NULL,
    advt_block      INT NOT NULL,
    advt_module     INT NOT NULL,
    CONSTRAINT t_advert_target_by_city_period_id_forming_type_id_city_id_advt_block_pk PRIMARY KEY (period_id, forming_type_id, city_list_id, advt_block),
    CONSTRAINT t_advert_target_by_city_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advert_target_by_city_t_forming_type_id_fk FOREIGN KEY (forming_type_id) REFERENCES smfd_data.t_forming_type (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advert_target_by_city_t_city_id_fk FOREIGN KEY (city_list_id) REFERENCES smfd_advert.t_targeting_city_list (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advert_target_by_city_t_advt_block_id_fk FOREIGN KEY (advt_block) REFERENCES smfd_advert.t_advt_block (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advert_target_by_city_t_advt_modules_id_fk FOREIGN KEY (advt_module) REFERENCES smfd_advert.t_advt_modules (id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON COLUMN smfd_advert.t_advert_target_by_city.period_id IS 'Ссылка на период';
COMMENT ON COLUMN smfd_advert.t_advert_target_by_city.forming_type_id IS 'Ссылка на тип формирования';
COMMENT ON COLUMN smfd_advert.t_advert_target_by_city.city_list_id IS 'Ссылка на список городов';
COMMENT ON COLUMN smfd_advert.t_advert_target_by_city.advt_block IS 'Ссылка на рекламный блок (место в PDF)';
COMMENT ON COLUMN smfd_advert.t_advert_target_by_city.advt_module IS 'Ссылка на рекламный модуль (картинка или текст)';
COMMENT ON TABLE smfd_advert.t_advert_target_by_city IS 'Таблица таргетирования по городам. Приоритет выше регионального таргетирования.';

/* Получение всего списка таргетинга по городам */
CREATE OR REPLACE FUNCTION smfd_advert.get_targeting_by_city_all(IN pi_period_id INT, /* период */
                                                                 IN pi_forming_type_id INT, /* тип формирования */
                                                                 OUT po_targeting_list REFCURSOR, /* результат */
                                                                 OUT po_result_code TEXT,
                                                                 OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
BEGIN
    OPEN po_targeting_list FOR
        SELECT list.id                            list_id,
               list.description                   list_description,
               array_remove(array_agg(DISTINCT
                                      CASE
                                          WHEN block.id IS NULL
                                              THEN NULL
                                          ELSE (block.id,
                                                block.advt_block_code,
                                                block.advt_block_description,
                                                module.id,
                                                module.code,
                                                CASE module.type
                                                    WHEN 0
                                                        THEN 'TEXT'
                                                    WHEN 1
                                                        THEN 'IMAGE'
                                                    ELSE 'UNK' END,
                                                module.data) END
                                ), NULL)          advt_settings,
               array_agg(DISTINCT (city.id,
                                   city.city_type,
                                   city.city_name,
                                   city.region_id,
                                   reg.region_name,
                                   mrf.mrf_code,
                                   mrf.mrf_name)) cities
        FROM smfd_advert.t_targeting_city_list list
                 JOIN smfd_advert.t_targeting_city_list_cities cities ON cities.city_list_id = list.id
                 JOIN public.t_city city ON cities.city_id = city.id
                 JOIN public.td_region reg ON reg.region_id = city.region_id
                 JOIN public.td_mrf mrf ON mrf.mrf_id = reg.mrf_id
                 LEFT JOIN smfd_advert.t_advert_target_by_city tc ON tc.city_list_id = list.id
            AND tc.period_id = pi_period_id
            AND tc.forming_type_id = pi_forming_type_id
                 LEFT JOIN smfd_advert.t_advt_block block ON block.id = tc.advt_block
                 LEFT JOIN smfd_advert.t_advt_modules module ON module.id = tc.advt_module
        GROUP BY list.id
        ORDER BY list.id;

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

/* Добавление, удаление записи по таргетировании по городам */
CREATE OR REPLACE FUNCTION smfd_advert.edit_targeting_by_city(IN pi_period_id INT, /* id периода */
                                                              IN pi_forming_type_id INT, /* id типа формирования */
                                                              IN pi_city_list_id INT, /* id списка городов */
                                                              IN pi_block_id INT, /* ссылка на id блока */
                                                              IN pi_module_id INT, /* ссылка на id модуля */
                                                              IN pi_user_id INT, /* id пользователя */
                                                              OUT po_result_code TEXT,
                                                              OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
BEGIN
    PERFORM smfd_user.assert_user_permit(pi_user_id, pi_access_object := 'smfd_advert.edit_targeting_by_city');

    IF (pi_module_id IS NULL)
    THEN
        PERFORM audit(pi_user_id, 'DELETE TARGETING BY CITY',
                      'pi_city_list_id=' || pi_city_list_id || ', pi_forming_type_id=' || pi_forming_type_id ||
                      ', pi_period_id=' || pi_period_id);
        DELETE
        FROM smfd_advert.t_advert_target_by_city
        WHERE city_list_id = pi_city_list_id
          AND forming_type_id = pi_forming_type_id
          AND period_id = pi_period_id
          AND advt_block = pi_block_id;
        po_result_code := 0;
        po_result_message := 'ok';
        RETURN;
    END IF;

    INSERT INTO smfd_advert.t_advert_target_by_city (period_id, forming_type_id, city_list_id, advt_block, advt_module)
    VALUES (pi_period_id, pi_forming_type_id, pi_city_list_id, pi_block_id, pi_module_id)
    ON CONFLICT (period_id, city_list_id, forming_type_id, advt_block)
        DO UPDATE SET advt_module = pi_module_id;

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

-- endregion <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<TARGET_BY_CITY

/* ------------------------------------------------------------------------------------------------ */
/* Получение курсоров со списком блоков, модулей и типов формирования */
CREATE OR REPLACE FUNCTION smfd_advert.get_advert_model(OUT po_advt_blcoks REFCURSOR /* Список рекламных блоков (ADVT_BLOCK_ID, ADVT_BLOCK_DESC) */,
                                                        OUT po_advt_modules REFCURSOR /* Список модулей */,
                                                        OUT po_forming_types REFCURSOR /* Список типов формирования (FT_ID, FT_CODE, FT_NAME) */,
                                                        OUT po_result_code TEXT,
                                                        OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    /* ---- Рекламные блоки */
    OPEN po_advt_blcoks FOR
        SELECT ab.id                     ADVT_BLOCK_ID,
               ab.advt_block_code        ADVT_BLOCK_CODE,
               ab.advt_block_description ADVT_BLOCK_DESC
        FROM smfd_advert.t_advt_block ab;

    /* ---- Рекламные модули */
    OPEN po_advt_modules FOR
        SELECT m.id   ADVT_MODULE_ID,
               m.code ADVT_MODULE_CODE,
               m.data ADVT_MODULE_DATA,
               m.type ADVT_MODULE_TYPE
        FROM smfd_advert.t_advt_modules m;

    /* ---- Типы формирования */
    OPEN po_forming_types FOR
        SELECT ft.id           FT_ID,
               ft.code         FT_CODE,
               ft.adapter_name FT_ADAPTER_NAME,
               ft.mrf_id       FT_MRF_ID
        FROM smfd_data.t_forming_type ft;

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

/* Получение полного списка с типами формирования */
CREATE OR REPLACE FUNCTION smfd_advert.get_ft(IN pi_mrf_id INT, /* мрф */
                                              OUT po_forming_types REFCURSOR, /* курсор с типами формирования */
                                              OUT po_result_code TEXT,
                                              OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    IF pi_mrf_id <> 0 THEN
        OPEN po_forming_types FOR
            SELECT ft.id           FT_ID,
                   ft.code         FT_CODE,
                   ft.adapter_name FT_ADAPTER_NAME,
                   ft.mrf_id       FT_MRF_ID
            FROM smfd_data.t_forming_type ft
            WHERE ft.mrf_id = pi_mrf_id;
    ELSE
        OPEN po_forming_types FOR
            SELECT ft.id           FT_ID,
                   ft.code         FT_CODE,
                   ft.adapter_name FT_ADAPTER_NAME,
                   ft.mrf_id       FT_MRF_ID
            FROM smfd_data.t_forming_type ft;
    END IF;

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

/* ------------------------------------------------------------------------------------------------ */
/* Получение рекламных шаблонов*/
CREATE OR REPLACE FUNCTION smfd_advert.get_advert_templates(pi_period_id integer, /* ссылка на период */
                                                            pi_forming_type_id integer, /* ссылка на тип формирования */
                                                            pi_mrf_id integer, /* ссылка на МРФ */
                                                            OUT po_advt_tmpl REFCURSOR /* Список рекламных блоков (ADVT_BLOCK_ID, ADVT_BLOCK_DESC) */,
                                                            OUT po_result_code TEXT,
                                                            OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    /* ---- Рекламные блоки */
    OPEN po_advt_tmpl FOR
        select adv_t.advt_block,
               ab.advt_block_code,
               ab.advt_block_description,
               reg.region_id
        from smfd_advert.t_advert_template adv_t
                 join smfd_data.t_forming_type ft on adv_t.forming_type_id = ft.id
                 join smfd_data.t_billing_period bp on adv_t.period_id = bp.id
                 join td_region reg on (adv_t.region_id = reg.region_id)
                 join smfd_advert.t_advt_block ab on adv_t.advt_block = ab.id
        where ft.id = pi_forming_type_id
          and bp.id = pi_period_id
          and reg.mrf_id = pi_mrf_id;

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


/* ------------------------------------------------------------------------------------------------ */
/* удаление рекламных шаблонов*/
CREATE OR REPLACE FUNCTION smfd_advert.delete_advert_template(pi_period_id integer, /* ссылка на период */
                                                              pi_forming_type_id integer, /* ссылка на тип формирования */
                                                              pi_region_id integer, /* ссылка на регион */
                                                              pi_block_id integer, /* ссылка на блок */
                                                              OUT po_result_code TEXT,
                                                              OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN

    -- чистка настроенной по удаляемому блоку рекламы по регионам
    delete
    from smfd_advert.t_advert_target_by_region ad_reg
    where ad_reg.forming_type_id = pi_forming_type_id
      and ad_reg.period_id = pi_period_id
      and ad_reg.region_id = pi_region_id
      and ad_reg.advt_block = pi_block_id;

    -- чистка настроенной по удаляемому блоку рекламы по городам
    delete
    from smfd_advert.t_advert_target_by_city ad_city
    where ad_city.forming_type_id = pi_forming_type_id
      and ad_city.period_id = pi_period_id
      and ad_city.city_list_id in
          (select clist.id
           from smfd_advert.t_targeting_city_list clist
                    join smfd_advert.t_targeting_city_list_cities cities on clist.id = cities.city_list_id
                    join t_city city on cities.city_id = city.id
           where city.region_id = pi_region_id
          )
      and ad_city.advt_block = pi_block_id;

    -- чистка настроенной по удаляемому блоку рекламы по списком номеров
    delete
    from smfd_advert.t_advert_target_by_numbers ad_nums
    where ad_nums.forming_type_id = pi_forming_type_id
      and ad_nums.period_id = pi_period_id
      and ad_nums.region_id = pi_region_id
      and ad_nums.advt_block = pi_block_id;

    delete
    from smfd_advert.t_advert_template adv_t
    where adv_t.forming_type_id = pi_forming_type_id
      and adv_t.period_id = pi_period_id
      and adv_t.region_id = pi_region_id
      and adv_t.advt_block = pi_block_id;

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

/* ------------------------------------------------------------------------------------------------ */
/* добавление рекламных шаблонов*/
CREATE OR REPLACE FUNCTION smfd_advert.add_advert_template(pi_period_id integer, /* ссылка на период */
                                                           pi_forming_type_id integer, /* ссылка на тип формирования */
                                                           pi_region_id integer, /* ссылка на регион */
                                                           pi_block_id integer, /* ссылка на блок */
                                                           OUT po_result_code TEXT,
                                                           OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN

    insert into smfd_advert.t_advert_template (forming_type_id,
                                               period_id,
                                               region_id,
                                               advt_block)
    values (pi_forming_type_id,
            pi_period_id,
            pi_region_id,
            pi_block_id);

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

/* копирование настроек и шаблонов с ранних периодов */
create or replace function smfd_advert.copy_adverts(in pi_period_id int, /* id периода */
                                                    OUT po_result_code TEXT,
                                                    OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
declare
    l_prev_period_id int;
begin
    -- определяем идентификатор предыдушего периода
    select bp.id
    into l_prev_period_id
    from smfd_data.t_billing_period bp
    where bp.date in (select (bp2.date - '1 month'::interval) :: date
                      from smfd_data.t_billing_period bp2
                      where bp2.id = pi_period_id);

    if l_prev_period_id is null then
        po_result_code := 1;
        po_result_message := 'previous period not found';
        RETURN;
    end if;
    -- копируем рекланые шаблоны с прошлого периода
    insert into smfd_advert.t_advert_template (forming_type_id, region_id, advt_block, period_id)
    SELECT ad.forming_type_id, ad.region_id, ad.advt_block, pi_period_id as period_id
    from smfd_advert.t_advert_template ad
    where ad.period_id = l_prev_period_id;

    -- копируем настройки для регионов с прошлого периода
    with prev_region_advert as (
        SELECT reg_adv.advt_block, reg_adv.region_id, reg_adv.forming_type_id, reg_adv.advt_module
        from smfd_advert.t_advert_target_by_region reg_adv
        where reg_adv.period_id = l_prev_period_id
    )
    insert
    into smfd_advert.t_advert_target_by_region (period_id, forming_type_id, region_id, advt_block, advt_module)
    SELECT pi_period_id as period_id, t.forming_type_id, t.region_id, t.advt_block, t.advt_module
    from prev_region_advert t;

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