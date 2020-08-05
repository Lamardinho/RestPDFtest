
--- добавил

DROP TABLE IF EXISTS public.t_audit_log CASCADE;
CREATE TABLE public.t_audit_log (
	rec_id      SERIAL PRIMARY KEY                  NOT NULL,
	user_id     INT                                 NOT NULL,
	action      VARCHAR(128)                        NOT NULL,
	time_action TIMESTAMP DEFAULT current_timestamp NOT NULL,
	reason      TEXT DEFAULT NULL
);
COMMENT ON TABLE public.t_audit_log IS 'Логирование важных действий изменения настроек системы.';

/* Создание записи о действиях пользователей */
CREATE OR REPLACE FUNCTION public.audit(
	IN  pi_user   INT,                  /* id пользователя */
	IN  pi_action VARCHAR(128),         /* описание действия */
	IN  pi_reason TEXT DEFAULT NULL,    /* причина совершения */
	OUT po_rec_id INT                   /* id созданной записи */
) RETURNS INT LANGUAGE plpgsql AS $$
BEGIN
	INSERT INTO public.t_audit_log (user_id, action, reason)
	VALUES (pi_user, pi_action, pi_reason)
	RETURNING rec_id INTO po_rec_id;
END;
$$;

/*  */
CREATE TABLE public.t_exception_log (
	log_id             SERIAL PRIMARY KEY                                 NOT NULL,
	log_time           TIMESTAMP WITHOUT TIME ZONE DEFAULT localtimestamp NOT NULL,
	error_code         VARCHAR(6) DEFAULT '0'                             NOT NULL,
	error_message      TEXT,
	current_query      TEXT,
	diagnostic_context TEXT
) WITH (OIDS = FALSE);
COMMENT ON TABLE public.t_exception_log IS 'Логирование исключений';

/* Сбор сведений об ошибках */
CREATE OR REPLACE FUNCTION public.exception_log(
	IN pi_error_code         VARCHAR(6),            /* код ошибки */
	IN pi_error_message      TEXT,                  /* сообщение ошибки */
	IN pi_diagnostic_context TEXT DEFAULT NULL      /* контекст ошибки */
) RETURNS INT LANGUAGE plpgsql AS $$
DECLARE
	logid INT;
BEGIN
	INSERT INTO public.t_exception_log (error_code, error_message, current_query, diagnostic_context)
	VALUES (pi_error_code, pi_error_message, current_query(), pi_diagnostic_context)
	RETURNING log_id INTO logid;
	RETURN logid;
END;
$$;

/* ------------------ */
CREATE TABLE public.td_statistics_action (
	id          INT PRIMARY KEY NOT NULL,
	code        VARCHAR(64)     NOT NULL,
	description TEXT            NOT NULL
);
CREATE UNIQUE INDEX td_statistics_action_code_uindex ON public.td_statistics_action (code);
COMMENT ON COLUMN public.td_statistics_action.id IS 'Идентификатор';
COMMENT ON COLUMN public.td_statistics_action.code IS 'Код';
COMMENT ON COLUMN public.td_statistics_action.description IS 'Описание';
COMMENT ON TABLE public.td_statistics_action IS 'Типы статистических действий';

INSERT INTO public.td_statistics_action (id, code, description) VALUES
	(1, 'DOCUMENT_FORMING', ''),
	(2, 'MASS_MAIL_SENDING', '');

CREATE TABLE public.t_statistics (
	id         SERIAL PRIMARY KEY                  NOT NULL,
	action     INT                                 NOT NULL,
	user_id    INT,
	start_time TIMESTAMP DEFAULT current_timestamp NOT NULL,
	end_time   TIMESTAMP DEFAULT NULL,
	reason     TEXT      DEFAULT NULL,
	attach_id  INT       DEFAULT NULL,
	CONSTRAINT t_statistics_td_statistics_action_id_fk FOREIGN KEY (action) REFERENCES public.td_statistics_action (id) ON UPDATE CASCADE,
	CONSTRAINT t_statistics_t_user_id_fk FOREIGN KEY (user_id) REFERENCES smfd_user.t_user (id) ON UPDATE CASCADE
);
COMMENT ON COLUMN public.t_statistics.action IS 'Тип действия';
COMMENT ON COLUMN public.t_statistics.user_id IS 'Пользователь, инициировавший действие';
COMMENT ON COLUMN public.t_statistics.start_time IS 'Время начала';
COMMENT ON COLUMN public.t_statistics.end_time IS 'Время окончания';
COMMENT ON COLUMN public.t_statistics.reason IS 'Причина';
COMMENT ON COLUMN public.t_statistics.attach_id IS 'Идентификатор в целевой таблице';
COMMENT ON TABLE public.t_statistics IS 'Таблица статистики действий';

/* Запись статистики различных действий (загрузка, формирование и тд) */
CREATE OR REPLACE FUNCTION public.start_statistic_action(
	IN  pi_action_code TEXT,        /* тип действия */
	IN  pi_user_id     INT,         /* id пользователя */
	IN  pi_reason      TEXT,        /* причина */
	IN  pi_attach_id   INT,         /* Идентификатор в целевой таблице */
	OUT po_stat_id     INT          /* id записи */
) RETURNS INT LANGUAGE plpgsql AS $$
DECLARE
BEGIN
	PERFORM smfd_user.assert_user_permit(pi_user_id);
	
	INSERT INTO public."t_statistics" (action, user_id, reason, attach_id)
		SELECT
			act.id,
			pi_user_id,
			pi_reason,
			pi_attach_id
		FROM public.td_statistics_action act
		WHERE act.code = pi_action_code
		LIMIT 1
	RETURNING id INTO po_stat_id;
	
	EXCEPTION WHEN OTHERS
	THEN DECLARE exception_diag TEXT;
	BEGIN
		GET STACKED DIAGNOSTICS exception_diag = PG_EXCEPTION_CONTEXT;
		PERFORM public.exception_log(SQLSTATE, SQLERRM, exception_diag);
		RETURN;
	END;
END;
$$;

/* Остановка записи статистики (загрузка, формирование и тд) */
CREATE OR REPLACE FUNCTION public.stop_statistics_action(
	IN pi_stat_id   INT,        /* id записи */
	IN pi_reason    TEXT,       /* причина */
	IN pi_attach_id INT         /* Идентификатор в целевой таблице */
) RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE
BEGIN
	UPDATE public."t_statistics"
	SET end_time  = current_timestamp,
		reason    = coalesce(pi_reason, reason),
		attach_id = coalesce(pi_attach_id, attach_id)
	WHERE id = pi_stat_id AND end_time IS NULL;
	
	EXCEPTION WHEN OTHERS
	THEN DECLARE exception_diag TEXT;
	BEGIN
		GET STACKED DIAGNOSTICS exception_diag = PG_EXCEPTION_CONTEXT;
		PERFORM public.exception_log(SQLSTATE, SQLERRM, exception_diag);
		RETURN;
	END;
END;
$$;

