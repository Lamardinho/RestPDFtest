/* ------------------------------------------------------------------------------------------------------------------------ */
/* Таблица пользователей СМФД */
DROP TABLE IF EXISTS smfd_user.t_user CASCADE;
CREATE TABLE IF NOT EXISTS smfd_user.t_user
(
    id                    SERIAL
        CONSTRAINT t_user_pkey PRIMARY KEY                    NOT NULL,
    user_login            VARCHAR(64)                         NOT NULL,
    pass_hash             VARCHAR(64)                         NOT NULL,
    pass_salt             INT                                 NOT NULL,
    registration_date     TIMESTAMP DEFAULT current_timestamp NOT NULL,
    block_date            TIMESTAMP DEFAULT NULL,
    last_pass_change_date TIMESTAMP DEFAULT current_timestamp NOT NULL,
    first_name            VARCHAR(128)                        NOT NULL,
    last_name             VARCHAR(128)                        NOT NULL,
    middle_name           VARCHAR(128)                        NOT NULL,
    contact_phone         VARCHAR(11),
    contact_email         VARCHAR(200),
    org_id                INT,
    CONSTRAINT t_user_org_fk FOREIGN KEY (org_id) references smfd_user.t_organization (org_id) on delete set null
); -- smfd_user.t_user_id_seq
COMMENT ON TABLE smfd_user.t_user IS 'Пользователи СМФД';
COMMENT ON COLUMN smfd_user.t_user.id IS 'Идентификатор пользователя';
COMMENT ON COLUMN smfd_user.t_user.user_login IS 'Логин пользователя';
COMMENT ON COLUMN smfd_user.t_user.pass_hash IS 'Зашифрованный пароль';
COMMENT ON COLUMN smfd_user.t_user.pass_salt IS 'Соль пароля';
COMMENT ON COLUMN smfd_user.t_user.registration_date IS 'Дата создания пользователя';
COMMENT ON COLUMN smfd_user.t_user.block_date IS 'Дата блокировки или удаления';
COMMENT ON COLUMN smfd_user.t_user.last_pass_change_date IS 'Дата последней смены пароля';
COMMENT ON COLUMN smfd_user.t_user.first_name IS 'Имя';
COMMENT ON COLUMN smfd_user.t_user.last_name IS 'Фамилия';
COMMENT ON COLUMN smfd_user.t_user.middle_name IS 'Отчество';
COMMENT ON COLUMN smfd_user.t_user.contact_phone IS 'Контактный телефон';
COMMENT ON COLUMN smfd_user.t_user.contact_email IS 'Контактный емейл';

CREATE UNIQUE INDEX t_user_user_login_uindex ON smfd_user.t_user (user_login);
CREATE INDEX t_user_block_date_index ON smfd_user.t_user (block_date)
    WHERE (block_date IS NOT NULL);
ALTER SEQUENCE smfd_user.t_user_id_seq START 10000 RESTART 10000 MINVALUE 10000 MAXVALUE 1000000;

DROP TABLE IF EXISTS smfd_user.t_person CASCADE;
DROP TABLE IF EXISTS smfd_user.t_org_address CASCADE;
DROP TABLE IF EXISTS smfd_user.td_org_type CASCADE;
DROP TABLE IF EXISTS smfd_user.t_organization CASCADE;
DROP TABLE IF EXISTS smfd_user.t_org_tree CASCADE;
DROP TABLE IF EXISTS smfd_user.t_org_role CASCADE;

CREATE TABLE IF NOT EXISTS smfd_user.t_person
(
    person_id     SERIAL
        CONSTRAINT t_person_pkey PRIMARY KEY NOT NULL,
    first_name    varchar(30),
    middle_name   varchar(30),
    last_name     varchar(30),
    birthday      timestamp with time zone,
    sex           smallint,
    birthplace    varchar(150),
    contact_phone varchar(11),
    contact_mail  varchar(200)
);
comment on table smfd_user.t_person is 'Персона';
comment on column smfd_user.t_person.person_id is 'PK';
comment on column smfd_user.t_person.first_name is 'Имя';
comment on column smfd_user.t_person.middle_name is 'Отчество';
comment on column smfd_user.t_person.last_name is 'Фамилия';
comment on column smfd_user.t_person.birthday is 'Дата рождения';
comment on column smfd_user.t_person.sex is 'да';
comment on column smfd_user.t_person.birthplace is 'Место рождения';
comment on column smfd_user.t_person.contact_phone is 'контактный номер телефона';
comment on column smfd_user.t_person.contact_mail is 'e-mail';

CREATE TABLE IF NOT EXISTS smfd_user.t_org_address
(
    address_id SERIAL
        CONSTRAINT t_org_address_pkey PRIMARY KEY NOT NULL,
    country    varchar(200),
    index_post varchar(12),
    city       varchar(200),
    street     varchar(200),
    house      varchar(200),
    office     varchar(200)
);
comment on table smfd_user.t_org_address is 'Адрес';
comment on column smfd_user.t_org_address.address_id is 'ПК';
comment on column smfd_user.t_org_address.country is 'Страна';
comment on column smfd_user.t_org_address.index_post is 'Почтовый индекс';
comment on column smfd_user.t_org_address.city is 'Город';
comment on column smfd_user.t_org_address.street is 'Улица';
comment on column smfd_user.t_org_address.house is 'Строение';
comment on column smfd_user.t_org_address.office is 'офис (квартира)';

CREATE TABLE IF NOT EXISTS smfd_user.td_org_type
(
    id   SERIAL
        CONSTRAINT td_org_type_pkey PRIMARY KEY NOT NULL,
    name varchar(200)                           not null
);
comment on table smfd_user.td_org_type is 'Справочник типов организаций';
comment on column smfd_user.td_org_type.id is 'ПК';
comment on column smfd_user.td_org_type.name is 'название';

CREATE TABLE IF NOT EXISTS smfd_user.t_organization
(
    org_id         SERIAL
        CONSTRAINT t_organization_pkey PRIMARY KEY NOT NULL,
    name           varchar(200)                    not null,
    full_name      varchar(500),
    address_fakt   bigint
        constraint t_organization_t_org_address_fk references smfd_user.t_org_address (address_id) ON DELETE CASCADE ON UPDATE CASCADE,
    person_contact bigint
        constraint t_organization_t_person_fk references smfd_user.t_person (person_id),
    org_type       bigint                          not null
        constraint t_organization_t_org_type_fk references smfd_user.td_org_type (id),
    description    varchar(2000)
);
comment on table smfd_user.t_organization is 'Справочник организаций';
comment on column smfd_user.t_organization.org_id is 'ПК';
comment on column smfd_user.t_organization.name is 'Наименование организации';
comment on column smfd_user.t_organization.full_name is 'Полное наименование организации';
comment on column smfd_user.t_organization.address_fakt is 'Фактический адрес (t_address)';
comment on column smfd_user.t_organization.person_contact is 'Контактное лицо (t_person)';
comment on column smfd_user.t_organization.org_type is 'тип организаци (подраздление, юр. лицо) t_dic_org_type';
comment on column smfd_user.t_organization.description is 'Примечание';

CREATE TABLE IF NOT EXISTS smfd_user.t_org_tree
(
    org_id  int not null
        constraint t_org_tree_t_organization_id_fk references smfd_user.t_organization (org_id) on delete cascade,
    org_pid bigint
        constraint t_org_tree_t_organization_pid_fk references smfd_user.t_organization (org_id) on delete cascade
);
comment on table smfd_user.t_org_tree is 'Готовое дерево связей между организациями';
comment on column smfd_user.t_org_tree.org_id is 'Организация (t_organization)';
comment on column smfd_user.t_org_tree.org_pid is 'Родительская организация (t_organization)';

CREATE TABLE IF NOT EXISTS smfd_user.t_org_role
(
    org_id  int not null
        constraint t_org_role_t_organization_id_fk references smfd_user.t_organization (org_id) on delete cascade,
    role_id varchar(64)
        constraint t_org_role_t_organization_pid_fk references smfd_user.t_role (id) on delete cascade,
    CONSTRAINT t_org_role_pk PRIMARY KEY (org_id, role_id)
);
comment on table smfd_user.t_org_role is 'роли огранизации';
comment on column smfd_user.t_org_role.org_id is 'Организация (t_organization)';
comment on column smfd_user.t_org_role.role_id is 'роль (t_role)';

/* Сохранение информации о персоне в организации */
CREATE OR REPLACE FUNCTION smfd_user.save_person(in pi_first_name varchar(30),
                                                 in pi_middle_name varchar(30),
                                                 in pi_last_name varchar(30),
                                                 in pi_birthday timestamp,
                                                 in pi_sex int,
                                                 in pi_phone varchar(11),
                                                 in pi_email varchar(200),
                                                 in pi_person_id int,
                                                 out po_person_id int, /* id сохраненной персоны */
                                                 OUT po_result_code TEXT,
                                                 OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
begin

    if pi_person_id is not null then
        update smfd_user.t_person
        set first_name    = pi_first_name,
            middle_name   = pi_middle_name,
            last_name     = pi_last_name,
            birthday      = pi_birthday,
            sex           = pi_sex,
            contact_phone = pi_phone,
            contact_mail  = pi_email
        where person_id = pi_person_id;
        po_person_id := pi_person_id;
    else
        insert into smfd_user.t_person (first_name, middle_name, last_name, birthday, sex, contact_phone, contact_mail)
        values (pi_first_name, pi_middle_name, pi_last_name, pi_birthday, pi_sex, pi_phone, pi_email)
        returning person_id into po_person_id;
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

/* Сохранение адреса организации */
CREATE OR REPLACE FUNCTION smfd_user.save_org_address(in pi_country varchar(200),
                                                      in pi_index_post varchar(12),
                                                      in pi_city varchar(200),
                                                      in pi_street varchar(200),
                                                      in pi_house varchar(200),
                                                      in pi_office varchar(200),
                                                      in pi_address_id int,
                                                      out po_address_id int, /* id сохраненного адреса */
                                                      OUT po_result_code TEXT,
                                                      OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
begin

    if pi_address_id is not null then
        update smfd_user.t_org_address
        set country    = pi_country,
            index_post = pi_index_post,
            city       = pi_city,
            street     = pi_street,
            house      = pi_house,
            office     = pi_office
        where address_id = pi_address_id;
        po_address_id := pi_address_id;
    else
        insert into smfd_user.t_org_address (country, index_post, city, street, house, office)
        values (pi_country, pi_index_post, pi_city, pi_street, pi_house, pi_office)
        returning address_id into po_address_id;
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

/* Создание орагнизации */
CREATE OR REPLACE FUNCTION smfd_user.create_organization(in pi_name varchar(200),
                                                         in pi_full_name varchar(500),
                                                         in pi_address_id int,
                                                         in pi_person_id int,
                                                         in pi_type_id int,
                                                         in pi_description varchar(2000),
                                                         in pi_parent_id int,
                                                         out po_org_id int,
                                                         OUT po_result_code TEXT,
                                                         OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql as
$$
begin
    insert into smfd_user.t_organization (name, full_name, address_fakt, person_contact, org_type, description)
    VALUES (pi_name, pi_full_name, pi_address_id, pi_person_id, pi_type_id, pi_description)
    returning org_id into po_org_id;

    if pi_parent_id is not null then
        insert into smfd_user.t_org_tree (org_id, org_pid) values (po_org_id, pi_parent_id);
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

/* Редактирование организации */
CREATE OR REPLACE FUNCTION smfd_user.edit_organization(in pi_orgId int, /* id */
                                                       in pi_name varchar(200), /* имя */
                                                       in pi_full_name varchar(500), /* полное имя */
                                                       in pi_address_id int, /* адрес */
                                                       in pi_person_id int, /* id контакта */
                                                       in pi_type_id int, /* тип */
                                                       in pi_description varchar(2000), /* описание */
                                                       OUT po_result_code TEXT,
                                                       OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql as
$$
begin

    update smfd_user.t_organization
    set name           = pi_name,
        full_name      = pi_full_name,
        address_fakt   = pi_address_id,
        person_contact = pi_person_id,
        org_type       = pi_type_id,
        description    = pi_description
    where org_id = pi_orgId;

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

/* Получение всех организаций */
CREATE OR REPLACE FUNCTION smfd_user.get_organizations(out po_organizations refcursor, /* результат */
                                                       OUT po_result_code text,
                                                       OUT po_result_message text) returns record
    language plpgsql
as
$$
BEGIN
    open po_organizations for
        select o.org_id,
               o.name,
               o.full_name,
               o.description,
               o.address_fakt,
               o.org_type,
               o.person_contact,
               t.org_pid,
               a.city,
               a.country,
               a.house,
               a.index_post,
               a.office,
               a.street,
               p.first_name,
               p.last_name,
               p.middle_name,
               p.sex,
               p.birthday,
               p.contact_phone,
               p.contact_mail
        from smfd_user.t_organization o
                 left join smfd_user.t_org_tree t on o.org_id = t.org_id
                 left join smfd_user.t_org_address a on o.address_fakt = a.address_id
                 left join smfd_user.t_person p on p.person_id = o.person_contact;

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


insert into smfd_user.td_org_type (id, name)
values (1, 'подразделение');
insert into smfd_user.td_org_type (id, name)
values (2, 'Юр. Лицо');
insert into smfd_user.td_org_type (id, name)
values (3, 'МРФ');
insert into smfd_user.td_org_type (id, name)
values (4, 'Филиал');
insert into smfd_user.td_org_type (id, name)
values (5, 'Внешняя система');

/* Получение всех разрешений (пермишинов) */
CREATE OR REPLACE FUNCTION smfd_user.get_all_permission(out po_permissions refcursor, /* курсор с результатом */
                                                        OUT po_result_code text,
                                                        OUT po_result_message text)
    returns record
    language plpgsql
as
$$
BEGIN
    open po_permissions for
        select t.id, t.name, t.description from smfd_user.td_permission t where t.embedded = 0;

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

/* Получение всех ролей */
CREATE OR REPLACE FUNCTION smfd_user.get_all_roles(out po_roles refcursor, /* результат */
                                                   OUT po_result_code text,
                                                   OUT po_result_message text)
    returns record
    language plpgsql
as
$$
BEGIN
    open po_roles for
        select r.id, r.description, r.name, oro.org_id
        from smfd_user.t_role r
                 join smfd_user.t_org_role oro on r.id = oro.role_id;

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

/* Создание роли */
CREATE OR REPLACE FUNCTION smfd_user.create_role(in pi_org_id int, /*  */
                                                 in pi_role_id varchar(64), /* id роли */
                                                 in pi_name varchar(200), /* наименование */
                                                 in pi_description varchar(500), /* описание */
                                                 OUT po_result_code text,
                                                 OUT po_result_message text)
    returns record
    language plpgsql
as
$$
BEGIN
    insert into smfd_user.t_role (id, name, description) VALUES (pi_role_id, pi_name, pi_description);

    insert into smfd_user.t_org_role (org_id, role_id) values (pi_org_id, pi_role_id);

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

/* Добавление пермишена к роли */
CREATE OR REPLACE FUNCTION smfd_user.add_perm_to_role(in pi_role_id varchar(64), /* id роли */
                                                      in pi_perm_id varchar(64), /* id пермишена */
                                                      OUT po_result_code text,
                                                      OUT po_result_message text)
    returns record
    language plpgsql
as
$$
BEGIN
    insert into smfd_user.t_role_permissions (role_id, permission_id) values (pi_role_id, pi_perm_id);

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

/* Удаление пермишена у роли */
CREATE OR REPLACE FUNCTION smfd_user.del_perm_role(in pi_role_id varchar(64), /* роль */
                                                   in pi_perm_id varchar(64), /* разрешение */
                                                   OUT po_result_code text,
                                                   OUT po_result_message text)
    returns record
    language plpgsql
as
$$
BEGIN
    delete from smfd_user.t_role_permissions where role_id = pi_role_id and permission_id = pi_perm_id;
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

/* Получение всех разрешений у роли */
CREATE OR REPLACE FUNCTION smfd_user.get_role_perms(in pi_role_id varchar(64), /* id роли */
                                                    out po_perm_ids refcursor, /* результат */
                                                    OUT po_result_code text,
                                                    OUT po_result_message text)
    returns record
    language plpgsql
as
$$
BEGIN
    open po_perm_ids for
        select permission_id from smfd_user.t_role_permissions where role_id = pi_role_id;

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

/* удаление роли */
CREATE OR REPLACE FUNCTION smfd_user.delete_role(IN pi_role_id VARCHAR(64), /* id роли */
                                                 OUT po_result_code TEXT,
                                                 OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN

    delete from smfd_user.t_role where id = pi_role_id;

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