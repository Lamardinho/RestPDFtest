CREATE SCHEMA IF NOT EXISTS smfd_report;

INSERT INTO smfd_task_manager.td_task_type (id, task_code, description)
VALUES (50, 'REPORT_BUILD', 'Создание отчетов');

DROP TYPE IF EXISTS smfd_report.S_REPORT CASCADE;
CREATE TYPE smfd_report.S_REPORT AS
(
    id           INT,
    title        TEXT,
    filename     TEXT,
    status       INT,
    mrf_id       INT,
    period_id    INT,
    form_id      INT,
    requester_id INT,
    isMvno       BOOLEAN,
    date         TIMESTAMP
);


DROP TABLE IF EXISTS smfd_report.td_report_status CASCADE;
CREATE TABLE IF NOT EXISTS smfd_report.td_report_status
(
    id   INT PRIMARY KEY NOT NULL,
    code VARCHAR         NOT NULL,
    name VARCHAR         NOT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS table_name_id_uindex
    ON smfd_report.td_report_status (id);
CREATE UNIQUE INDEX IF NOT EXISTS table_name_code_uindex
    ON smfd_report.td_report_status (code);
CREATE UNIQUE INDEX IF NOT EXISTS table_name_name_uindex
    ON smfd_report.td_report_status (name);

INSERT INTO smfd_report.td_report_status (id, code, name)
VALUES (-1, 'DELETED', 'Удалено');
INSERT INTO smfd_report.td_report_status (id, code, name)
VALUES (0, 'PROCESS', 'Формируется');
INSERT INTO smfd_report.td_report_status (id, code, name)
VALUES (1, 'SUCCESS', 'Сформировано');
INSERT INTO smfd_report.td_report_status (id, code, name)
VALUES (2, 'ABORTED', 'Отменено');


DROP TABLE IF EXISTS smfd_report.report_list CASCADE;
CREATE TABLE IF NOT EXISTS smfd_report.report_list
(
    id           SERIAL PRIMARY KEY                  NOT NULL,
    title        VARCHAR                             NOT NULL,
    filename     VARCHAR   DEFAULT NULL,
    status_id    INT                                 NOT NULL,
    mrf_id       INT                                 NOT NULL,
    period_id    INT                                 NOT NULL,
    form_id      INT                                 NOT NULL,
    requester_id INT                                 NOT NULL,
    is_mvno      BOOLEAN                             NOT NULL,
    date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT report_list_td_report_status_id_fk FOREIGN KEY (status_id) REFERENCES smfd_report.td_report_status (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT report_list_td_mrf_mrf_id_fk FOREIGN KEY (mrf_id) REFERENCES public.td_mrf (mrf_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT report_list_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT report_list_t_user_id_fk FOREIGN KEY (requester_id) REFERENCES smfd_user.t_user (id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX IF NOT EXISTS report_list_id_uindex
    ON smfd_report.report_list (id);
