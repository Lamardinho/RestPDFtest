/* ------------------------------------------------------------------------------------------------------------------------ */

CREATE TABLE if not exists smfd_data.t_forming_history
(
    id              SERIAL PRIMARY KEY NOT NULL,
    statistics_id   INT                NULL,
    is_mass_forming BOOLEAN            NOT NULL,
    is_test_forming BOOLEAN            NOT NULL
);
COMMENT ON COLUMN smfd_data.t_forming_history.statistics_id IS 'Ссылка на запись статистики в public.t_statistics';
COMMENT ON COLUMN smfd_data.t_forming_history.is_mass_forming IS 'Формирование было массовым или одиночным?';
COMMENT ON COLUMN smfd_data.t_forming_history.is_test_forming IS 'Формирование было тестовым и не затрагивает всю выборку?';
COMMENT ON TABLE smfd_data.t_forming_history IS 'История запусков формирования документов';

/* ------------------------------------------------------------------------------------------------------------------------ */

CREATE TABLE if not exists smfd_data.t_forming_publishing
(
    id           SERIAL PRIMARY KEY,
    history_id   INT       DEFAULT 1 NOT NULL,
    period_id    INT,
    region_id    INT,
    part_index   INT,
    file_name    TEXT,
    created_date TIMESTAMP DEFAULT current_timestamp,
    CONSTRAINT t_forming_publishing_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_forming_publishing_td_region_region_id_fk FOREIGN KEY (region_id) REFERENCES public.td_region (region_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_forming_publishing_t_forming_history_id_fk FOREIGN KEY (history_id) REFERENCES smfd_data.t_forming_history (id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON COLUMN smfd_data.t_forming_publishing.id IS 'Внутренний идентификатор';
COMMENT ON COLUMN smfd_data.t_forming_publishing.period_id IS 'Период, за который совершалось формирование';
COMMENT ON COLUMN smfd_data.t_forming_publishing.region_id IS 'Регион, для которого совершалось формирование';
COMMENT ON COLUMN smfd_data.t_forming_publishing.part_index IS 'Порядковый номер файла MBOX в рамках текущего формирования';
COMMENT ON COLUMN smfd_data.t_forming_publishing.file_name IS 'Имя созданного файла MBOX';
COMMENT ON COLUMN smfd_data.t_forming_publishing.created_date IS 'Время создания MBOX';
COMMENT ON TABLE smfd_data.t_forming_publishing IS 'Состояние создания MBOX после формирования документов';

CREATE UNIQUE INDEX if not exists t_forming_publishing_id_uindex ON smfd_data.t_forming_publishing (id);

/* ------------------------------------------------------------------------------------------------------------------------ */

CREATE TABLE if not exists smfd_data.t_forming_publishing_details_base
(
    period_id          INT,
    publishing_id      INT,
    bill_id            INT,
    message_id         TEXT,
    send_status        INT       DEFAULT 0,
    change_status_date TIMESTAMP DEFAULT NULL NULL,
    queue_id           TEXT      DEFAULT NULL NULL
) PARTITION BY LIST (period_id);
COMMENT ON COLUMN smfd_data.t_forming_publishing_details_base.period_id IS 'Ссылка на период. Оно же - ключ партицирования.';
COMMENT ON COLUMN smfd_data.t_forming_publishing_details_base.publishing_id IS 'Ссылка на таблицу smfd_data.t_forming_publishing';
COMMENT ON COLUMN smfd_data.t_forming_publishing_details_base.bill_id IS 'Ссылка на счёт к оплате';
COMMENT ON COLUMN smfd_data.t_forming_publishing_details_base.message_id IS 'Идентификатор почтового сообщения';
COMMENT ON COLUMN smfd_data.t_forming_publishing_details_base.send_status IS 'Статус отправки письма';
COMMENT ON COLUMN smfd_data.t_forming_publishing_details_base.change_status_date IS 'Время смены статуса (например, отправки, из логов)';
COMMENT ON TABLE smfd_data.t_forming_publishing_details_base IS 'Данные об отправки в письме каждого счёта на оплату';

--------------------
-- CREATE TABLE smfd_data_partitions.t_forming_publishing_details_2018_06 PARTITION OF smfd_data.t_forming_publishing_details_base FOR VALUES IN (2);
-- CREATE INDEX t_forming_publishing_details_2018_06_message_id_index ON smfd_data_partitions.t_forming_publishing_details_2018_06 (message_id);
-- ALTER TABLE smfd_data_partitions.t_forming_publishing_details_2018_06 ADD CONSTRAINT t_forming_publishing_details_2018_06_t_forming_publishing_id_fk FOREIGN KEY (publishing_part) REFERENCES smfd_data.t_forming_publishing (id) ON DELETE CASCADE ON UPDATE CASCADE;
-- ALTER TABLE smfd_data_partitions.t_forming_publishing_details_2018_06 ADD CONSTRAINT t_forming_publishing_details_2018_06_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE;
-- ALTER TABLE smfd_data_partitions.t_forming_publishing_details_2018_06 ADD CONSTRAINT t_forming_publishing_details_2018_06_t_bill_2018_06_id_fk FOREIGN KEY (bill_id) REFERENCES smfd_data_partitions.t_bill_2018_06 (id) ON DELETE CASCADE ON UPDATE CASCADE;
-- CREATE UNIQUE INDEX t_forming_publishing_details_2018_06_period_id_publishing_id_bill_id_uindex ON smfd_data_partitions.t_forming_publishing_details_2018_06 (period_id, publishing_id, bill_id);

/* ------------------------------------------------------------------------------------------------------------------------ */

create table if not exists smfd_data.t_bill_publish_status
(
    id               SERIAL PRIMARY KEY     NOT NULL,
    status           INT,
    status_change_dt TIMESTAMP DEFAULT NULL NULL,
    period_id        INT                    NOT NULL,
    forming_type_id  INT                    NOT NULL,
    region_id        INT                    NOT NULL,
    CONSTRAINT t_bill_publish_status_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_bill_publish_status_t_forming_type_fk FOREIGN KEY (forming_type_id) REFERENCES smfd_data.t_forming_type (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_bill_publish_status_td_region_fk FOREIGN KEY (region_id) REFERENCES td_region (region_id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON COLUMN smfd_data.t_bill_publish_status.status IS 'Статус публикации, 1 - опубликовано, все остально - не опубликовано';
COMMENT ON COLUMN smfd_data.t_bill_publish_status.status_change_dt IS 'Последняя дата изменения статуса публикации';
COMMENT ON COLUMN smfd_data.t_bill_publish_status.period_id IS 'Ссылка на период';
COMMENT ON COLUMN smfd_data.t_bill_publish_status.forming_type_id IS 'Ссылка на тип формирования';
COMMENT ON COLUMN smfd_data.t_bill_publish_status.region_id IS 'Ссылка на регион';
COMMENT ON TABLE smfd_data.t_bill_publish_status IS 'Данные о статусе публикации счетов для внешних систем';
CREATE UNIQUE INDEX t_bill_publish_status_uindex ON smfd_data.t_bill_publish_status (period_id, forming_type_id, region_id);


/* Сохранение информации о сформированных файлах (eml) в таблицу с ссылкой на историю формирования */
CREATE OR REPLACE FUNCTION smfd_data.save_publishing(IN pi_history_id INT, /* ссылка на историю формирования */
                                                     IN pi_period_id INT, /* период */
                                                     IN pi_region_id INT, /* регион */
                                                     IN pi_part_index INT, /* номер части (имя под-папки) */
                                                     IN pi_file_name TEXT, /* путь до папки с eml */
                                                     IN pi_user_id INT, /* пользователь */
                                                     IN pi_bill_message_ids S_KEY_VALUE_PAIR[], /* {'bill_id','message_id'} */
                                                     OUT po_result_code TEXT,
                                                     OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    pub_id INT;
BEGIN
    PERFORM smfd_user.assert_user_permit(pi_user_id, pi_access_object := 'smfd_data.save_publishing');

    INSERT INTO smfd_data.t_forming_publishing (history_id, period_id, region_id, part_index, file_name)
    VALUES (pi_history_id, pi_period_id, pi_region_id, pi_part_index, pi_file_name)
    RETURNING id INTO pub_id;

    IF (pub_id IS NOT NULL)
    THEN
        INSERT INTO smfd_data.t_forming_publishing_details_base (period_id, publishing_id, bill_id, message_id)
        SELECT pi_period_id,
               pub_id,
               (msgs :: S_KEY_VALUE_PAIR).key :: INT,
               (msgs :: S_KEY_VALUE_PAIR).value
        FROM unnest(pi_bill_message_ids) msgs;
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

drop type IF EXISTS smfd_data.S_PUBLISHING_INFO cascade;

CREATE TYPE smfd_data.S_PUBLISHING_INFO AS
(
    message_id    TEXT,
    queue_id      TEXT,
    complete_time TIMESTAMP,
    status_code   INT
);

/* Сохранения статуса отправка, после парсинга логов smtp-сервера */
CREATE OR REPLACE FUNCTION smfd_data.change_publishing_status(IN pi_log_file_date TIMESTAMP, /* дата изменения статуса */
                                                              IN pi_status_infos smfd_data.S_PUBLISHING_INFO[], /* информация о статусе */
                                                              OUT po_result_code TEXT,
                                                              OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    per_id INT;
BEGIN
    SELECT p.id
    INTO per_id
    FROM smfd_data.t_billing_period p
    WHERE pi_log_file_date BETWEEN p.date AND p.date + INTERVAL '1 month'
    LIMIT 1;

    IF (per_id IS NULL)
    THEN
        RAISE SQLSTATE '02000'
            USING MESSAGE = 'Period is not found for date ' || pi_log_file_date;
    END IF;

    UPDATE smfd_data.t_forming_publishing_details_base
    SET send_status        = (inf).status_code,
        change_status_date = (inf).complete_time,
        queue_id           = (inf).queue_id
    FROM unnest(pi_status_infos) inf
    WHERE smfd_data.t_forming_publishing_details_base.period_id = per_id
      AND smfd_data.t_forming_publishing_details_base.message_id = (inf).message_id;

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

/* Сохранение информации о формировании, получение id статистики\истории формирования */
CREATE OR REPLACE FUNCTION smfd_data.save_forming_status(IN pi_user_id INT, /* юзер */
                                                         IN pi_is_mass_forming BOOLEAN, /* массовое формирование (да/нет) */
                                                         IN pi_is_test_forming BOOLEAN, /* тестовое формирование (да/нет) */

                                                         OUT po_history_id INT, /* ссылка на историю */
                                                         OUT po_statistics_id INT, /* ссылка на статистику */

                                                         OUT po_result_code TEXT,
                                                         OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    SELECT stat.po_stat_id
    INTO po_statistics_id
    FROM public.start_statistic_action('DOCUMENT_FORMING', pi_user_id, NULL, NULL) stat;

    INSERT INTO smfd_data.t_forming_history (statistics_id, is_mass_forming, is_test_forming)
    VALUES (po_statistics_id, pi_is_mass_forming, pi_is_test_forming)
    RETURNING id INTO po_history_id;

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

/* Получения списка сформированных файлов при массовом формировании */
CREATE OR REPLACE FUNCTION smfd_data.get_forming_files(IN pi_forming_history_id INT, /* id истории формирования */
                                                       OUT po_forming_files REFCURSOR, /* Курсор с результатом */
                                                       OUT po_result_code TEXT,
                                                       OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
BEGIN
    OPEN po_forming_files FOR
        SELECT f_pub.id                        pub_id,
               f_pub.file_name                 file_name,
               array_agg(f_pub_det.message_id) message_ids
        FROM smfd_data.t_forming_history f_hist
                 JOIN smfd_data.t_forming_publishing f_pub ON f_hist.id = f_pub.history_id
                 JOIN smfd_data.t_forming_publishing_details_base f_pub_det ON f_pub_det.publishing_id = f_pub.id
                 JOIN public.t_statistics stat ON stat.id = f_hist.statistics_id
        WHERE f_hist.id = pi_forming_history_id
          AND stat.end_time IS NOT NULL
        GROUP BY f_pub.id, f_pub.file_name;

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

CREATE OR REPLACE FUNCTION smfd_data.fill_email_info(IN emails S_KEY_VALUE_PAIR[],
                                                     IN pub_id INT,
                                                     OUT po_result_code TEXT,
                                                     OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    item S_KEY_VALUE_PAIR;
BEGIN

    FOREACH item IN ARRAY emails
        LOOP
            BEGIN
                UPDATE smfd_data.t_forming_publishing_details_base
                SET email = item.value
                WHERE message_id = item.key
                  AND publishing_id = pub_id;
            END;
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
            po_result_message := SQLERRM || ' CTX:' || exception_diag;
            PERFORM public.exception_log(SQLSTATE, SQLERRM, exception_diag);
            RETURN;
        END;
END;
$$;

/* Смена статуса публикации для ЕЛК */
CREATE OR REPLACE FUNCTION smfd_data.set_publish_status(IN pi_period_id INT, /* период */
                                                        IN pi_forming_type_id INT, /* тип формирования */
                                                        IN pi_region_id INT, /* регион */
                                                        IN pi_status INT, /* Статус: опубликовать или исключить */
                                                        OUT po_result_code TEXT,
                                                        OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
BEGIN
    INSERT INTO smfd_data.t_bill_publish_status
        (status, status_change_dt, period_id, forming_type_id, region_id)
    values (pi_status, current_timestamp, pi_period_id, pi_forming_type_id, pi_region_id);
    po_result_code := 0;
    po_result_message := 'ok';
    RETURN;

EXCEPTION
    WHEN SQLSTATE '23000' THEN
        BEGIN
            update smfd_data.t_bill_publish_status
            set status_change_dt = current_timestamp,
                status           = pi_status
            where period_id = pi_period_id
              and forming_type_id = pi_forming_type_id
              and region_id = pi_region_id;
            po_result_code := 0;
            po_result_message := 'ok';
            RETURN;
        EXCEPTION
            WHEN OTHERS
                THEN
                    DECLARE
                        exception_diag TEXT;
                    begin
                        GET STACKED DIAGNOSTICS exception_diag = PG_EXCEPTION_CONTEXT;
                        po_result_code := SQLSTATE;
                        po_result_message := SQLERRM || ' CTX:' || exception_diag;
                        PERFORM public.exception_log(SQLSTATE, SQLERRM, exception_diag);
                        RETURN;
                    end;
        END;
    WHEN OTHERS THEN
        DECLARE
            exception_diag TEXT;
        BEGIN
            GET STACKED DIAGNOSTICS exception_diag = PG_EXCEPTION_CONTEXT;
            po_result_code := SQLSTATE;
            po_result_message := SQLERRM || ' CTX:' || exception_diag;
            PERFORM public.exception_log(SQLSTATE, SQLERRM, exception_diag);
            RETURN;
        end;
END;
$$;

/* Получение информации о публикации регионов в ЕЛК */
CREATE OR REPLACE FUNCTION smfd_data.get_publish_status(IN pi_period_id INT, /* период */
                                                        IN pi_mrf_id INT, /* мрф */
                                                        OUT po_publish_state REFCURSOR, /* результат */
                                                        OUT po_result_code TEXT,
                                                        OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
BEGIN
    OPEN po_publish_state FOR
        select distinct reg.region_id,
                        ft.id        as forming_type,
                        pi_period_id as period_id,
                        bs.status,
                        bs.status_change_dt
        from smfd_data.t_forming_type ft
                 join td_region reg on reg.mrf_id = ft.mrf_id
                 join smfd_data.t_bill_statistic stat
                      on stat.region_id = reg.region_id and stat.forming_type_id = ft.id and
                         stat.period_id = pi_period_id
                 left join smfd_data.t_bill_publish_status bs
                           on bs.region_id = reg.region_id and bs.period_id = pi_period_id
        where ft.mrf_id = pi_mrf_id;

    po_result_code := 0;
    po_result_message := 'ok';
    RETURN;


EXCEPTION
    WHEN OTHERS THEN
        DECLARE
            exception_diag TEXT;
        BEGIN
            GET STACKED DIAGNOSTICS exception_diag = PG_EXCEPTION_CONTEXT;
            po_result_code := SQLSTATE;
            po_result_message := SQLERRM || ' CTX:' || exception_diag;
            PERFORM public.exception_log(SQLSTATE, SQLERRM, exception_diag);
            RETURN;
        end;
END;
$$;