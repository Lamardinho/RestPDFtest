CREATE TABLE if not exists smfd_data.t_forming_type (
	id           INT PRIMARY KEY           NOT NULL,
	code         VARCHAR(32)               NOT NULL,
	adapter_name TEXT DEFAULT 'AUTODETECT' NOT NULL,
	mrf_id       INT constraint t_forming_type_td_mrf_fk references td_mrf (mrf_id)
);
COMMENT ON COLUMN smfd_data.t_forming_type.id IS 'Идентификатор периода формирования';
COMMENT ON COLUMN smfd_data.t_forming_type.code IS 'Код периода формирования. По сути чисто для человеков';
COMMENT ON COLUMN smfd_data.t_forming_type.adapter_name IS 'Имя адаптера';
COMMENT ON COLUMN smfd_data.t_forming_type.mrf_id IS 'ссылка на мрф (td_mrf)';
COMMENT ON TABLE smfd_data.t_forming_type IS 'Типы формирования документов';
CREATE UNIQUE INDEX t_forming_type_id_uindex ON smfd_data.t_forming_type (id);
CREATE UNIQUE INDEX t_forming_type_code_uindex ON smfd_data.t_forming_type (code);

INSERT INTO smfd_data.t_forming_type (id, code, adapter_name) VALUES
	(0, 'AUTODETECT', 'AUTODETECT'),
	(10, 'RTK_CENTER_EMAIL', 'CENTER'),
	(11, 'RTK_CENTER', 'CENTER'),
	(12, 'RTK_CENTER_PDF', 'CENTER'),
	(20, 'RTK_DV', 'DV'),
	(21, 'RTK_DV_EMAIL', 'DV'),
	(22, 'RTK_KAMCHATKA', 'DV'),
	(30, 'RTK_SPB_EMAIL', 'NW'),
	(31, 'RTK_TEL_SPB', 'NW'),
	(40, 'RTK_SIB_EMAIL', 'SIB'),
	(41, 'RTK_SIB', 'SIB'),
	(50, 'RTK_SOUTH', 'SOUTH'),
	(51, 'RTK_SOUTH_EMAIL', 'SOUTH'),
	(60, 'RTK_URAL_LITE', 'URAL'),
	(61, 'RTK_URAL_TEL', 'URAL'),
	(62, 'RTK_URAL_INET', 'URAL'),
	(63, 'RTK_URAL_IPTV', 'URAL'),
	(70, 'RTK_VOLGA_EMAIL', 'VOLGA'),
	(71, 'RTK_VOLGA', 'VOLGA'),
	(110, 'RTK_CENTER_MVNO_EMAIL', 'MVNO'),
	(111, 'RTK_CENTER_MVNO', 'MVNO'),
	(120, 'RTK_DV_MVNO_EMAIL', 'MVNO'),
	(121, 'RTK_DV_MVNO', 'MVNO'),
	(130, 'RTK_SPB_MVNO', 'MVNO'),
	(131, 'RTK_SPB_MVNO_EMAIL', 'MVNO'),
	(140, 'RTK_SIB_MVNO_EMAIL', 'MVNO'),
	(141, 'RTK_SIB_MVNO', 'MVNO'),
	(150, 'RTK_SOUTH_MVNO', 'MVNO'),
	(151, 'RTK_SOUTH_MVNO_EMAIL', 'MVNO'),
	(160, 'RTK_URAL_MVNO', 'MVNO'),
	(161, 'RTK_URAL_MVNO_EMAIL', 'MVNO'),
	(170, 'RTK_VOLGA_MVNO', 'MVNO');