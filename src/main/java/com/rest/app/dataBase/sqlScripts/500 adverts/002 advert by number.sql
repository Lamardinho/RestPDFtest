CREATE TABLE smfd_advert.t_targeting_number_list
(
    id           SERIAL PRIMARY KEY                  NOT NULL,
    file_name    TEXT                                NOT NULL,
    description  TEXT                                NOT NULL,
    numbers_type INT       DEFAULT 0                 NOT NULL,
    user_id      INT                                 NOT NULL,
    load_date    TIMESTAMP DEFAULT current_timestamp NOT NULL,
    period_id    INT                                 NOT NULL,
    mrf_id       INT                                 NOT NULL,
    CONSTRAINT t_targeting_number_list_t_user_id_fk FOREIGN KEY (user_id) REFERENCES smfd_user.t_user (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_targeting_number_list_t_billing_period_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_targeting_number_list_t_mrf_fk FOREIGN KEY (mrf_id) REFERENCES td_mrf (mrf_id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON COLUMN smfd_advert.t_targeting_number_list.file_name IS 'Имя файла относительно директории хранения';
COMMENT ON COLUMN smfd_advert.t_targeting_number_list.description IS 'Описание файла';
COMMENT ON COLUMN smfd_advert.t_targeting_number_list.numbers_type IS 'Тип номеров, 1 = ЛС, 2 = услуга';
COMMENT ON COLUMN smfd_advert.t_targeting_number_list.user_id IS 'Пользователь, загрузивший файл';
COMMENT ON COLUMN smfd_advert.t_targeting_number_list.load_date IS 'Время загрузки файла';
COMMENT ON COLUMN smfd_advert.t_targeting_number_list.period_id IS 'Для какого периода был загружен список';
COMMENT ON COLUMN smfd_advert.t_targeting_number_list.mrf_id IS 'Для какого МРФ был загружен список';
COMMENT ON TABLE smfd_advert.t_targeting_number_list IS 'Список загруженных файлов с таргетированием по номерам';

CREATE TABLE smfd_advert.t_targeting_number_list_numbers
(
    num_list_id    INT  NOT NULL,
    svc_nls_number TEXT NOT NULL,
    CONSTRAINT t_targeting_number_list_numbers_num_list_id_svc_nls_number_pk PRIMARY KEY (num_list_id, svc_nls_number),
    CONSTRAINT t_targeting_number_list_numbers_t_targeting_number_list_id_fk FOREIGN KEY (num_list_id) REFERENCES smfd_advert.t_targeting_number_list (id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX t_targeting_number_list_numbers_num_list_id_svc_nls_number_uindex ON smfd_advert.t_targeting_number_list_numbers (num_list_id, svc_nls_number);
COMMENT ON COLUMN smfd_advert.t_targeting_number_list_numbers.num_list_id IS 'Ссылка на лист номеров';
COMMENT ON COLUMN smfd_advert.t_targeting_number_list_numbers.svc_nls_number IS 'Номер ЛС или услуги (тип в таблице листа)';
COMMENT ON TABLE smfd_advert.t_targeting_number_list_numbers IS 'Перечисление номеров услуг/лс по каждому загруженному листу';

CREATE TABLE smfd_advert.t_advert_target_by_numbers
(
    period_id       INT NOT NULL,
    forming_type_id INT NOT NULL,
    number_list_id  INT NOT NULL,
    advt_block      INT NOT NULL,
    advt_module     INT NOT NULL,
    region_id       INT NOT NULL,
    CONSTRAINT t_advert_target_by_numbers_period_id_forming_type_id_number_list_id_advt_block_pk PRIMARY KEY (period_id, forming_type_id, number_list_id, advt_block),
    CONSTRAINT t_advert_target_by_numbers_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advert_target_by_numbers_t_forming_type_id_fk FOREIGN KEY (forming_type_id) REFERENCES smfd_data.t_forming_type (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advert_target_by_numbers_t_targeting_number_list_id_fk FOREIGN KEY (number_list_id) REFERENCES smfd_advert.t_targeting_number_list (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advert_target_by_numbers_t_advt_block_id_fk FOREIGN KEY (advt_block) REFERENCES smfd_advert.t_advt_block (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advert_target_by_numbers_t_advt_modules_id_fk FOREIGN KEY (advt_module) REFERENCES smfd_advert.t_advt_modules (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_advert_target_by_numbers_td_region_fk FOREIGN KEY (region_id) REFERENCES td_region (region_id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON COLUMN smfd_advert.t_advert_target_by_numbers.period_id IS 'Ссфлка на рассчётный период';
COMMENT ON COLUMN smfd_advert.t_advert_target_by_numbers.forming_type_id IS 'Ссылка на тип формирования';
COMMENT ON COLUMN smfd_advert.t_advert_target_by_numbers.number_list_id IS 'Ссылка на список номеров';
COMMENT ON COLUMN smfd_advert.t_advert_target_by_numbers.advt_block IS 'Ссылка на рекламный блок';
COMMENT ON COLUMN smfd_advert.t_advert_target_by_numbers.advt_module IS 'Ссылка на рекламный модуль';
COMMENT ON COLUMN smfd_advert.t_advert_target_by_numbers.region_id IS 'Ссылка на конкретный регион';
COMMENT ON TABLE smfd_advert.t_advert_target_by_numbers IS 'Таблица настройки рекламы по номерам ЛС/услуг';

/* Добавление списка номеров лс/услуг. Внешней связи номера нет. */
CREATE OR REPLACE FUNCTION smfd_advert.upload_number_list(IN pi_file_name TEXT, /* имя файла */
                                                          IN pi_description TEXT, /* описание */
                                                          IN pi_numbers TEXT[], /* список номеров */
                                                          IN pi_numbers_type INT, /* тип */
                                                          IN pi_period_id INT, /* период */
                                                          IN pi_mrf_id INT, /* мрф */
                                                          IN pi_user_id INT, /* пользователь */
                                                          OUT po_result_code TEXT,
                                                          OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    list_id INT;
BEGIN
    PERFORM smfd_user.assert_user_permit(pi_user_id, pi_access_object := 'smfd_advert.load_number_list');

    INSERT INTO smfd_advert.t_targeting_number_list (file_name, description, numbers_type, user_id, load_date,
                                                     period_id, mrf_id)
    VALUES (pi_file_name, pi_description, pi_numbers_type, pi_user_id, current_timestamp, pi_period_id, pi_mrf_id)
    RETURNING id INTO list_id;

    INSERT INTO smfd_advert.t_targeting_number_list_numbers (num_list_id, svc_nls_number)
    SELECT DISTINCT ON (nums) list_id,
                              nums
    FROM unnest(pi_numbers) nums
    ON CONFLICT (num_list_id, svc_nls_number) DO NOTHING;

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

/*  */
CREATE OR REPLACE FUNCTION smfd_advert.get_number_lists(IN pi_do_load_numbers BOOLEAN, /*  */
                                                        OUT po_number_lists REFCURSOR, /*  */
                                                        OUT po_result_code TEXT,
                                                        OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN

    OPEN po_number_lists FOR
        SELECT lst.*,
               us.last_name || ' ' || us.first_name || ' ' || us.middle_name user_name,
               count(nums.svc_nls_number)                                    numbers_count,
               CASE
                   WHEN pi_do_load_numbers
                       THEN array_agg(nums.svc_nls_number)
                   ELSE ARRAY [] :: TEXT[] END                               numbers
        FROM smfd_advert.t_targeting_number_list lst
                 JOIN smfd_user.t_user us ON lst.user_id = us.id
                 JOIN smfd_advert.t_targeting_number_list_numbers nums ON lst.id = nums.num_list_id
        GROUP BY lst.id, us.id;

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

/* Получение списка тергетинга по номерам (не используется) */
CREATE OR REPLACE FUNCTION smfd_advert.get_targeting_by_numbers_all(IN pi_period_id INT, /* период */
                                                                    IN pi_forming_type_id INT, /* тип формирования */
                                                                    OUT po_targeting_list REFCURSOR, /* курсор с результатом */
                                                                    OUT po_result_code TEXT,
                                                                    OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN po_targeting_list FOR
        SELECT list.id                                                       list_id,
               list.description                                              list_description,
               list.file_name                                                list_file_name,
               list.numbers_type                                             list_numbers_type,
               list.load_date                                                list_load_date,
               count(nums.svc_nls_number)                                    list_numbers_count,
               us.last_name || ' ' || us.first_name || ' ' || us.middle_name list_user_name,
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
                                ), NULL)                                     advt_settings
        FROM smfd_advert.t_targeting_number_list list
                 JOIN smfd_user.t_user us ON list.user_id = us.id
                 JOIN smfd_advert.t_advert_target_by_numbers tn ON list.id = tn.number_list_id
            AND tn.period_id = pi_period_id
            AND tn.forming_type_id = pi_forming_type_id
                 JOIN smfd_advert.t_targeting_number_list_numbers nums ON list.id = nums.num_list_id
                 LEFT JOIN smfd_advert.t_advt_block block ON block.id = tn.advt_block
                 LEFT JOIN smfd_advert.t_advt_modules module ON module.id = tn.advt_module
        GROUP BY list.id, us.id
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

/* Добавление, удаление записи по таргетировании по номерам */
CREATE OR REPLACE FUNCTION smfd_advert.edit_targeting_by_numbers(IN pi_period_id INT, /* id периода */
                                                                 IN pi_forming_type_id INT, /* id типа формирования */
                                                                 IN pi_numbers_list_id INT, /* id номер набора */
                                                                 IN pi_block_id INT, /* id блока */
                                                                 IN pi_module_id INT, /* id модуля */
                                                                 IN pi_user_id INT, /* id пользователя */
                                                                 IN pi_region_id INT, /* id региона */
                                                                 OUT po_result_code TEXT,
                                                                 OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    PERFORM smfd_user.assert_user_permit(pi_user_id, pi_access_object := 'smfd_advert.edit_targeting_by_numbers');

    IF (pi_module_id IS NULL)
    THEN
        PERFORM audit(pi_user_id, 'DELETE TARGETING BY NUMBERS',
                      'pi_numbers_list_id=' || pi_numbers_list_id || ', pi_forming_type_id=' || pi_forming_type_id ||
                      ', pi_period_id=' || pi_period_id);
        DELETE
        FROM smfd_advert.t_advert_target_by_numbers
        WHERE number_list_id = pi_numbers_list_id
          AND forming_type_id = pi_forming_type_id
          AND period_id = pi_period_id
          AND advt_block = pi_block_id;
        po_result_code := 0;
        po_result_message := 'ok';
        RETURN;
    END IF;

    INSERT INTO smfd_advert.t_advert_target_by_numbers (period_id, forming_type_id, number_list_id, advt_block,
                                                        advt_module, region_id)
    VALUES (pi_period_id, pi_forming_type_id, pi_numbers_list_id, pi_block_id, pi_module_id, pi_region_id)
    ON CONFLICT (period_id, number_list_id, forming_type_id, advt_block)
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

/* Получение курсора со списком таргетинга по номерам */
CREATE OR REPLACE FUNCTION smfd_advert.get_lists(IN pi_period_id INT, /* период */
                                                 IN pi_mrf_id INT, /* мрф */
                                                 OUT po_lists REFCURSOR, /* курсор с результатом */
                                                 OUT po_result_code TEXT,
                                                 OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN po_lists for
        SELECT id,
               file_name,
               numbers_type,
               user_id,
               load_date,
               period_id,
               mrf_id,
               (select count(*) from smfd_advert.t_targeting_number_list_numbers n where n.num_list_id = lst.id) as cnt
        FROM smfd_advert.t_targeting_number_list lst
        WHERE lst.period_id = pi_period_id
          and lst.mrf_id = pi_mrf_id;

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

/* Получение списка  */
CREATE OR REPLACE FUNCTION smfd_advert.get_distributed_lists(IN pi_period_id INT, /* период */
                                                             IN pi_mrf_id INT, /* мрф */
                                                             OUT po_lists REFCURSOR, /* курсор */
                                                             OUT po_result_code TEXT,
                                                             OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN po_lists for
        select lst.id,
               lst.file_name,
               lst.period_id,
               lst.load_date,
               lst.numbers_type,
               (select count(*)
                from smfd_advert.t_targeting_number_list_numbers nums
                where nums.num_list_id = lst.id) as count,
               trg.region_id,
               trg.forming_type_id,
               trg.advt_block,
               trg.advt_module
        from smfd_advert.t_targeting_number_list lst
                 join smfd_advert.t_advert_target_by_numbers trg on lst.id = trg.number_list_id
                 join smfd_advert.t_advt_block ad_block on ad_block.id = trg.advt_block
                 join smfd_advert.t_advt_modules ad_module on ad_module.id = trg.advt_module
        where lst.mrf_id = pi_mrf_id
          and lst.period_id = pi_period_id;

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

/* Удаление набора рекалмы для таргетирования по номерам */
CREATE OR REPLACE FUNCTION smfd_advert.delete_distributed_lists(IN pi_list_id INT, /* id набора */
                                                                OUT po_result_code TEXT,
                                                                OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    delete from smfd_advert.t_advert_target_by_numbers trg where trg.number_list_id = pi_list_id;

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

/*  */
CREATE OR REPLACE FUNCTION smfd_advert.delete_number_lists(IN pi_list_id INT, /* id набора */
                                                           OUT po_result_code TEXT,
                                                           OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    delete from smfd_advert.t_targeting_number_list lst where lst.id = pi_list_id;

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