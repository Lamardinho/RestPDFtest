/* Создание записи об отчете */
DROP FUNCTION IF EXISTS smfd_report.create_report(VARCHAR, INT, INT, INT, INT, BOOLEAN);
CREATE OR REPLACE FUNCTION smfd_report.create_report(pi_title VARCHAR, /* название */
                                                     pi_user_id INT, /* пользователь */
                                                     pi_mrf_id INT, /* мрф */
                                                     pi_period_id INT, /* период */
                                                     pi_form_id INT, /* тип формы отчета */
                                                     pi_is_mvno BOOLEAN, /* МВНО или нет */
                                                     OUT po_report_id INT, /* id записи */
                                                     OUT po_result_code TEXT,
                                                     OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
DECLARE
    status    INT;
    report_id INT;
BEGIN
    status := 0;
    INSERT INTO smfd_report.report_list (title, filename, status_id, mrf_id, period_id, form_id, requester_id, is_mvno)
    VALUES (pi_title, NULL, status, pi_mrf_id, pi_period_id, pi_form_id, pi_user_id, pi_is_mvno)
    RETURNING id INTO report_id;

    po_report_id := report_id;
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

/* Получаение списка доступных отчетов для пользователя */
DROP FUNCTION IF EXISTS smfd_report.get_available_reports(INTEGER);
CREATE OR REPLACE FUNCTION smfd_report.get_available_reports(pi_user_id INT, /* пользователь */
                                                             OUT po_reports REFCURSOR, /* результат */
                                                             OUT po_result_code TEXT,
                                                             OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    OPEN po_reports FOR
        SELECT rl.id    id,
               rl.date  date,
               rl.title title,
               rs.name  status,
               rs.id    status_id
        FROM smfd_report.report_list rl
                 LEFT JOIN smfd_report.td_report_status rs ON rs.id = rl.status_id
        WHERE rl.requester_id = pi_user_id
          AND rl.status_id IN (0, 1, 3);

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

/* Получение информации об отчете по id */
DROP FUNCTION IF EXISTS smfd_report.get_report_by_id(INTEGER);
CREATE OR REPLACE FUNCTION smfd_report.get_report_by_id(pi_report_id INT, /* id отчета */
                                                        OUT po_report smfd_report.S_REPORT, /* информация об отчете */
                                                        OUT po_result_code TEXT,
                                                        OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    SELECT rl.id,
           rl.title,
           rl.filename,
           rl.status_id,
           rl.mrf_id,
           rl.period_id,
           rl.form_id,
           rl.requester_id,
           rl.is_mvno,
           rl.date
    INTO po_report
    FROM smfd_report.report_list rl
    WHERE rl.id = pi_report_id;

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

/* Изменение статуса создания отчета (если успех, то передается так же путь до файла) */
DROP FUNCTION IF EXISTS smfd_report.change_report_status(INT, INT, INT, VARCHAR);
CREATE OR REPLACE FUNCTION smfd_report.change_report_status(pi_report_id INT, /* id отчета */
                                                            pi_user_id INT, /* id юзера */
                                                            pi_new_status_id INT, /* id нового статуса */
                                                            pi_report_name VARCHAR DEFAULT NULL, /* имя файла отчета */
                                                            OUT po_result_code TEXT,
                                                            OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    UPDATE smfd_report.report_list
    SET status_id = (
        CASE
            WHEN pi_report_name IS NULL AND pi_new_status_id = 1
                THEN status_id
            ELSE pi_new_status_id
            END
        ),
        filename  = (
            CASE
                WHEN pi_report_name IS NOT NULL AND pi_new_status_id = 1
                    THEN pi_report_name
                ELSE filename
                END
            )
    WHERE requester_id = pi_user_id
      AND id = pi_report_id;

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