/* ------------------------------------------------------------------------------------------------------------------------
	Проверка на существование пользователя и на разрешение ему указанных объектов и/или прав. */
CREATE OR REPLACE FUNCTION smfd_user.assert_user_permit(IN pi_user_id INT, /* id пользователя */
                                                        IN pi_role_features TEXT[] DEFAULT ARRAY [] :: TEXT[], /* перечисление прав */
                                                        IN pi_access_object TEXT DEFAULT '') RETURNS VOID
    LANGUAGE plpgsql AS
$$
DECLARE
    found_user smfd_user.T_USER;
BEGIN
    SELECT *
    INTO found_user
    FROM smfd_user.t_user u
    WHERE u.id = pi_user_id;

    IF (found_user IS NULL OR found_user.id IS NULL)
    THEN
        PERFORM audit(pi_user_id, 'ASSERT PERMIT FAILED');
        RAISE SQLSTATE '02000'
            USING MESSAGE = 'User not found';
    END IF;

    IF cardinality(pi_role_features) > 0
    THEN
        /*todo IF (NOT smfd_user.role_check_user_fe ature(pi_user_id, pi_role_features))
        THEN
            PERFORM audit(pi_user_id, 'ASSERT ACCESS FAILED');
            RAISE SQLSTATE '02000'
            USING MESSAGE = 'User denied acces to  ' || pi_role_features;
        END IF;*/
    END IF;

    -- todo! сделать табличку (объект<->роль) и проверять юзверя по правам. И сделать похожую функцию для этого.
END;
$$;


/* Получение всех пользователей и их пермишинов */
CREATE OR REPLACE FUNCTION smfd_user.get_all_users(OUT po_users REFCURSOR, /* Все пользователи */
                                                   OUT po_permissions_dic REFCURSOR, /* Словарь пермишинов */
                                                   OUT po_result_code TEXT,
                                                   OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
BEGIN

    OPEN po_users FOR
        SELECT us.id,
               us.user_login,
               us.registration_date,
               us.block_date,
               us.first_name,
               us.last_name,
               us.middle_name,
               us.contact_phone,
               us.contact_email,
               us.org_id,
               (SELECT ss.user_id /* такой вот себе экзистс. настоящий делал в плане двойную выборку по таблице сессий */
                FROM smfd_user.t_session ss
                WHERE ss.user_id = us.id
                LIMIT 1) IS NOT NULL                                                                                                 has_session,
               coalesce(perms.is_admin, FALSE)                                                                                       is_admin,
               us.last_pass_change_date IS NULL OR us.last_pass_change_date < (current_timestamp -
                                                                               smfd_settings.get_interval('USER_PASSWORD_LIFETIME')) need_to_change_pass,
               coalesce(perms.permissions, ARRAY [] :: RECORD[])                                                                     permissions
        FROM smfd_user.t_user us
                 LEFT JOIN (
            SELECT compound.user_id                                                            user_id,
                   max(compound.is_admin :: INT) :: BOOLEAN                                    is_admin,
                   array_agg((compound.permission_id, compound.is_role, compound.is_personal)) permissions
            FROM (
                     -- иды групп в качестве пермишнов
                     SELECT us_roles.user_id user_id,
                            us_roles.role_id permission_id,
                            TRUE             is_role,
                            FALSE            is_personal,
                            FALSE            is_admin
                     FROM smfd_user.t_user_roles us_roles
                     UNION ALL
                     -- и все пермишны групп в качестве пермишнов пользователя
                     SELECT us_roles.user_id       user_id,
                            perm.id                permission_id,
                            FALSE                  is_role,
                            FALSE                  is_personal,
                            role.is_administrative is_admin
                     FROM smfd_user.t_user_roles us_roles
                              LEFT JOIN smfd_user.t_role role ON us_roles.role_id = role.id
                              LEFT JOIN smfd_user.t_role_permissions role_perms ON role.id = role_perms.role_id
                              JOIN smfd_user.td_permission perm
                                   ON role_perms.permission_id = perm.id OR role.is_administrative
                     UNION ALL
                     -- персональные пермишны
                     SELECT us_perm.user_id       user_id,
                            us_perm.permission_id permission_id,
                            FALSE                 is_role,
                            TRUE                  is_personal,
                            FALSE                 is_admin
                     FROM smfd_user.t_user_permissions us_perm
                 ) compound
            GROUP BY compound.user_id
        ) perms ON perms.user_id = us.id AND us.block_date IS NULL
        ORDER BY is_admin DESC, us.block_date DESC, us.registration_date;

    OPEN po_permissions_dic FOR
        SELECT r.id  permission_id,
               r.name,
               r.description,
               r.is_administrative,
               TRUE  is_role,
               FALSE is_personal
        FROM smfd_user.t_role r
        UNION ALL
        SELECT p.id  permission_id,
               p.name,
               p.description,
               FALSE is_administrative,
               FALSE is_role,
               FALSE is_personal
        FROM smfd_user.td_permission p;

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

/* Получеине информации о пользователе */
CREATE OR REPLACE FUNCTION smfd_user.get_user_info(in pi_user_id int, /* id пользователя */
                                                   OUT po_users REFCURSOR, /* инфа о пользлвателе */
                                                   OUT po_permissions_dic REFCURSOR, /* список разрешений */
                                                   out po_is_admin int, /* админ или нет */
                                                   OUT po_result_code TEXT,
                                                   OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
BEGIN

    OPEN po_users FOR
        SELECT us.id,
               us.user_login,
               us.registration_date,
               us.block_date,
               us.first_name,
               us.last_name,
               us.middle_name,
               us.contact_phone,
               us.contact_email,
               us.org_id,
               (SELECT ss.user_id /* такой вот себе экзистс. настоящий делал в плане двойную выборку по таблице сессий */
                FROM smfd_user.t_session ss
                WHERE ss.user_id = us.id
                LIMIT 1) IS NOT NULL                                                                                                 has_session,
               coalesce(perms.is_admin, FALSE)                                                                                       is_admin,
               us.last_pass_change_date IS NULL OR us.last_pass_change_date < (current_timestamp -
                                                                               smfd_settings.get_interval('USER_PASSWORD_LIFETIME')) need_to_change_pass,
               coalesce(perms.permissions, ARRAY [] :: RECORD[])                                                                     permissions
        FROM smfd_user.t_user us
                 LEFT JOIN (
            SELECT compound.user_id                                                            user_id,
                   max(compound.is_admin :: INT) :: BOOLEAN                                    is_admin,
                   array_agg((compound.permission_id, compound.is_role, compound.is_personal)) permissions
            FROM (
                     -- иды групп в качестве пермишнов
                     SELECT us_roles.user_id user_id,
                            us_roles.role_id permission_id,
                            TRUE             is_role,
                            FALSE            is_personal,
                            FALSE            is_admin
                     FROM smfd_user.t_user_roles us_roles
                     UNION ALL
                     -- и все пермишны групп в качестве пермишнов пользователя
                     SELECT us_roles.user_id       user_id,
                            perm.id                permission_id,
                            FALSE                  is_role,
                            FALSE                  is_personal,
                            role.is_administrative is_admin
                     FROM smfd_user.t_user_roles us_roles
                              LEFT JOIN smfd_user.t_role role ON us_roles.role_id = role.id
                              LEFT JOIN smfd_user.t_role_permissions role_perms ON role.id = role_perms.role_id
                              JOIN smfd_user.td_permission perm
                                   ON role_perms.permission_id = perm.id OR role.is_administrative
                     UNION ALL
                     -- персональные пермишны
                     SELECT us_perm.user_id       user_id,
                            us_perm.permission_id permission_id,
                            FALSE                 is_role,
                            TRUE                  is_personal,
                            FALSE                 is_admin
                     FROM smfd_user.t_user_permissions us_perm
                 ) compound
            GROUP BY compound.user_id
        ) perms ON perms.user_id = us.id AND us.block_date IS NULL
        where us.id = pi_user_id
        ORDER BY is_admin DESC, us.block_date DESC, us.registration_date;

    OPEN po_permissions_dic FOR
        select distinct p.id
        from smfd_user.td_permission p
                 join smfd_user.t_role_permissions rp on p.id = rp.permission_id
                 join smfd_user.t_role r on r.id = rp.role_id
                 join smfd_user.t_user_roles ur on ur.role_id = r.id
        where ur.user_id = pi_user_id;

    select count(*)
    into po_is_admin
    from smfd_user.t_user_roles ur
    where ur.role_id = 'ROLE_ADMIN_GENERAL'
      and ur.user_id = pi_user_id;

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

/* Получение списка всех ролей у пользователей */
CREATE OR REPLACE FUNCTION smfd_user.get_users_roles(OUT po_roles REFCURSOR, /* результат */
                                                     OUT po_result_code TEXT,
                                                     OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
BEGIN

    OPEN po_roles FOR
        SELECT user_id, role_id FROM smfd_user.t_user_roles;

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

/* Изменение\удаление роли для пользователя */
create or replace function smfd_user.change_user_role(in pi_user_id int, /* id пользователя */
                                                      in pi_role_id varchar(64), /* id роли */
                                                      in pi_add int, /* Удалить или добавить */
                                                      OUT po_result_code text,
                                                      OUT po_result_message text)
    returns record
    language plpgsql
as
$$
BEGIN
    if pi_add = 1 then
        insert into smfd_user.t_user_roles (user_id, role_id) values (pi_user_id, pi_role_id);
    else
        delete from smfd_user.t_user_roles where user_id = pi_user_id and role_id = pi_role_id;
    end if;

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