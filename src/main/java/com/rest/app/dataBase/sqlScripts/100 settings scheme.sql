CREATE TABLE smfd_settings.t_settings_category
(
    category_code  TEXT PRIMARY KEY NOT NULL,
    category_name  TEXT             NOT NULL,
    category_order INT DEFAULT 500  NOT NULL
);
COMMENT ON COLUMN smfd_settings.t_settings_category.category_code IS 'Код раздела';
COMMENT ON COLUMN smfd_settings.t_settings_category.category_name IS 'Название раздела';
COMMENT ON COLUMN smfd_settings.t_settings_category.category_order IS 'Порядок отрисовки на клиентах';
COMMENT ON TABLE smfd_settings.t_settings_category IS 'Разделы настроек';

INSERT INTO smfd_settings.t_settings_category (category_code, category_name, category_order)
VALUES ('COMMON', 'Остальные', 999);
INSERT INTO smfd_settings.t_settings_category (category_code, category_name, category_order)
VALUES ('MAIL_SERVER', 'Email сервер', 500);
INSERT INTO smfd_settings.t_settings_category (category_code, category_name, category_order)
VALUES ('DIRECTORIES', 'Директории', 500);
INSERT INTO smfd_settings.t_settings_category (category_code, category_name, category_order)
VALUES ('USERS_SESSIONS', 'Пользователи и сессии', 500);

/* Основные настройки системы */
DROP TABLE IF EXISTS smfd_settings.t_settings_global;
CREATE TABLE smfd_settings.t_settings_global
(
    id            VARCHAR(64) PRIMARY KEY        NOT NULL,
    value         VARCHAR(256)  DEFAULT NULL,
    default_value VARCHAR(256)  DEFAULT NULL,
    value_type    VARCHAR(64)   DEFAULT NULL,
    description   VARCHAR(1024) DEFAULT NULL,
    category      TEXT          DEFAULT 'COMMON' NOT NULL,
    CONSTRAINT t_settings_global_t_settings_category_category_code_fk FOREIGN KEY (category) REFERENCES smfd_settings.t_settings_category (category_code)
);
COMMENT ON COLUMN smfd_settings.t_settings_global.id IS 'Идентификатор настройки';
COMMENT ON COLUMN smfd_settings.t_settings_global.value IS 'Значение';
COMMENT ON COLUMN smfd_settings.t_settings_global.default_value IS 'Значение по-умолчанию, для восстановления настроек';
COMMENT ON COLUMN smfd_settings.t_settings_global.value_type IS 'Тип значения. В логике не участвует, необходим для отображение корректных контролов на вэбе';
COMMENT ON COLUMN smfd_settings.t_settings_global.description IS 'Пояснение';
COMMENT ON TABLE smfd_settings.t_settings_global IS 'Основные настройки системы';

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Нужна для сброса триггера */
CREATE OR REPLACE FUNCTION smfd_settings.trg_settings_default_value() RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    NEW.default_value := NEW.value;
    RETURN NEW;
END;
$$;

/* ------------------------------------------------------------------------------------------------------------------------ */
DROP TRIGGER IF EXISTS trg_settings_default_value ON smfd_settings.t_settings_global;
CREATE TRIGGER trg_settings_default_value
    BEFORE INSERT
    ON smfd_settings.t_settings_global
    FOR EACH ROW
    WHEN (NEW.default_value IS NULL AND NEW.value IS NOT NULL)
EXECUTE PROCEDURE smfd_settings.trg_settings_default_value();

/* ------------------------------------------------------------------------------------------------------------------------ */
TRUNCATE TABLE smfd_settings.t_settings_global;

-- @formatter:off
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('MAIL_FROM', 'kabinet@smfd.rt.ru', 'kabinet@smfd.rt.ru', 'TEXT', 'Отправитель email''ов', 'MAIL_SERVER');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('RESPONSE_CODE_REGEX', '(\w{3}\s{1,2}\d{1,2}\s\d{2}:\d{2}:\d{2}).*sendmail.*:\s(\w{5,}).*dsn=(\d\.\d\.\d)',
        '(\w{3}\s{1,2}\d{1,2}\s\d{2}:\d{2}:\d{2}).*sendmail.*:\s(\w{5,}).*dsn=(\d\.\d\.\d)', 'TEXT', 'MailParser',
        'MAIL_SERVER');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('MAX_PDF_IN_PART', '100', '100', 'INT', 'Максимальное кол-во отчетов в одном тираже', 'MAIL_SERVER');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('QUEUEID_GROUP', '2', '2', 'INT', 'MailParser', 'MAIL_SERVER');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('MSG_ID_REGEX', '(\w{3}\s{1,2}\d{1,2}\s\d{2}:\d{2}:\d{2}).*sendmail.*:\s(\w{5,}).*msgid=<(.*?)>',
        '(\w{3}\s{1,2}\d{1,2}\s\d{2}:\d{2}:\d{2}).*sendmail.*:\s(\w{5,}).*msgid=<(.*?)>', 'TEXT', 'MailParser',
        'MAIL_SERVER');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('VALUE_GROUP', '3', '3', 'INT', 'MailParser', 'MAIL_SERVER');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('DATETIME_GROUP', '1', '1', 'INT', 'MailParser', 'MAIL_SERVER');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('MAIL_PORT', '25', '25', 'INT', 'Порт почтового сервера', 'MAIL_SERVER');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('TEMPLATE_DIRECTORY_LOCAL', 'C:\SMFD\test\template', 'C:\SMFD\test\template', 'TEXT',
        '[Локальный запуск] Папка с шаблонами', 'DIRECTORIES');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('XML_INPUT_DIRECTORY_LOCAL', 'C:\smfd\test\xml\', 'C:\smfd\xml\', 'TEXT',
        '[Локальный запуск] Директория, в которую сваливаются XML файлы от АСР', 'DIRECTORIES');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('XML_ARCHIVE_DIRECTORY', '/data/shared/smfd/xml_archive/', '/data/shared/smfd/xml_archive/', 'TEXT',
        'Директория хренения архивированных XML, которые уже обработаны.', 'DIRECTORIES');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('XML_INPUT_DIRECTORY', '/data/shared/smfd/xml/', '/data/shared/smfd/xml/', 'TEXT',
        'Директория, в которую сваливаются XML файлы от АСР', 'DIRECTORIES');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('ADVERT_MODULES_PIC_DIRECTORY', 'C:\smfd\test\advt_pics\', 'C:\smfd\advt_pics\', 'TEXT',
        'Директория хранения рекламных изображений', 'DIRECTORIES');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('MBOX_DIRECTORY_LOCAL', 'C:\smfd\test\mbox\', 'C:\smfd\test\mbox\', 'TEXT',
        '[Локальный запуск] Папка с mbox''ами', 'DIRECTORIES');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('TEMP_PDF_DIRECTORY_LOCAL', 'C:\SMFD\test\pdf', 'C:\SMFD\test\pdf\', 'TEXT', '[Локальный запуск] Папка с пдф',
        'DIRECTORIES');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('XML_ARCHIVE_DIRECTORY_LOCAL', 'C:\SMFD\test\zip', 'C:\smfd\xml_archive\', 'TEXT',
        '[Локальный запуск] Директория хренения архивированных XML, которые уже обработаны.', 'DIRECTORIES');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('MAIL_HOST', '10.178.47.227', '10.178.47.227', 'TEXT', 'Хост почтового сервера', 'MAIL_SERVER');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('MAX_COUNT_SEND_TRY', '5', '5', 'INT', 'Максимальное количество попыток отправки', 'MAIL_SERVER');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('SESSION_INACTIVE_LIFETIME', '5 day', '5 day', 'INTERVAL', 'Время неактивности пользователя до удаления сессии',
        'USERS_SESSIONS');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('USER_PASSWORD_LIFETIME', '3 month', '3 month', 'INTERVAL', 'Периодичность смены пароля пользователей',
        'USERS_SESSIONS');
INSERT INTO smfd_settings.t_settings_global (id, value, default_value, value_type, description, category)
VALUES ('MAIL_PROTOCOL', 'smtp', 'smtp', 'TEXT', 'Протокол почтового сервера', 'MAIL_SERVER');
-- @formatter:on

/* Получеине всех настроек СМФД из таблицы t_settings_global */
CREATE OR REPLACE FUNCTION smfd_settings.get_all_settings(OUT po_settings REFCURSOR, /* результат */
                                                          OUT po_result_code TEXT,
                                                          OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN po_settings FOR
        SELECT s.id,
               s.value,
               s.default_value,
               s.value_type,
               s.description,
               cat.category_code,
               cat.category_name,
               cat.category_order
        FROM smfd_settings.t_settings_global s
                 JOIN smfd_settings.t_settings_category cat ON s.category = cat.category_code
        ORDER BY cat.category_order, s.id;

    po_result_code := 0;
    po_result_message := 'ok';
    RETURN;
END;
$$;

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Изменение настроек в таблице t_settings_global */
CREATE OR REPLACE FUNCTION smfd_settings.set_value(IN pi_setting_id TEXT, /* id настройки */
                                                   IN pi_setting_value TEXT, /* значение */
                                                   OUT po_result_code TEXT,
                                                   OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    setting_row smfd_settings.t_settings_global%ROWTYPE;
    temp_value  TEXT;
BEGIN
    SELECT *
    INTO setting_row
    FROM smfd_settings.t_settings_global s
    WHERE s.id = upper(pi_setting_id)
    LIMIT 1;

    IF setting_row.id IS NULL
    THEN
        RAISE EXCEPTION '02000'
            USING MESSAGE = 'Setting not found: ' || pi_setting_id;
    END IF;

    -- Длиннющая портянка кейса на каждый тип значения. Пока не придумал, как можно сделать автокаст в тип по строке.
    CASE upper(setting_row.value_type)
        -- Проверяем каст к интервалу
        WHEN 'INTERVAL'
            THEN SELECT cast(pi_setting_value AS INTERVAL)
                 INTO temp_value;
                 temp_value := lower(pi_setting_value);

        -- Проверяем каст к числу
        WHEN 'INTEGER'
            THEN SELECT cast(pi_setting_value AS INT)
                 INTO temp_value;

        -- Проверяем буль. Может быть 1/0/true/false/on/off
        WHEN 'BOOLEAN'
            THEN SELECT cast(pi_setting_value AS BOOLEAN)
                 INTO temp_value;
                 temp_value := temp_value :: TEXT;

        -- Ничего не проверяем, у нас и так строка...
        WHEN 'TEXT'
            THEN temp_value := pi_setting_value;

        ELSE RAISE EXCEPTION '02000'
            USING MESSAGE = 'Incorrect value type: ' || setting_row.value_type;
        END CASE;

    UPDATE smfd_settings.t_settings_global
    SET value = temp_value :: TEXT
    WHERE id = pi_setting_id;

    po_result_code := 0;
    po_result_message := 'ok: ' || pi_setting_id :: TEXT || ' = ' || temp_value :: TEXT;

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

/* Получение настройки в виде строки */
CREATE OR REPLACE FUNCTION smfd_settings.get_string(IN pi_setting_name TEXT,
                                                    IN pi_default_value TEXT = '') RETURNS TEXT
    LANGUAGE plpgsql AS
$$
DECLARE
    s_value TEXT;
BEGIN
    SELECT sg.value
    INTO s_value
    FROM smfd_settings.t_settings_global sg
    WHERE upper(sg.id) = upper(pi_setting_name);
    RETURN coalesce(s_value, pi_default_value);
END;
$$;

/* Получение настройки в виде числа */
CREATE OR REPLACE FUNCTION smfd_settings.get_integer(IN pi_setting_name TEXT,
                                                     IN pi_default_value TEXT = '0') RETURNS INTEGER
    LANGUAGE plpgsql AS
$$
BEGIN
    RETURN smfd_settings.get_string(pi_setting_name, pi_default_value) :: INTEGER;
END;
$$;

/* Получение настройки в виде массива чисел */
CREATE OR REPLACE FUNCTION smfd_settings.get_integer_array(IN pi_setting_name TEXT,
                                                           IN pi_default_value TEXT = '{}') RETURNS INTEGER[]
    LANGUAGE plpgsql AS
$$
BEGIN
    RETURN smfd_settings.get_string(pi_setting_name, pi_default_value) :: INTEGER[];
END;
$$;

/* Получение настройки интервала http://howtucode.com/how-to-operate-on-postgresql-interval-datatype-using-jdbcspring-jdbc-not-using-pginterval-317496.html */
CREATE OR REPLACE FUNCTION smfd_settings.get_interval(IN pi_setting_name TEXT,
                                                      IN pi_default_value TEXT = '1 year') RETURNS INTERVAL
    LANGUAGE plpgsql AS
$$
BEGIN
    RETURN smfd_settings.get_string(pi_setting_name, pi_default_value) :: INTERVAL;
END;
$$;

/* Получение настройки времени */
CREATE OR REPLACE FUNCTION smfd_settings.get_timestamp(IN pi_setting_name TEXT,
                                                       IN pi_default_value TEXT = current_timestamp :: TEXT) RETURNS TIMESTAMP
    LANGUAGE plpgsql AS
$$
BEGIN
    RETURN smfd_settings.get_string(pi_setting_name, pi_default_value) :: TIMESTAMP;
END;
$$;

CREATE TABLE smfd_settings.t_period_property
(
    id              SERIAL PRIMARY KEY NOT NULL,
    period_id       INT,
    forming_type_id INT,
    name            varchar,
    value           text,
    CONSTRAINT t_period_property_t_billing_period_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE
);

comment on COLUMN smfd_settings.t_period_property.period_id is 'Ссылка на период';
comment on COLUMN smfd_settings.t_period_property.forming_type_id is 'Ссылка на тип формирования';
comment on COLUMN smfd_settings.t_period_property.name is 'Название настроцки';
comment on COLUMN smfd_settings.t_period_property.value is 'значение настроцки';
comment on table smfd_settings.t_period_property is 'специфичные настройки для периода и типа формирования';

CREATE UNIQUE INDEX period_property_uindex ON smfd_settings.t_period_property (period_id, forming_type_id, name);

/* Получеине настроек для формирования (например текст и тема письма) */
create or replace function smfd_settings.get_period_property(IN pi_period_id INT, /* период */
                                                             IN pi_forming_type_id INT, /* тип формирования */
                                                             IN pi_name varchar, /* наименование настройки */
                                                             OUT po_value text, /* значение настройки */
                                                             OUT po_period_date timestamp, /* дата */
                                                             OUT po_result_code TEXT,
                                                             OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    period_date TIMESTAMP;
BEGIN

    select bp.date into period_date from smfd_data.t_billing_period bp where bp.id = pi_period_id;

    select t.value, bp.date
    into po_value, po_period_date
    from smfd_settings.t_period_property t
             join smfd_data.t_billing_period bp on t.period_id = bp.id
    where bp.date <= period_date
      and forming_type_id = pi_forming_type_id
      and name = pi_name
    order by bp.date desc
    limit 1;


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

/* Изменение\создание настройки для формирования (текст и тема письма) */
create or replace function smfd_settings.set_period_property(IN pi_period_id INT, /* период */
                                                             IN pi_forming_type_id INT, /* тип формирования */
                                                             IN pi_name varchar, /* имя */
                                                             in pi_value text, /* значение */
                                                             OUT po_result_code TEXT,
                                                             OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
declare
begin

    insert into smfd_settings.t_period_property (period_id, forming_type_id, name, value)
    values (pi_period_id, pi_forming_type_id, pi_name, pi_value);

    po_result_code := 0;
    po_result_message := 'ok';
    RETURN;

EXCEPTION
    WHEN SQLSTATE '23000' THEN
        BEGIN
            update smfd_settings.t_period_property
            set value = pi_value
            where period_id = pi_period_id
              and forming_type_id = pi_forming_type_id
              and name = pi_name;

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
end;
$$;
