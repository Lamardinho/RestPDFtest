/* ------------------------------------------------------------------------------------------------------------------------ */

CREATE TABLE IF NOT EXISTS smfd_user.td_permission
(
    id          VARCHAR(64) PRIMARY KEY NOT NULL,
    name        TEXT                    NOT NULL,
    embedded    INT DEFAULT 0,
    description TEXT
);
CREATE UNIQUE INDEX IF NOT EXISTS td_permission_id_uindex ON smfd_user.td_permission (id);
COMMENT ON TABLE smfd_user.td_permission IS 'Справочник разрешений и прав пользователей';
COMMENT ON COLUMN smfd_user.td_permission.id IS 'Идентификатор (код) разрешения';
COMMENT ON COLUMN smfd_user.td_permission.name IS 'Короткое имя разрешения';
COMMENT ON COLUMN smfd_user.td_permission.embedded is 'указание что данное разрешение является встроенным';
COMMENT ON COLUMN smfd_user.td_permission.description IS 'Описание';

INSERT INTO smfd_user.td_permission(id, name, description)
VALUES ('CREATE_USER', 'Редактирование пользователей', 'Включает редактирование, создание и блокировку пользователей'),
       ('CHANGE_USER_PWD', 'Смена пароля пользователя', 'Включает возможность смены пароля другим пользователям'),
       ('LOAD_XML_FILES', 'Загрузка XML файлов', 'Включает механизм загрузки XML файлов со счетами'),
       ('EDIT_TARGETING', 'Таргетирование рекламы', 'Включает возможность редактирования рекламы и её таргетирования');

/* ------------------------------------------------------------------------------------------------------------------------ */

CREATE TABLE IF NOT EXISTS smfd_user.t_role
(
    id                VARCHAR(64) PRIMARY KEY NOT NULL,
    name              TEXT                    NOT NULL,
    description       TEXT,
    is_administrative BOOLEAN DEFAULT FALSE   NOT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS table_name_id_uindex ON smfd_user.t_role (id);
COMMENT ON COLUMN smfd_user.t_role.id IS 'Идентификатор (код) роли';
COMMENT ON COLUMN smfd_user.t_role.name IS 'Короткое имя роли';
COMMENT ON COLUMN smfd_user.t_role.description IS 'Описание';
COMMENT ON COLUMN smfd_user.t_role.is_administrative IS 'Роль является административной в пределах других ограничений';

INSERT INTO smfd_user.t_role (id, name, description, is_administrative)
VALUES ('ROLE_ADMIN_GENERAL', 'Администратор', 'Включает основные административные права', TRUE),
       ('ROLE_NEW_USER', 'Новый пользователь СМФД', 'Новый пользователь, у которого не настроены права', FALSE);

/* ------------------------------------------------------------------------------------------------------------------------ */

CREATE TABLE IF NOT EXISTS smfd_user.t_role_permissions
(
    role_id       VARCHAR(64) NOT NULL,
    permission_id VARCHAR(64) NOT NULL,
    CONSTRAINT t_role_permissions_role_id_permission_id_pk PRIMARY KEY (role_id, permission_id),
    CONSTRAINT t_role_permissions_t_role_id_fk FOREIGN KEY (role_id) REFERENCES smfd_user.t_role (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_role_permissions_td_permission_id_fk FOREIGN KEY (permission_id) REFERENCES smfd_user.td_permission (id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS t_role_permissions_role_id_permission_id_index ON smfd_user.t_role_permissions (role_id, permission_id);
COMMENT ON COLUMN smfd_user.t_role_permissions.role_id IS 'Ссылка на справочник ролей';
COMMENT ON COLUMN smfd_user.t_role_permissions.permission_id IS 'Ссылка на справоничк разрешений';
COMMENT ON TABLE smfd_user.t_role_permissions IS 'Назначенные разрешения для роли';

/* ------------------------------------------------------------------------------------------------------------------------ */

CREATE TABLE IF NOT EXISTS smfd_user.t_role_permissions
(
    role_id       VARCHAR(64) NOT NULL,
    permission_id VARCHAR(64) NOT NULL,
    CONSTRAINT t_role_permissions_role_id_permission_id_pk PRIMARY KEY (role_id, permission_id),
    CONSTRAINT t_role_permissions_t_role_id_fk FOREIGN KEY (role_id) REFERENCES smfd_user.t_role (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_role_permissions_td_permission_id_fk FOREIGN KEY (permission_id) REFERENCES smfd_user.td_permission (id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS t_role_permissions_role_id_permission_id_index ON smfd_user.t_role_permissions (role_id, permission_id);
COMMENT ON COLUMN smfd_user.t_role_permissions.role_id IS 'Ссылка на справочник ролей';
COMMENT ON COLUMN smfd_user.t_role_permissions.permission_id IS 'Ссылка на справоничк разрешений';
COMMENT ON TABLE smfd_user.t_role_permissions IS 'Назначенные разрешения для роли';

/* ------------------------------------------------------------------------------------------------------------------------ */

CREATE TABLE IF NOT EXISTS smfd_user.t_user_roles
(
    user_id INT         NOT NULL,
    role_id VARCHAR(64) NOT NULL,
    CONSTRAINT t_user_roles_user_id_role_id_pk PRIMARY KEY (user_id, role_id),
    CONSTRAINT t_user_roles_t_user_id_fk FOREIGN KEY (user_id) REFERENCES smfd_user.t_user (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT t_user_roles_t_role_id_fk FOREIGN KEY (role_id) REFERENCES smfd_user.t_role (id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON COLUMN smfd_user.t_user_roles.user_id IS 'Ссылка на пользователя';
COMMENT ON COLUMN smfd_user.t_user_roles.role_id IS 'Ссылка на роль';
COMMENT ON TABLE smfd_user.t_user_roles IS 'Список ролей пользователя';

INSERT INTO smfd_user.t_user_roles (user_id, role_id)
VALUES (10000, 'ROLE_ADMIN_GENERAL');

/* ------------------------------------------------------------------------------------------------------------------------ */
