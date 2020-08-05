/* Смена пароля */
CREATE OR REPLACE FUNCTION smfd_user.user_change_password(IN pi_user_id INT, -- Ссылка на пользователя, которому меняется пароль.
                                                          IN pi_new_password VARCHAR(128), -- Новый пароль.
                                                          IN pi_reason VARCHAR(256), -- Причина редактирования.
                                                          IN pi_caller INT, -- Ссылка на пользователя, инициировавшего смену пароля.
                                                          OUT po_result_code TEXT, --
                                                          OUT po_result_message TEXT --
) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    new_salt CONSTANT INTEGER     := module__utils.generate_salt();
    new_hash CONSTANT VARCHAR(64) := encode(module_pgcrypto.digest(pi_new_password || new_salt, 'sha1'), 'base64');
    affected_user     smfd_user.t_user%ROWTYPE;
    caller_user       smfd_user.t_user%ROWTYPE;
    tmp               INT;
BEGIN
    -- Если передали коллера - он обязан существовать и не быть заблокированным.
    -- fixme caller_user := smfd_user.user_get_r aw(pi_caller, TRUE);

    -- Только если у каллера есть права на редактирвоание паролей, при том, что каллер - это не сам пользователь.
    /*	IF pi_caller IS NOT NULL AND
           pi_caller <> pi_user_id AND
           NOT smfd_user.role_check_user_fea ture(pi_caller, 'CHANGE_USER_PWD')
        THEN
            RAISE SQLSTATE '01007'
            USING MESSAGE = 'privilege_not_granted(CHANGE_USER_PWD): Caller cannot change user password';
        END IF;*/

    -- Пользователь должен существовать и не быть заблокированным.
    -- fixme  affected_user := smfd_user.user_get_r aw(pi_user_id, FALSE);

    IF affected_user.id IS NULL
    THEN
        RAISE SQLSTATE '02000'
            USING MESSAGE = 'User not found';
    END IF;

    UPDATE smfd_user.t_user
    SET last_pass_change_date = current_timestamp,
        pass_salt             = new_salt,
        pass_hash             = new_hash
    WHERE id = pi_user_id;

    po_result_code := 0;
    po_result_message := 'password changed';
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

/* Редактирование пользователя */
CREATE OR REPLACE FUNCTION smfd_user.user_edit(IN pi_user_id INT,
                                               IN pi_user_login TEXT,
                                               IN pi_first_name TEXT,
                                               IN pi_last_name TEXT,
                                               IN pi_middle_name TEXT,
                                               IN pi_contact_phone TEXT,
                                               IN pi_contact_email TEXT,
                                               in pi_block_date timestamp,
                                               IN pi_caller INT,
                                               OUT po_result_code TEXT,
                                               OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    affected_user smfd_user.t_user%ROWTYPE;
BEGIN
    -- Если не редактируем, или редактируем не себе - нужны права
    PERFORM smfd_user.assert_user_permit(pi_caller, ARRAY ['CREATE_USER']);
    PERFORM smfd_user.assert_user_permit(pi_user_id);

    -- Пытаемся найти пользователя
    SELECT *
    INTO affected_user
    FROM smfd_user.t_user us
    WHERE (pi_user_id IS NOT NULL AND us.id = pi_user_id)
       OR (pi_user_id IS NULL AND lower(us.user_login) = lower(pi_user_login));

    IF (affected_user.id IS NULL)
    THEN
        RAISE SQLSTATE '02000'
            USING MESSAGE = 'User not found';
    END IF;

    UPDATE smfd_user.t_user
    SET user_login    = coalesce(pi_user_login, affected_user.user_login),
        first_name    = coalesce(pi_first_name, affected_user.first_name),
        last_name     = coalesce(pi_last_name, affected_user.last_name),
        middle_name   = coalesce(pi_middle_name, affected_user.middle_name),
        contact_phone = coalesce(pi_contact_phone, affected_user.contact_phone),
        contact_email = coalesce(pi_contact_email, affected_user.contact_email),
        block_date    = coalesce(pi_block_date, affected_user.block_date)
    WHERE id = pi_user_id;

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

/* Создание нового пользователя. */
CREATE OR REPLACE FUNCTION smfd_user.user_create(IN pi_user_login VARCHAR(64),
                                                 IN pi_user_password VARCHAR(128),
                                                 IN pi_first_name VARCHAR(128),
                                                 IN pi_last_name VARCHAR(128),
                                                 IN pi_middle_name VARCHAR(128),
                                                 IN pi_contact_phone VARCHAR(11),
                                                 IN pi_contact_email VARCHAR(200),
                                                 IN pi_org_id INT,
                                                 IN pi_caller INT,
                                                 IN pi_reason VARCHAR(200),
                                                 OUT po_user_id INT,
                                                 OUT po_result_code TEXT,
                                                 OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    new_salt CONSTANT INTEGER     := module__utils.generate_salt();
    new_hash CONSTANT VARCHAR(64) := encode(module_pgcrypto.digest(pi_user_password || new_salt, 'sha1'), 'base64');
    caller_user       smfd_user.t_user%ROWTYPE;
    affected_user     smfd_user.t_user%ROWTYPE;
    tmp               INT;
BEGIN
    -- Если передали коллера - он обязан существовать и не быть заблокированным.
    -- fixme caller_user := smfd_user.user_get_r aw(pi_caller, TRUE);

    -- Только если у каллера есть права на редактирвоание паролей.
    /*	IF pi_caller IS NOT NULL AND NOT smfd_user.role_check_user_fe ature(pi_caller, 'CREATE_USER')
      THEN
        RAISE SQLSTATE '01007'
        USING MESSAGE = 'privilege_not_granted(CREATE_USER): Caller cannot create user';
      END IF;*/

    -- Пользователь должен иметь уникальный логин.
    IF (EXISTS(SELECT *
               FROM smfd_user.t_user
               WHERE lower(user_login) = lower(pi_user_login)))
    THEN
        RAISE SQLSTATE '23505'
            USING MESSAGE = 'User "' || pi_user_login || '" allready existed';
    END IF;

    INSERT INTO smfd_user.t_user (user_login, pass_hash, pass_salt, block_date, first_name, last_name, middle_name,
                                  contact_phone, contact_email, org_id)
    VALUES (pi_user_login, new_hash, new_salt, NULL, pi_first_name, pi_last_name, pi_middle_name, pi_contact_phone,
            pi_contact_email, pi_org_id)
    RETURNING * INTO affected_user;

    po_user_id := affected_user.id;
    po_result_code := 0;
    po_result_message := 'user created';
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
