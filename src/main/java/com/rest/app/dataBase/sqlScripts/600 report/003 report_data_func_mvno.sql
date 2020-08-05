-- noinspection SqlResolveForFile

-- form_one_mvno
DROP FUNCTION IF EXISTS smfd_report.get_report_form_one_mvno(INT, INT);
CREATE OR REPLACE FUNCTION smfd_report.get_report_form_one_mvno(pi_mrf_id INT,
                                                                pi_period_id INT,
                                                                OUT po_data REFCURSOR,
                                                                OUT po_result_code TEXT,
                                                                OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    DROP TABLE IF EXISTS temp_table_form_one_mvno;
    CREATE TEMPORARY TABLE temp_table_form_one_mvno WITH (OIDS = FALSE
        )
                                                    ON COMMIT DROP AS
    SELECT ARRAY [
               'N' :: TEXT, -- N
               MRF.mrf_name :: TEXT, -- МРФ
               (REG.region_name || ' (' || REG.region_id || ')') :: TEXT, -- Регион
               FPD.send_status :: TEXT, -- Статус отправки
               AB.account_number :: TEXT, -- Номер лс
               '{' || AB.account_number || '}' :: TEXT, -- Какая то хрень связанная с лс (UID)
               BA.full_name :: TEXT, -- Фио
               (
                                                   CITY.city_type || ' ' || CITY.city_name || ', '
                                                   || AA.street_type || ' ' || AA.street || ', '
                                   || 'дом ' || AA.house || ', квартира ' || AA.flat
                   ) :: TEXT
               ] :: TEXT[] data_array
    FROM smfd_data.t_forming_publishing FP
             JOIN smfd_data.t_forming_history FH ON FH.id = FP.history_id
             JOIN smfd_data.t_forming_publishing_details_base FPD ON FPD.publishing_id = FP.id
             JOIN smfd_data.t_bill_base BB ON BB.id = FPD.bill_id
             JOIN smfd_data.t_bill_accounts_base AB ON AB.bill_id = BB.id
             JOIN smfd_data.t_bill_abonent BA ON BA.id = AB.abonent_id
             JOIN smfd_data.t_address AA ON AA.id = BA.address
             JOIN t_city CITY ON CITY.id = AA.city_id
             JOIN td_mrf MRF ON MRF.mrf_id = pi_mrf_id
             JOIN td_region REG ON REG.mrf_id = MRF.mrf_id
    WHERE FP.period_id = pi_period_id
      AND FP.region_id IN (REG.region_id)
      AND NOT FH.is_test_forming
      AND FPD.send_status <> 200
      AND FPD.send_status <> 1
      AND BB.forming_type > 100
    ORDER BY REG.region_name;

    OPEN po_data FOR
        SELECT arr.data_array data_array
        FROM temp_table_form_one_mvno arr;

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

-- form_two_mvno
DROP FUNCTION IF EXISTS smfd_report.get_report_form_two_mvno(INT, INT);
CREATE OR REPLACE FUNCTION smfd_report.get_report_form_two_mvno(pi_mrf_id INT,
                                                                pi_period_id INT,
                                                                OUT po_data REFCURSOR,
                                                                OUT po_result_code TEXT,
                                                                OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    DROP TABLE IF EXISTS temp_table_form_two_mvno;
    CREATE TEMPORARY TABLE temp_table_form_two_mvno WITH (OIDS = FALSE
        )
                                                    ON COMMIT DROP AS
    SELECT ARRAY [
               'N' :: TEXT,
               MRF.mrf_name :: TEXT,
               (REG.region_name || ' (' || REG.region_id || ')') :: TEXT,
               AB.account_number :: TEXT,
               '{' || AB.account_number || '}' :: TEXT,
               BA.full_name :: TEXT,
               BB.email :: TEXT,
               ' ' :: TEXT,
               BP.date :: TEXT,
               FP.created_date :: TEXT,
               ' ' :: TEXT,
               'email' :: TEXT
               ] :: TEXT[] data_array
    FROM smfd_data.t_forming_publishing FP
             JOIN smfd_data.t_forming_history FH ON FH.id = FP.history_id
             JOIN smfd_data.t_forming_publishing_details_base FPD ON FPD.publishing_id = FP.id
             JOIN smfd_data.t_bill_base BB ON BB.id = FPD.bill_id
             JOIN smfd_data.t_bill_accounts_base AB ON AB.bill_id = BB.id
             JOIN smfd_data.t_bill_abonent BA ON BA.id = AB.abonent_id
             JOIN td_mrf MRF ON MRF.mrf_id = pi_mrf_id
             JOIN td_region REG ON REG.mrf_id = MRF.mrf_id
             JOIN smfd_data.t_billing_period BP ON BP.id = FP.period_id
    WHERE FP.period_id = pi_period_id
      AND FP.region_id IN (REG.region_id)
      AND NOT FH.is_test_forming
      AND BB.forming_type > 100
    ORDER BY REG.region_name;

    OPEN po_data FOR
        SELECT arr.data_array data_array
        FROM temp_table_form_two_mvno arr;

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

-- form_seven_mvno
DROP FUNCTION IF EXISTS smfd_report.get_report_form_seven_mvno(INT, INT);
CREATE OR REPLACE FUNCTION smfd_report.get_report_form_seven_mvno(pi_mrf_id INT,
                                                                  pi_period_id INT,
                                                                  OUT po_data REFCURSOR,
                                                                  OUT po_result_code TEXT,
                                                                  OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    DROP TABLE IF EXISTS temp_table_form_seven_mvno;
    CREATE TEMPORARY TABLE temp_table_form_seven_mvno WITH (OIDS = FALSE
        )
                                                      ON COMMIT DROP AS
    SELECT ARRAY [
               'N' :: TEXT,
               MRF.mrf_name :: TEXT,
               (REG.region_name || ' (' || REG.region_id || ')') :: TEXT,
               AB.account_number :: TEXT,
               '{' || AB.account_number || '}' :: TEXT,
               BA.full_name :: TEXT,
               BB.email :: TEXT,
               coalesce(BA.contact_phone, ' ') :: TEXT,
               (CASE
                    WHEN FPD.send_status BETWEEN 200 AND 299
                        THEN 'Доставлено'
                    WHEN FPD.send_status BETWEEN 400 AND 599
                        THEN 'Не доставлено'
                    WHEN FPD.send_status = 1
                        THEN 'Готово к отправке'
                    ELSE 'Неизвестно'
                   END
                   ), -- Статус
               FPD.change_status_date :: TEXT,
               ' ' :: TEXT, -- Колличество попыток
               (CASE
                    WHEN FPD.send_status BETWEEN 200 AND 299
                        THEN ' '
                    WHEN FPD.send_status = 1
                        THEN ' '
                    ELSE FPD.send_status :: TEXT
                   END
                   ) -- Причина недоставки
               ] :: TEXT[] data_array
    FROM smfd_data.t_forming_publishing FP
             JOIN smfd_data.t_forming_history FH ON FH.id = FP.history_id
             JOIN smfd_data.t_forming_publishing_details_base FPD ON FPD.publishing_id = FP.id
             JOIN smfd_data.t_bill_base BB ON BB.id = FPD.bill_id
             JOIN smfd_data.t_bill_accounts_base AB ON AB.bill_id = BB.id
             JOIN smfd_data.t_bill_abonent BA ON BA.id = AB.abonent_id
             JOIN public.td_mrf MRF ON MRF.mrf_id = pi_mrf_id
             JOIN public.td_region REG ON REG.mrf_id = MRF.mrf_id
    WHERE FP.period_id = pi_period_id
      AND FP.region_id IN (REG.region_id)
      AND NOT FH.is_test_forming
      AND BB.forming_type > 100
    ORDER BY REG.region_name;

    OPEN po_data FOR
        SELECT arr.data_array data_array
        FROM temp_table_form_seven_mvno arr;

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

-- form_aggregate_mvno
DROP FUNCTION IF EXISTS smfd_report.get_report_form_aggregate_mvno(INT, INT);
CREATE OR REPLACE FUNCTION smfd_report.get_report_form_aggregate_mvno(pi_mrf_id INT,
                                                                      pi_period_id INT,
                                                                      OUT po_data REFCURSOR,
                                                                      OUT po_result_code TEXT,
                                                                      OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    DROP TABLE IF EXISTS temp_table_form_aggregate_mvno;
    CREATE TEMPORARY TABLE temp_table_form_aggregate_mvno WITH (OIDS = FALSE
        )
                                                          ON COMMIT DROP AS
    SELECT ARRAY [
               'N' :: TEXT,
               MRF.mrf_name :: TEXT,
               REG.region_name :: TEXT,
               COUNT(FPD.publishing_id) :: TEXT,
               COUNT(nullif(FPD.send_status, 200)) :: TEXT,
               MIN(FP.created_date) :: TEXT,
               MAX(FP.created_date) :: TEXT,
               MIN(FPD.change_status_date) :: TEXT,
               MAX(FPD.change_status_date) :: TEXT
               ] :: TEXT[] data_array
    FROM smfd_data.t_forming_publishing_details_base FPD
             JOIN smfd_data.t_forming_publishing FP ON FP.id = FPD.publishing_id
             JOIN smfd_data.t_forming_history FH ON FH.id = FP.history_id
             JOIN smfd_data.t_bill_base BB ON BB.id = FPD.bill_id
             JOIN td_mrf MRF ON MRF.mrf_id = pi_mrf_id
             JOIN td_region REG ON REG.mrf_id = MRF.mrf_id
    WHERE NOT FH.is_test_forming
      AND FP.period_id = pi_period_id
      AND FP.region_id IN (REG.region_id)
      AND FPD.send_status <> 1
      AND BB.forming_type > 100
    GROUP BY MRF.mrf_name, REG.region_name
    ORDER BY REG.region_name;

    OPEN po_data FOR
        SELECT arr.data_array data_array
        FROM temp_table_form_aggregate_mvno arr;

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

-- form_one_agg_mvno
DROP FUNCTION IF EXISTS smfd_report.get_report_form_one_agg_mvno(INT, INT);
CREATE OR REPLACE FUNCTION smfd_report.get_report_form_one_agg_mvno(pi_mrf_id INT,
                                                                    pi_period_id INT,
                                                                    OUT po_data REFCURSOR,
                                                                    OUT po_result_code TEXT,
                                                                    OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    DROP TABLE IF EXISTS temp_table_form_one_agg_mvno;
    CREATE TEMPORARY TABLE temp_table_form_one_agg_mvno WITH (OIDS = FALSE
        )
                                                        ON COMMIT DROP AS
    SELECT ARRAY [
               'N' :: TEXT,
               MRF.mrf_name :: TEXT,
               REG.region_name :: TEXT,
               count(FPD.send_status)
               ] :: TEXT[] data_array
    FROM smfd_data.t_forming_publishing FP
             JOIN smfd_data.t_forming_history FH ON FH.id = FP.history_id
             JOIN smfd_data.t_forming_publishing_details_base FPD ON FPD.publishing_id = FP.id
             JOIN smfd_data.t_bill_base BB ON BB.id = FPD.bill_id
             JOIN td_mrf MRF ON MRF.mrf_id = pi_mrf_id
             JOIN td_region REG ON REG.mrf_id = MRF.mrf_id
    WHERE FP.period_id = pi_period_id
      AND FP.region_id IN (REG.region_id)
      AND NOT FH.is_test_forming
      AND FPD.send_status <> 1
      AND FPD.send_status <> 200
      AND BB.delivery_type = 6
      AND BB.forming_type > 100
    GROUP BY MRF.mrf_name, REG.region_name
    ORDER BY MRF.mrf_name, REG.region_name;

    OPEN po_data FOR
        SELECT arr.data_array data_array
        FROM temp_table_form_one_agg_mvno arr;

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

-- form_elk_screen_mvno
DROP FUNCTION IF EXISTS smfd_report.get_report_form_elk_screen_mvno(INT, INT);
CREATE OR REPLACE FUNCTION smfd_report.get_report_form_elk_screen_mvno(pi_mrf_id INT,
                                                                       pi_period_id INT,
                                                                       OUT po_data REFCURSOR,
                                                                       OUT po_result_code TEXT,
                                                                       OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    DROP TABLE IF EXISTS temp_table_form_elk_screen_mvno;
    CREATE TEMPORARY TABLE temp_table_form_elk_screen_mvno WITH (OIDS = FALSE
        )
                                                           ON COMMIT DROP AS
    SELECT ARRAY [
               'N' :: TEXT,
               MRF.mrf_name :: TEXT,
               REG.region_name :: TEXT,
               FPD.send_status :: TEXT,
               AB.account_number :: TEXT,
               '{' || AB.account_number || '}' :: TEXT,
               BA.full_name :: TEXT,
               (
                                                   CITY.city_type || ' ' || CITY.city_name || ', '
                                                   || AA.street_type || ' ' || AA.street || ', '
                                   || 'дом ' || AA.house || ', квартира ' || AA.flat
                   ) :: TEXT
               ] :: TEXT[] data_array
    FROM smfd_data.t_forming_publishing FP
             JOIN smfd_data.t_forming_history FH ON FH.id = FP.history_id
             JOIN smfd_data.t_forming_publishing_details_base FPD ON FPD.publishing_id = FP.id
             JOIN smfd_data.t_bill_base BB ON BB.id = FPD.bill_id
             JOIN smfd_data.t_bill_accounts_base AB ON AB.bill_id = BB.id
             JOIN smfd_data.t_bill_abonent BA ON BA.id = AB.abonent_id
             JOIN td_mrf MRF ON MRF.mrf_id = pi_mrf_id
             JOIN td_region REG ON REG.mrf_id = MRF.mrf_id
    WHERE FP.period_id = pi_period_id
      AND FP.region_id IN (REG.region_id)
      AND NOT FH.is_test_forming
      AND NOT FH.is_mass_forming
      AND BB.forming_type > 100
    ORDER BY MRF.mrf_name, REG.region_name, FPD.send_status;

    OPEN po_data FOR
        SELECT arr.data_array data_array
        FROM temp_table_form_elk_screen_mvno arr;

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

-- form_elk_agg_mvno
DROP FUNCTION IF EXISTS smfd_report.get_report_form_elk_agg_mvno(INT, INT);
CREATE OR REPLACE FUNCTION smfd_report.get_report_form_elk_agg(pi_mrf_id INT,
                                                               pi_period_id INT,
                                                               OUT po_data REFCURSOR,
                                                               OUT po_result_code TEXT,
                                                               OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    DROP TABLE IF EXISTS temp_table_form_elk_agg_mvno;
    CREATE TEMPORARY TABLE temp_table_form_elk_agg_mvno WITH (OIDS = FALSE)
                                                        ON COMMIT DROP AS
    SELECT ARRAY [
               'N' :: TEXT,
               MRF.mrf_name :: TEXT,
               REG.region_name :: TEXT,
               count(BB.id) :: TEXT
               ] :: TEXT[] data_array
    FROM smfd_task_manager.t_task_m2m_report M2M
             JOIN smfd_task_manager.t_task T ON T.id = M2M.task_id
             JOIN smfd_task_manager.t_task_params TP ON TP.task_id = T.id
             JOIN smfd_data.t_bill_base BB ON BB.id = CAST(TP.param_value AS INTEGER)
             JOIN td_mrf MRF ON MRF.mrf_id = pi_mrf_id
             JOIN td_region REG ON REG.mrf_id = MRF.mrf_id
    WHERE M2M.source_id = 'ELK'
      AND T.task_type = 30
      AND T.task_status = 3
      AND TP.param_key = 'docXaId'
      AND BB.period_id = pi_period_id
      AND BB.region_id IN (REG.region_id)
      AND BB.forming_type > 100
    GROUP BY MRF.mrf_name, REG.region_name
    ORDER BY MRF.mrf_name, REG.region_name;

    OPEN po_data FOR
        SELECT arr.data_array data_array
        FROM temp_table_form_elk_agg_mvno arr;

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

-- form_elk_mvno
DROP FUNCTION IF EXISTS smfd_report.get_report_form_elk_mvno(INT, INT);
CREATE OR REPLACE FUNCTION smfd_report.get_report_form_elk_mvno(pi_mrf_id INT,
                                                                pi_period_id INT,
                                                                OUT po_data REFCURSOR,
                                                                OUT po_result_code TEXT,
                                                                OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    DROP TABLE IF EXISTS temp_table_form_elk_mvno;
    CREATE TEMPORARY TABLE temp_table_form_elk_mvno WITH (OIDS = FALSE
        )
                                                    ON COMMIT DROP AS
    SELECT ARRAY [
               'N' :: TEXT,
               MRF.mrf_name :: TEXT,
               REG.region_name :: TEXT,
               AB.account_number :: TEXT,
               '{' || AB.account_number || '}' :: TEXT,
               BA.full_name :: TEXT,
               coalesce(BA.contact_phone, ' ') :: TEXT,
               BP.date :: TEXT,
               T.status_change_date :: TEXT,
               DT.dt_code,
               coalesce(BB.email, ' ') :: TEXT,
               'Нет' :: TEXT,
               BB.id :: TEXT
               ] :: TEXT[] data_array
    FROM smfd_task_manager.t_task_m2m_report M2M
             JOIN smfd_task_manager.t_task T ON T.id = M2M.task_id
             JOIN smfd_task_manager.t_task_params TP ON TP.task_id = T.id
             JOIN smfd_data.t_bill_base BB ON BB.id = CAST(TP.param_value AS INTEGER)
             JOIN smfd_data.t_delivery_type DT ON DT.id = BB.delivery_type
             JOIN smfd_data.t_billing_period BP ON BP.id = BB.period_id
             JOIN smfd_data.t_bill_accounts_base AB ON AB.bill_id = BB.id
             JOIN smfd_data.t_bill_abonent BA ON BA.id = AB.abonent_id
             JOIN td_mrf MRF ON MRF.mrf_id = pi_mrf_id
             JOIN td_region REG ON REG.mrf_id = MRF.mrf_id
    WHERE M2M.source_id = 'ELK'
      AND T.task_type = 30
      AND T.task_status = 3
      AND TP.param_key = 'docXaId'
      AND BB.period_id = pi_period_id
      AND BB.forming_type > 100
      AND BB.region_id IN (REG.region_id)
    ORDER BY MRF.mrf_name, REG.region_name;

    OPEN po_data FOR
        SELECT arr.data_array data_array
        FROM temp_table_form_elk_mvno arr;

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

-- form_10_mvno
DROP FUNCTION IF EXISTS smfd_report.get_report_form_ten_mvno(INT, INT);
CREATE OR REPLACE FUNCTION smfd_report.get_report_form_ten_mvno(pi_mrf_id INT,
                                                                pi_period_id INT,
                                                                OUT po_data REFCURSOR,
                                                                OUT po_result_code TEXT,
                                                                OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    DROP TABLE IF EXISTS temp_table_form_ten_mvno;
    CREATE TEMPORARY TABLE temp_table_form_ten_mvno WITH (OIDS = FALSE)
                                                    ON COMMIT DROP AS
    SELECT ARRAY [
               'N' :: TEXT,
               REG.region_name :: TEXT,
               count(BB.id) :: TEXT,
               '175 x 60' :: TEXT,
               ' ' :: TEXT,
               ' ' :: TEXT,
               BP.date :: TEXT,
               REG.mrf_id :: TEXT,
               REG.region_id :: TEXT
               ] :: TEXT[] data_array
    FROM (
             SELECT AB.account_number, AB.bill_id
             FROM smfd_advert.t_targeting_number_list NL
                      JOIN smfd_advert.t_targeting_number_list_numbers NLN ON NLN.num_list_id = NL.id
                      JOIN smfd_data.t_bill_accounts_base AB ON AB.account_number = NLN.svc_nls_number
             WHERE NL.period_id = pi_period_id
               AND NL.mrf_id = pi_mrf_id
         ) result
             JOIN smfd_data.t_forming_publishing_details_base FPD ON FPD.bill_id = result.bill_id
             JOIN smfd_data.t_forming_publishing FP ON FP.id = FPD.publishing_id
             JOIN smfd_data.t_forming_history FH ON FH.id = FP.history_id

             JOIN smfd_data.t_bill_base BB ON BB.id = FPD.bill_id
             JOIN smfd_data.t_billing_period BP ON BP.id = BB.period_id
             JOIN td_region REG ON REG.region_id = BB.region_id
    WHERE NOT FH.is_test_forming
      AND FH.is_mass_forming
      AND BB.period_id = pi_period_id
      AND BB.forming_type > 100
    GROUP BY BP.date,
             REG.region_name,
             REG.region_id
    ORDER BY REG.region_name :: TEXT;

    OPEN po_data FOR
        SELECT arr.data_array data_array
        FROM temp_table_form_ten_mvno arr;

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

-- form_11
DROP FUNCTION IF EXISTS smfd_report.get_report_form_eleven_mvno(INT, INT);
CREATE OR REPLACE FUNCTION smfd_report.get_report_form_eleven_mvno(pi_mrf_id INT,
                                                                   pi_period_id INT,
                                                                   OUT po_data REFCURSOR,
                                                                   OUT po_result_code TEXT,
                                                                   OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql
AS
$$
BEGIN
    DROP TABLE IF EXISTS temp_table_form_eleven_mvno;
    CREATE TEMPORARY TABLE temp_table_form_eleven_mvno WITH (OIDS = FALSE)
                                                       ON COMMIT DROP AS
    SELECT ARRAY [
               'N' :: TEXT,
               ' ' :: TEXT,
               ' ' :: TEXT,
               ' ' :: TEXT,
               ' ' :: TEXT,
               ' ' :: TEXT,
               ' ' :: TEXT,
               ' ' :: TEXT,
               ' ' :: TEXT,
               ' ' :: TEXT
               ] :: TEXT[] data_array
    FROM smfd_data.t_bill_base BB
    WHERE BB.period_id = pi_period_id
      AND BB.id = -1
      AND BB.forming_type > 100;

    OPEN po_data FOR
        SELECT arr.data_array data_array
        FROM temp_table_form_eleven_mvno arr;

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
