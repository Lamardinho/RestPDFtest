create table if not exists smfd_data.t_bill_statistic
(
    id               SERIAL PRIMARY KEY NOT NULL,
    task_id          INT,
    period_id        INT                NOT NULL,
    forming_type_id  INT                NOT NULL,
    delivery_type_id INT                NOT NULL,
    region_id        INT                NOT NULL,
    count            INT                NOT NULL,
    at_time          TIMESTAMP          NOT NULL DEFAULT current_timestamp,
    CONSTRAINT t_bill_stat_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE,
    CONSTRAINT t_bill_stat_t_forming_type_id_fk FOREIGN KEY (forming_type_id) REFERENCES smfd_data.t_forming_type (id) ON DELETE CASCADE,
    CONSTRAINT t_bill_stat_t_delivery_type_id_fk FOREIGN KEY (delivery_type_id) REFERENCES smfd_data.t_delivery_type (id) ON DELETE CASCADE,
    CONSTRAINT t_bill_stat_td_region_id_fk FOREIGN KEY (region_id) REFERENCES td_region (region_id) ON DELETE CASCADE
);
COMMENT ON COLUMN smfd_data.t_bill_statistic.id IS 'Первичный ключ';
COMMENT ON COLUMN smfd_data.t_bill_statistic.task_id IS 'Ссылка на родительскую задачу которая загружала счета, специально нету fk так как это вспомогательная информация';
COMMENT ON COLUMN smfd_data.t_bill_statistic.period_id IS 'Ссылка на период (smfd_data.t_billing_period)';
COMMENT ON COLUMN smfd_data.t_bill_statistic.forming_type_id IS 'Ссылка на тип формирования (smfd_data.t_forming_type)';
COMMENT ON COLUMN smfd_data.t_bill_statistic.delivery_type_id IS 'Ссылка на тип формирования (smfd_data.t_delivery_type)';
COMMENT ON COLUMN smfd_data.t_bill_statistic.region_id IS 'Ссылка на регион (td_region)';
COMMENT ON COLUMN smfd_data.t_bill_statistic.count IS 'количество счетов удовлетворяющих условиям';
COMMENT ON TABLE smfd_data.t_bill_statistic IS 'Вспомогательная таблица, используется для быстрого получения статистики по загруженным счетам, запослняется после завершения загрузки';

create table if not exists smfd_data.t_bill_statistic_accumulate
(
    id               SERIAL PRIMARY KEY NOT NULL,
    task_id          INT,
    period_id        INT                NOT NULL,
    forming_type_id  INT                NOT NULL,
    delivery_type_id INT                NOT NULL,
    region_id        INT                NOT NULL,
    count            INT                NOT NULL,
    CONSTRAINT t_bill_stat_t_billing_period_id_fk FOREIGN KEY (period_id) REFERENCES smfd_data.t_billing_period (id) ON DELETE CASCADE,
    CONSTRAINT t_bill_stat_t_forming_type_id_fk FOREIGN KEY (forming_type_id) REFERENCES smfd_data.t_forming_type (id) ON DELETE CASCADE,
    CONSTRAINT t_bill_stat_t_delivery_type_id_fk FOREIGN KEY (delivery_type_id) REFERENCES smfd_data.t_delivery_type (id) ON DELETE CASCADE,
    CONSTRAINT t_bill_stat_td_region_id_fk FOREIGN KEY (region_id) REFERENCES td_region (region_id) ON DELETE CASCADE
);
COMMENT ON COLUMN smfd_data.t_bill_statistic_accumulate.id IS 'Первичный ключ';
COMMENT ON COLUMN smfd_data.t_bill_statistic_accumulate.task_id IS 'Ссылка на родительскую задачу которая загружала счета, специально нету fk так как это вспомогательная информация';
COMMENT ON COLUMN smfd_data.t_bill_statistic_accumulate.period_id IS 'Ссылка на период (smfd_data.t_billing_period)';
COMMENT ON COLUMN smfd_data.t_bill_statistic_accumulate.forming_type_id IS 'Ссылка на тип формирования (smfd_data.t_forming_type)';
COMMENT ON COLUMN smfd_data.t_bill_statistic_accumulate.delivery_type_id IS 'Ссылка на тип формирования (smfd_data.t_delivery_type)';
COMMENT ON COLUMN smfd_data.t_bill_statistic_accumulate.region_id IS 'Ссылка на регион (td_region)';
COMMENT ON COLUMN smfd_data.t_bill_statistic_accumulate.count IS 'количество счетов по данному типу формирования';
COMMENT ON TABLE smfd_data.t_bill_statistic_accumulate IS 'Вспомогательная таблица, используется для хранения статистики по типам доставки в рамках различных порций прогрузки счетов. После завершения загрузки региона данные из этой таблицы суммируются и переносятся в smfd_data.t_bill_statistic';


/* Сохранение статистики (не используется) */
create or replace function smfd_data.save_batch_statistic(in pi_task_id INT, /* задача */
                                                          in pi_period_id INT, /* период */
                                                          in pi_forming_type_id INT, /* тип формирования */
                                                          in pi_region_id INT, /* регион */
                                                          in pi_types varchar[], /* перечисление тпов доставки */
                                                          OUT po_result_code TEXT,
                                                          OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    insert into smfd_data.t_bill_statistic_accumulate (task_id, period_id, forming_type_id, region_id, delivery_type_id,
                                                       count)
    select pi_task_id         as task_id,
           pi_period_id       as period_id,
           pi_forming_type_id as forming_type_id,
           pi_region_id       as region_id,
           dt.id,
           count(dtId)
    from smfd_data.t_delivery_type dt
             join unnest(pi_types) as dtId on dt.dt_code = dtId
    group by dt.id;
end;
$$;

/* Подсчет статистики по типам доставки */
CREATE OR REPLACE FUNCTION smfd_data.calc_statistic(in pi_task_id INT, /* номер задачи */
                                                    in pi_period_id INT, /* период */
                                                    in pi_forming_type_id INT, /* тип формирования */
                                                    in pi_region_id INT, /* регион */
                                                    in pi_types s_key_value_pair[], /* тип доставки на количество */
                                                    OUT po_result_code TEXT,
                                                    OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    insert into smfd_data.t_bill_statistic (task_id, period_id, forming_type_id, region_id, delivery_type_id, count)
    select pi_task_id         as task_id,
           pi_period_id       as period_id,
           pi_forming_type_id as forming_type_id,
           pi_region_id       as region_id,
           dt.id,
           dtStat.value::int
    from smfd_data.t_delivery_type dt
             join unnest(pi_types) as dtStat on dtStat.key = dt.dt_code
             join smfd_data.t_forming_type ft on ft.id = pi_forming_type_id
         -- типы "доставки" Account и Client сохраняем только для типов формирования mvno
    where (pi_forming_type_id > 100)
       -- для отсатльных типов формирования соответственно сохраняем все кроме типов "доставки" Account и Client
       or (pi_forming_type_id < 100 and dt.id not in (1, 2))
       -- кроме урала, для него грузим все
       or (ft.mrf_id = 6 and pi_forming_type_id < 100);

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

/* Удаление статистики по задаче */
CREATE OR REPLACE FUNCTION smfd_data.clear_stat(IN pi_task_id INT, /* номер заадчи */
                                                OUT po_result_code TEXT,
                                                OUT po_result_message TEXT)
    RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    DELETE FROM smfd_data.t_bill_statistic BS WHERE BS.task_id = pi_task_id;

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