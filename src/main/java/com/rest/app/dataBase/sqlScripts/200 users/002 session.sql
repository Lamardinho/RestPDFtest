/* ------------------------------------------------------------------------------------------------------------------------ */
DROP TABLE IF EXISTS smfd_user.t_session CASCADE;
CREATE TABLE IF NOT EXISTS smfd_user.t_session
(
    user_id          INT                                 NOT NULL,
    session_key      VARCHAR(64)                         NOT NULL,
    create_date      TIMESTAMP DEFAULT current_timestamp NOT NULL,
    last_action_date TIMESTAMP DEFAULT current_timestamp NOT NULL,
    CONSTRAINT t_session_user_id_session_key_pk PRIMARY KEY (user_id, session_key),
    CONSTRAINT t_session_t_user_id_fk FOREIGN KEY (user_id) REFERENCES smfd_user.t_user (id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX t_session_session_key_uindex ON smfd_user.t_session (session_key);
COMMENT ON TABLE smfd_user.t_session IS 'Сессии пользователей';
COMMENT ON COLUMN smfd_user.t_session.user_id IS 'Идентификатор пользователя';
COMMENT ON COLUMN smfd_user.t_session.session_key IS 'Ключ сессии';
COMMENT ON COLUMN smfd_user.t_session.create_date IS 'Время логина';
COMMENT ON COLUMN smfd_user.t_session.last_action_date IS 'Время последнего действия';

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Обнуление, очистка сессии, если была просрочена */
CREATE OR REPLACE FUNCTION smfd_user.session_purge() RETURNS VOID
    LANGUAGE plpgsql AS
$$
BEGIN
    DELETE
    FROM smfd_user.t_session s
    WHERE s.last_action_date < (now() - smfd_settings.get_interval('SESSION_INACTIVE_LIFETIME'))
       OR s.create_date < now() - smfd_settings.get_interval('SESSION_MAX_LIFETIME')
       OR s.user_id IN (
        SELECT u.id
        FROM smfd_user.t_user u
        WHERE u.block_date IS NOT NULL
    );
EXCEPTION
    WHEN OTHERS
        THEN DECLARE
            exception_diag TEXT;
        BEGIN
            GET STACKED DIAGNOSTICS exception_diag = PG_EXCEPTION_CONTEXT;
            PERFORM public.exception_log(SQLSTATE, SQLERRM, exception_diag);
        END;
END;
$$;

/* Проверка сессии пользователя */
DROP FUNCTION if EXISTS smfd_user.session_check(TEXT);
CREATE OR REPLACE FUNCTION smfd_user.session_check(IN pi_session_key TEXT, /* ключ сессии */
                                                   OUT po_user_id INT, /* id пользователя */
                                                   OUT po_user_permissions REFCURSOR, /* разрешения */
                                                   OUT po_permissions REFCURSOR, /* id разрешений */
                                                   out po_is_admin int, /* админ или нет */
                                                   OUT po_result_code TEXT,
                                                   OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    -- 	PERFORM smfd_user.session_purge(); -- todo поглядеть, что будет на больших данных.

    UPDATE smfd_user.t_session
    SET last_action_date = current_timestamp
    WHERE session_key = upper(pi_session_key)
    RETURNING user_id INTO po_user_id;

    OPEN po_permissions FOR
        select distinct p.id
        from smfd_user.td_permission p
                 join smfd_user.t_role_permissions rp on p.id = rp.permission_id
                 join smfd_user.t_role r on r.id = rp.role_id
                 join smfd_user.t_user_roles ur on ur.role_id = r.id
        where ur.user_id = po_user_id;

    select count(*)
    into po_is_admin
    from smfd_user.t_user_roles ur
    where ur.role_id = 'ROLE_ADMIN_GENERAL'
      and ur.user_id = po_user_id;

    open po_user_permissions for
        SELECT compound.permission_id                   permission_id,
               max(compound.is_role :: INT) :: BOOL     is_role,
               max(compound.is_personal :: INT) :: BOOL is_personal
        FROM (
                 SELECT compound.permission_id,
                        compound.is_role,
                        compound.is_personal
                 FROM (
                          -- иды групп в качестве пермишнов
                          SELECT us_roles.user_id user_id,
                                 us_roles.role_id permission_id,
                                 TRUE             is_role,
                                 FALSE            is_personal
                          FROM smfd_user.t_user_roles us_roles
                          WHERE us_roles.user_id = po_user_id
                          UNION ALL
                          -- и все пермишны групп в качестве пермишнов пользователя
                          SELECT us_roles.user_id user_id,
                                 perm.id          permission_id,
                                 FALSE            is_role,
                                 FALSE            is_personal
                          FROM smfd_user.t_user_roles us_roles
                                   LEFT JOIN smfd_user.t_role role ON us_roles.role_id = role.id
                                   LEFT JOIN smfd_user.t_role_permissions role_perms ON role.id = role_perms.role_id
                                   JOIN smfd_user.td_permission perm
                                        ON role_perms.permission_id = perm.id OR role.is_administrative
                          WHERE us_roles.user_id = po_user_id
                          UNION ALL
                          -- персональные пермишны
                          SELECT us_perm.user_id       user_id,
                                 us_perm.permission_id permission_id,
                                 FALSE                 is_role,
                                 TRUE                  is_personal
                          FROM smfd_user.t_user_permissions us_perm
                          WHERE us_perm.user_id = po_user_id
                      ) compound
                 ORDER BY compound.is_personal DESC, compound.is_role DESC, compound.permission_id
             ) compound
        GROUP BY compound.permission_id;

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

/* Вход на портал */
CREATE OR REPLACE FUNCTION smfd_user.user_login(IN pi_login TEXT, /* логин */
                                                IN pi_password TEXT, /* пароль */
                                                OUT po_session_key TEXT, /* ключ сессии */
                                                OUT po_user_id INT, /* id пользователя */
                                                OUT po_result_code TEXT,
                                                OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    found_user smfd_user.t_user%ROWTYPE;
BEGIN
    -- 	PERFORM smfd_user.session_purge();

    SELECT u.*
    INTO found_user
    FROM smfd_user.t_user u
    WHERE lower(u.user_login) = lower(pi_login)
      AND u.block_date IS NULL
      AND u.pass_hash = encode(module_pgcrypto.digest(pi_password || u.pass_salt, 'sha1'), 'base64');

    IF found_user.id IS NULL
    THEN
        RAISE SQLSTATE '02000'
            USING MESSAGE = 'User not found or password incorrect';
    END IF;

    po_session_key :=
            upper(md5(random() :: TEXT || found_user.user_login || found_user.pass_salt) || md5(random() :: TEXT));
    po_user_id := found_user.id;

    INSERT INTO smfd_user.t_session (user_id, session_key) VALUES (po_user_id, po_session_key);
    -- todo подумать про коллизии

    po_result_code := 0;
    po_result_message := 'session created';
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

/* Выход из портала */
CREATE OR REPLACE FUNCTION smfd_user.user_logout(IN pi_session_key TEXT, -- Ключ сессии. Если NULL - грохнет все сессии. Если некорректен - вернет ошибку.
                                                 OUT po_result_code TEXT,
                                                 OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    deleted_count INT;
BEGIN
    -- 	PERFORM smfd_user.session_purge();

    DELETE
    FROM smfd_user.t_session s
    WHERE s.session_key = pi_session_key;

    GET DIAGNOSTICS deleted_count = ROW_COUNT;

    IF pi_session_key IS NOT NULL AND deleted_count = 0
    THEN
        RAISE SQLSTATE '02000'
            USING MESSAGE = 'Session not found';
    END IF;

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
