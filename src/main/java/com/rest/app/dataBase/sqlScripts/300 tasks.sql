/* ------------------------------------------------------------------------------------------------------------------------ */
DROP TABLE IF EXISTS smfd_task_manager.td_task_type CASCADE;
CREATE TABLE smfd_task_manager.td_task_type
(
    id               INT PRIMARY KEY NOT NULL,
    task_code        VARCHAR(32)     NOT NULL,
    description      TEXT,
    parent_task_type INT DEFAULT NULL,
    CONSTRAINT td_task_type_td_task_type_id_fk FOREIGN KEY (parent_task_type) REFERENCES smfd_task_manager.td_task_type (id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON COLUMN smfd_task_manager.td_task_type.id IS 'Идентификатор типа задачи';
COMMENT ON COLUMN smfd_task_manager.td_task_type.task_code IS 'Код типа задачи';
COMMENT ON COLUMN smfd_task_manager.td_task_type.description IS 'Описание типа задачи';
COMMENT ON COLUMN smfd_task_manager.td_task_type.parent_task_type IS 'Родительский тип задачи для цепочек последовательных задач';
COMMENT ON TABLE smfd_task_manager.td_task_type IS 'Типы задач';

CREATE UNIQUE INDEX td_task_type_task_code_uindex ON smfd_task_manager.td_task_type (task_code);

INSERT INTO smfd_task_manager.td_task_type (id, task_code, description, parent_task_type)
VALUES (1, 'XML_LOAD', 'Загрузка .XML со счетами в БД', NULL);
INSERT INTO smfd_task_manager.td_task_type (id, task_code, description, parent_task_type)
VALUES (2, 'XML_ARCHIVE', 'Архивирование и удаление .XML со счетами', 1);
INSERT INTO smfd_task_manager.td_task_type (id, task_code, description, parent_task_type)
VALUES (10, 'LOAD_BILLS', 'Загрузка выборки счетов из БД', NULL);
INSERT INTO smfd_task_manager.td_task_type (id, task_code, description, parent_task_type)
VALUES (11, 'CREATE_PDF', 'Создание pdf', 10);
INSERT INTO smfd_task_manager.td_task_type (id, task_code, description, parent_task_type)
VALUES (12, 'CIRCULATION', 'Группировка счетов по тиражам в mbox''ы', 11);

/* ------------------------------------------------------------------------------------------------------------------------ */
DROP TABLE IF EXISTS smfd_task_manager.td_task_status CASCADE;
CREATE TABLE smfd_task_manager.td_task_status
(
    id          INT PRIMARY KEY       NOT NULL,
    status_code VARCHAR(32),
    description TEXT,
    initial     BOOLEAN DEFAULT FALSE NOT NULL,
    final       BOOLEAN DEFAULT FALSE NOT NULL
);
COMMENT ON COLUMN smfd_task_manager.td_task_status.id IS 'Идентификатор статуса задачи';
COMMENT ON COLUMN smfd_task_manager.td_task_status.status_code IS 'Код статуса задачи';
COMMENT ON COLUMN smfd_task_manager.td_task_status.description IS 'Описание статуса';
COMMENT ON COLUMN smfd_task_manager.td_task_status.initial IS 'Статус начальный, задача не взята в обработку?';
COMMENT ON COLUMN smfd_task_manager.td_task_status.final IS 'Статус финальный, задача выполнена?';
COMMENT ON TABLE smfd_task_manager.td_task_status IS 'Статусы задач';

INSERT INTO smfd_task_manager.td_task_status (id, status_code, description, initial, final)
VALUES (1, 'CREATED', '', TRUE, FALSE);
INSERT INTO smfd_task_manager.td_task_status (id, status_code, description, initial, final)
VALUES (2, 'STARTED', '', FALSE, FALSE);
INSERT INTO smfd_task_manager.td_task_status (id, status_code, description, initial, final)
VALUES (3, 'COMPLETED', '', FALSE, TRUE);
INSERT INTO smfd_task_manager.td_task_status (id, status_code, description, initial, final)
VALUES (4, 'ABORTED', '', FALSE, TRUE);
INSERT INTO smfd_task_manager.td_task_status (id, status_code, description, initial, final)
VALUES (5, 'FAILED', '', FALSE, TRUE);

/* ------------------------------------------------------------------------------------------------------------------------ */
DROP TABLE IF EXISTS smfd_task_manager.t_task CASCADE;
CREATE TABLE smfd_task_manager.t_task
(
    id                 SERIAL PRIMARY KEY                  NOT NULL,
    task_type          INT                                 NOT NULL,
    task_status        INT                                 NOT NULL,
    task_initiator     INT                                 NOT NULL,
    create_date        TIMESTAMP DEFAULT current_timestamp NOT NULL,
    status_change_date TIMESTAMP DEFAULT current_timestamp NOT NULL,
    parent_task_id     INT       DEFAULT NULL,
    CONSTRAINT t_task_td_task_type_id_fk FOREIGN KEY (task_type) REFERENCES smfd_task_manager.td_task_type (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_task_td_task_status_id_fk FOREIGN KEY (task_status) REFERENCES smfd_task_manager.td_task_status (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_task_t_user_id_fk FOREIGN KEY (task_initiator) REFERENCES smfd_user.t_user (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_task_t_task_id_fk FOREIGN KEY (id) REFERENCES smfd_task_manager.t_task (id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON COLUMN smfd_task_manager.t_task.id IS 'Идентификатор задачи';
COMMENT ON COLUMN smfd_task_manager.t_task.task_type IS 'Тип задачи (td_task_type)';
COMMENT ON COLUMN smfd_task_manager.t_task.task_status IS 'Статус задачи (td_task_status)';
COMMENT ON COLUMN smfd_task_manager.t_task.create_date IS 'Время создания задачи';
COMMENT ON COLUMN smfd_task_manager.t_task.status_change_date IS 'Время последней смены статуса задачи';
COMMENT ON COLUMN smfd_task_manager.t_task.parent_task_id IS 'Ссылка на задачу, в результате выполнения которой была создана эта задача (ссылка на "цепную" задачу)';
COMMENT ON TABLE smfd_task_manager.t_task IS 'Задачи (таблица так же случит источником истории задач)';

ALTER TABLE smfd_task_manager.t_task
    ADD COLUMN comment TEXT;
ALTER TABLE smfd_task_manager.t_task
    ALTER COLUMN comment TYPE TEXT USING comment::TEXT;

/* ------------------------------------------------------------------------------------------------------------------------ */
DROP TABLE IF EXISTS smfd_task_manager.t_task_params CASCADE;
CREATE TABLE smfd_task_manager.t_task_params
(
    task_id     INT         NOT NULL,
    param_key   VARCHAR(64) NOT NULL,
    param_value TEXT        NOT NULL,
    CONSTRAINT t_task_params_task_id_param_key_pk PRIMARY KEY (task_id, param_key),
    CONSTRAINT t_task_params_t_task_id_fk FOREIGN KEY (task_id) REFERENCES smfd_task_manager.t_task (id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON TABLE smfd_task_manager.t_task_params IS 'Параметры задач';
COMMENT ON COLUMN smfd_task_manager.t_task_params.task_id IS 'Ссылка на задачу';
COMMENT ON COLUMN smfd_task_manager.t_task_params.param_key IS 'Ключ параметра';
COMMENT ON COLUMN smfd_task_manager.t_task_params.param_value IS 'Значение параметра';

CREATE INDEX t_task_params_task_id_index ON smfd_task_manager.t_task_params (task_id);

/* ------------------------------------------------------------------------------------------------------------------------ */
CREATE TABLE smfd_task_manager.t_task_m2m_report
(
    task_id   INT PRIMARY KEY NOT NULL,
    order_id  BIGINT          NOT NULL,
    source_id TEXT            NOT NULL,
    doc_id    INT,
    CONSTRAINT t_task_m2m_report_t_task_id_fk FOREIGN KEY (task_id) REFERENCES smfd_task_manager.t_task (id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX t_task_m2m_report_order_id_source_id_uindex ON smfd_task_manager.t_task_m2m_report (order_id, source_id);
COMMENT ON TABLE smfd_task_manager.t_task_m2m_report IS 'Расширение таски для индексации задача по формированию M2M';

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Удаление данных, загруженных по задаче */
CREATE OR REPLACE FUNCTION smfd_data.clear_bills_data(task_id integer, /* номер задачи */
                                                      OUT po_result_code text,
                                                      OUT po_result_message text)
    RETURNS record
    LANGUAGE plpgsql
AS
$$
BEGIN
    DELETE FROM smfd_data.t_bill_base bb where bb.history_entry = task_id;

    po_result_code := 0;
    po_result_message := 'ok';
    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            po_result_code := SQLSTATE;
            po_result_message := SQLERR;
            RETURN;
        END;
END;
$$;

/* ------------------------------------------------------------------------------------------------------------------------------------------- */
/* Создание задачи определенного типа */
CREATE OR REPLACE FUNCTION smfd_task_manager.create_task(IN pi_task_type INT, /* тип задачи */
                                                         IN pi_user INT, /* пользователь создавший задачу */
                                                         IN pi_parameters public.S_KEY_VALUE_PAIR[], /* доп. параметры для задачи */
                                                         IN pi_parent_task_id INT, /* родительская задача (обычно null) */
                                                         OUT po_task_id INT, /* возвращаем id записи */
                                                         OUT po_result_code TEXT,
                                                         OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    task_id INT;
BEGIN
    INSERT INTO smfd_task_manager.t_task (task_type, task_status, task_initiator, parent_task_id)
    VALUES (pi_task_type, 1, pi_user, pi_parent_task_id)
    RETURNING id INTO task_id;

    INSERT INTO smfd_task_manager.t_task_params (task_id, param_key, param_value)
    SELECT task_id   task_id,
           (x).key   param_key,
           (x).value param_value
    FROM unnest(pi_parameters) x;

    po_task_id := task_id;
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


/* Получеине всех задач по фильтру (тип, статус) */
CREATE OR REPLACE FUNCTION smfd_task_manager.get_tasks(pi_task_types integer[] DEFAULT ARRAY []::integer[], /* фильтр по списку нужных типов */
                                                       pi_task_statuses integer[] DEFAULT ARRAY []::integer[], /* фильтр по списку нужных статусов */
                                                       OUT po_tasks refcursor, /* результат */
                                                       OUT po_result_code text,
                                                       OUT po_result_message text) RETURNS record
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN po_tasks FOR
        SELECT t.*,
               array_agg((p.param_key, p.param_value) :: S_KEY_VALUE_PAIR) task_params
        FROM smfd_task_manager.t_task t
                 JOIN smfd_task_manager.td_task_status s ON s.id = t.task_status
                 LEFT JOIN smfd_task_manager.t_task_params p ON p.task_id = t.id
        WHERE (
                cardinality(pi_task_types) = 0 -- если не переданы типы
                OR t.task_type = ANY (pi_task_types)
            )
          AND (
                cardinality(pi_task_statuses) = 0 -- если
                OR t.task_status = ANY (pi_task_statuses)
            )
        GROUP BY t.id, t.*
        ORDER BY t.create_date;

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

/* ------------------------------------------------------------------------------------------------------------------------------------------- */
/* Создание задачи на выполнение M2M запроса */
CREATE OR REPLACE FUNCTION smfd_task_manager.create_task_m2m_report(IN pi_user INT, /* пользователь */
                                                                    in pi_doc_id int, /* номер документа */
                                                                    IN pi_parameters public.S_KEY_VALUE_PAIR[], /* параметры */
                                                                    IN pi_parent_task_id INT, /* родительская задача */
                                                                    IN pi_order_id BIGINT, /* id задачи из источника */
                                                                    IN pi_source_id TEXT, /* Источник: например ELK */
                                                                    OUT po_task_id INT, /* возвращаем id записи */
                                                                    OUT po_result_code TEXT,
                                                                    OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    l_task_id int;
BEGIN
    select min(ords.task_id) into l_task_id from smfd_task_manager.t_task_m2m_report ords where ords.doc_id = pi_doc_id;


    if l_task_id is not null then
        INSERT INTO smfd_task_manager.t_task_m2m_report (task_id, order_id, source_id, doc_id)
        VALUES (l_task_id, pi_order_id, pi_source_id, pi_doc_id);

        po_task_id := l_task_id;
        po_result_code := 0;
        po_result_message := 'ok';
        RETURN;
    end if;

    SELECT ovr.po_task_id,
           ovr.po_result_code,
           ovr.po_result_message
    INTO po_task_id, po_result_code, po_result_message
    FROM smfd_task_manager.create_task(
                 pi_task_type := 30 /*M2M_REPORT*/,
                 pi_user := pi_user,
                 pi_parameters := pi_parameters,
                 pi_parent_task_id := pi_parent_task_id
             ) ovr;

    IF (po_result_code <> '0')
    THEN
        RAISE EXCEPTION '%', po_result_message USING ERRCODE = po_result_code;
    END IF;

    INSERT INTO smfd_task_manager.t_task_m2m_report (task_id, order_id, source_id, doc_id)
    VALUES (po_task_id, pi_order_id, pi_source_id, pi_doc_id);

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
/* Изменение статуса задачи (с добавлением коммента) */
CREATE OR REPLACE FUNCTION smfd_task_manager.change_task_status(IN pi_task_id INT, /* id задачи */
                                                                IN pi_new_status INT, /* новый статус задачи*/
                                                                IN pi_comment TEXT DEFAULT '', /* коммент */
                                                                OUT po_result_code TEXT,
                                                                OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    task_found INT;
BEGIN
    SELECT tt.id
    INTO task_found
    FROM smfd_task_manager.t_task tt
    WHERE tt.id = pi_task_id
      AND tt.task_status >= pi_new_status;

    IF (task_found IS NOT NULL)
    THEN
        RAISE SQLSTATE '57014'
            USING MESSAGE = 'Task ' || pi_task_id || ' allready in status ' || pi_new_status;
    END IF;

    UPDATE smfd_task_manager.t_task
    SET task_status        = pi_new_status,
        status_change_date = current_timestamp,
        comment            = pi_comment
    WHERE id = pi_task_id
    RETURNING id INTO task_found;

    IF (task_found IS NULL)
    THEN
        RAISE SQLSTATE '02000'
            USING MESSAGE = 'Task not found';
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

/* ------------------------------------------------------------------------------------------------------------------------
	Изменение параметров задачи.
	Передавать нужно только те параметры, которые требуется изменить.
	Если значение NULL - параметр будет удален. */
CREATE OR REPLACE FUNCTION smfd_task_manager.edit_task_params(IN pi_task_id INT, /* id задачи */
                                                              IN pi_diff_params S_KEY_VALUE_PAIR[], /* новые значения параметров */
                                                              OUT po_result_code TEXT,
                                                              OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    -- Удаляем все параметры, которые пришли с NULL значением
    DELETE
    FROM smfd_task_manager.t_task_params tp
    WHERE tp.task_id = pi_task_id
      AND tp.param_key IN (
        SELECT (u :: S_KEY_VALUE_PAIR).key
        FROM unnest(pi_diff_params) u
        WHERE (u :: S_KEY_VALUE_PAIR).value IS NULL
           OR (u :: S_KEY_VALUE_PAIR).value = ''
    );
    -- Мержим в параметры остальное
    WITH s AS (
        SELECT pi_task_id task_id,
               (u).key    kvp_key,
               (u).value  kvp_value
        FROM unnest(pi_diff_params) u
        WHERE (u).value IS NOT NULL
          AND (u).value <> ''
    ),
         upd AS (
             UPDATE smfd_task_manager.t_task_params
                 SET param_value = kvp_value
                 FROM s
                 WHERE t_task_params.task_id = pi_task_id AND t_task_params.param_key = kvp_key
                 RETURNING t_task_params.param_key
         )
    INSERT
    INTO smfd_task_manager.t_task_params (task_id, param_key, param_value)
    SELECT pi_task_id,
           s.kvp_key,
           s.kvp_value
    FROM s
    WHERE s.kvp_key NOT IN (SELECT param_key
                            FROM upd);

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

/* Запрос актуальной задачи на формирование отдельного документа (например, для ЕЛК) */
CREATE OR REPLACE FUNCTION smfd_task_manager.get_individual_forming_task(IN pi_order_id BIGINT, /* Номер заказа */
                                                                         IN pi_source_id TEXT, /* Источник (ELK) */
                                                                         OUT po_task_id INT, /* id задачи */
                                                                         OUT po_task_type INT, /* тип задачи */
                                                                         OUT po_task_status INT, /* статус */
                                                                         OUT po_initiator INT, /* инициатор */
                                                                         OUT po_create_date TIMESTAMP, /* дата создания */
                                                                         OUT po_change_date TIMESTAMP, /* дата изменения статуса */
                                                                         OUT po_parent_id INT, /* родительская задача */
                                                                         OUT po_task_params public.S_KEY_VALUE_PAIR[], /* параметры */
                                                                         OUT po_result_code TEXT,
                                                                         OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    SELECT task.id,
           task.task_type,
           task.task_status,
           task.task_initiator,
           task.create_date,
           task.status_change_date,
           task.parent_task_id,
           array_agg(DISTINCT (param_all.param_key, param_all.param_value) :: public.S_KEY_VALUE_PAIR) params
    INTO
        po_task_id,
        po_task_type,
        po_task_status,
        po_initiator,
        po_create_date,
        po_change_date,
        po_parent_id,
        po_task_params
    FROM smfd_task_manager.t_task task
             JOIN smfd_task_manager.t_task_m2m_report taskm2m ON task.id = taskm2m.task_id
        AND taskm2m.order_id = pi_order_id
        AND taskm2m.source_id = pi_source_id
             LEFT JOIN smfd_task_manager.t_task_params param_all ON task.id = param_all.task_id
    WHERE task.task_type = 30
      AND task.status_change_date >= (NOW() - smfd_settings.get_interval('FORMING_INTIVIDIAL_STORE_TIME', '1 week'))
    GROUP BY task.id
    LIMIT 1;

    IF (po_task_id IS NULL)
    THEN
        RAISE SQLSTATE '02000'
            USING MESSAGE = 'Task not found';
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

/* Получение параметров задачи по id */
CREATE OR REPLACE FUNCTION smfd_task_manager.get_task_params(IN pi_task_id BIGINT, /* id задачи */
                                                             OUT po_task_params public.S_KEY_VALUE_PAIR[], /* параметры */
                                                             OUT po_result_code TEXT,
                                                             OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    SELECT array_agg(DISTINCT (param.param_key, param.param_value) :: public.S_KEY_VALUE_PAIR) param
    INTO
        po_task_params
    FROM smfd_task_manager.t_task_params param
    WHERE param.task_id = pi_task_id;

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

/* Получение статуса задачи по id */
create or replace function smfd_task_manager.get_task_status(IN pi_task_id INT, /* id задачи */
                                                             OUT po_status INT, /* статус */
                                                             OUT po_result_code TEXT,
                                                             OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
BEGIN
    select t.task_status into po_status from smfd_task_manager.t_task t where t.id = pi_task_id;

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