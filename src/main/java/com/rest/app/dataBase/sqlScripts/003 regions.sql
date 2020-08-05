/* ------------------------------------------------------------------------------------------------------------------------ */
CREATE TABLE public.td_mrf
(
    mrf_id   INT PRIMARY KEY NOT NULL,
    mrf_code VARCHAR(8)      NOT NULL,
    mrf_name VARCHAR(128)    NOT NULL
);
CREATE UNIQUE INDEX td_mrf_mrf_code_uindex
    ON public.td_mrf (mrf_code);
CREATE UNIQUE INDEX td_mrf_mrf_name_uindex
    ON public.td_mrf (mrf_name);
COMMENT ON COLUMN public.td_mrf.mrf_id IS 'Идентификатор МРФ';
COMMENT ON COLUMN public.td_mrf.mrf_code IS 'Код МРФ';
COMMENT ON COLUMN public.td_mrf.mrf_name IS 'Наименование МРФ';
COMMENT ON TABLE public.td_mrf IS 'Справочник МРФ';

TRUNCATE TABLE public.td_mrf CASCADE;
INSERT INTO public.td_mrf (mrf_id, mrf_code, mrf_name)
VALUES (0, 'UNK', 'Не определено'),
       (1, 'CENTER', 'Центральный ФО'),
       (2, 'NW', 'Северо-Западный ФО'),
       (3, 'SOUTH', 'Южный ФО'),
       (5, 'VOLGA', 'Приволжский ФО'),
       (6, 'URAL', 'Уральский ФО'),
       (7, 'SIBIR', 'Сибирский ФО'),
       (8, 'DV', 'Дальневосточный ФО');

/* ------------------------------------------------------------------------------------------------------------------------ */
DROP TABLE IF EXISTS public.td_region;
CREATE TABLE public.td_region
(
    region_id              INT PRIMARY KEY NOT NULL,
    region_code            VARCHAR(32)     NOT NULL,
    region_name            VARCHAR(128)    NOT NULL,
    mrf_id                 INT             NOT NULL,
    invariant_region_names VARCHAR(128)[]  NOT NULL DEFAULT ARRAY [] :: VARCHAR(128)[],
    svc_type_id            VARCHAR(64)              DEFAULT NULL NULL,
    perm_id                VARCHAR(64),
    CONSTRAINT td_region_td_mrf_mrf_id_fk FOREIGN KEY (mrf_id) REFERENCES td_mrf (mrf_id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX td_region_region_code_uindex
    ON public.td_region (region_code);
CREATE UNIQUE INDEX td_region_region_name_uindex
    ON public.td_region (region_name);
COMMENT ON COLUMN public.td_region.region_id IS 'Идентификатор региона';
COMMENT ON COLUMN public.td_region.region_code IS 'Кодовое название региона';
COMMENT ON COLUMN public.td_region.region_name IS 'Наименование региона';
COMMENT ON COLUMN public.td_region.mrf_id IS 'Принадлежность к МРФ';
COMMENT ON COLUMN public.td_region.invariant_region_names IS 'Варианты именования региона со стороны МРФ';
COMMENT ON COLUMN public.td_region.svc_type_id IS 'svcTypeId региона';
COMMENT ON TABLE public.td_region IS 'Справочник регионов';

-- region inserts
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (0, 'unk', 'Не определено', 0, '{}', NULL);
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (36, 'voronezh', 'Воронежская область', 1, '{}', 'RT.CENTER.04.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (32, 'bryansk', 'Брянская область', 1, '{}', 'RT.CENTER.02.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (40, 'kaluga', 'Калужская область', 1, '{}', 'RT.CENTER.06.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (33, 'vladimir', 'Владимирская область', 1, '{}', 'RT.CENTER.03.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (46, 'kursk', 'Курская область', 1, '{}', 'RT.CENTER.08.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (37, 'ivanovo', 'Ивановская область', 1, '{}', 'RT.CENTER.17.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (57, 'orel', 'Орловская область', 1, '{}', 'RT.CENTER.11.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (8, 'elista', 'Республика Калмыкия', 3, '{калмыкия}', 'RT.SOUTH.08.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (67, 'smolensk', 'Смоленская область', 1, '{}', 'RT.CENTER.13.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (48, 'lipetsk', 'Липецкая область', 1, '{}', 'RT.CENTER.09.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (62, 'ryazan', 'Рязанская область', 1, '{}', 'RT.CENTER.12.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (68, 'tambov', 'Тамбовская область', 1, '{}', 'RT.CENTER.14.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (71, 'tula', 'Тульская область', 1, '{}', 'RT.CENTER.16.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (69, 'tver', 'Тверская область', 1, '{}', 'RT.CENTER.15.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (76, 'yaroslavl', 'Ярославская область', 1, '{}', 'RT.CENTER.17.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (6, 'ingushetia', 'Ингушетия', 3, '{}', 'RT.SOUTH.06.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (11, 'komi', 'Республика Коми', 2, '{}', 'RT.NW.11.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (77, 'moscow', 'Город Москва', 1, '{}', 'RT.CENTER.10.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (29, 'archangelsk', 'Архангельская область', 2, '{}', 'RT.NW.29.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (35, 'vologda', 'Вологодская область', 2, '{}', 'RT.NW.35.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (39, 'kaliningrad', 'Калининградская область', 2, '{}', 'RT.NW.39.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (47, 'lenoblast', 'Ленинградская область', 2, '{}', 'RT.NW.47.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (51, 'murmansk', 'Мурманская область', 2, '{}', 'RT.NW.51.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (53, 'novgorod', 'Новгородская область', 2, '{}', 'RT.NW.53.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (60, 'pskov', 'Псковская область', 2, '{}', 'RT.NW.60.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (78, 'spb', 'Санкт-Петербург', 2, '{}', 'RT.NW.78.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (9, 'cherkessk', 'Карачаево-Черкесская Республика', 3, '{}', 'RT.SOUTH.09.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (15, 'vladikavkaz', 'Республика Северная Осетия', 3, '{}', 'RT.SOUTH.15.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (23, 'krasnodar', 'Краснодарский край', 3, '{}', 'RT.SOUTH.23.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (26, 'stavropol', 'Ставропольский край', 3, '{}', 'RT.SOUTH.26.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (30, 'astrakhan', 'Астраханская область', 3, '{}', 'RT.SOUTH.30.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (34, 'volgograd', 'Волгоградская область', 3, '{}', 'RT.SOUTH.34.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (61, 'rostov', 'Ростовская область', 3, '{}', 'RT.SOUTH.61.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (12, 'maryel', 'Республика Марий Эл', 5, '{}', 'RT.VT.8.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (13, 'mordoviya', 'Республика Мордовия', 5, '{}', 'RT.VT.9.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (16, 'kazan', 'Республика Татарстан', 5, '{}', 'RT.VT.12.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (18, 'udmurtiya', 'Удмуртская Республика', 5, '{}', 'RT.VT.10.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (21, 'chuvashiya', 'Чувашская республика', 5, '{}', 'RT.VT.11.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (31, 'belgorod', 'Белгородская область', 1, '{}', 'RT.CENTER.01.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (43, 'kirov', 'Кировская область', 5, '{}', 'RT.VT.1.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (52, 'nnovgorod', 'Нижегородская область', 5, '{}', 'RT.VT.2.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (56, 'orenburg', 'Оренбургская область', 5, '{}', 'RT.VT.3.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (63, 'samara', 'Самарская область', 5, '{}', 'RT.VT.5.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (64, 'saratov', 'Саратовская область', 5, '{}', 'RT.VT.6.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (73, 'ulyanovsk', 'Ульяновская область', 5, '{}', 'RT.VT.7.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (19, 'khakassia', 'Республика Хакасия', 7, '{}', 'RT.SIBIR.F003.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (24, 'krasnoyarsk', 'Красноярский край', 7, '{}', 'RT.SIBIR.F005.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (38, 'irkutsk', 'Иркутская область', 7, '{}', 'RT.SIBIR.F006.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (42, 'kemerovo', 'Кемеровская область', 7, '{}', 'RT.SIBIR.F007.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (55, 'omsk', 'Омская область', 7, '{}', 'RT.SIBIR.F009.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (70, 'tomsk', 'Томская область', 7, '{}', 'RT.SIBIR.F010.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (75, 'chita', 'Забайкальский край', 7, '{}', 'RT.SIBIR.F011.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (45, 'kurgan', 'Курганская область', 6, '{}', NULL);
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (59, 'perm', 'Пермский край', 6, '{}', NULL);
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (66, 'ekt', 'Свердловская область', 6, '{}', NULL);
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (72, 'tumen', 'Тюменская область', 6, '{}', NULL);
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (74, 'chelyabinsk', 'Челябинская область', 6, '{}', NULL);
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (86, 'hanty', 'ХМАО', 6, '{}', NULL);
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (89, 'yamal', 'ЯНАО', 6, '{}', NULL);
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (4, 'raltay', 'Республика Алтай', 7, '{алтай,алтайский}', NULL);
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (80, 'buryatiya', 'Бурятский АО', 7, '{}', 'RT.SIBIR.F002.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (14, 'sakha', 'Якутия', 8, '{}', 'RT.DV.14.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (25, 'primorye', 'Приморский край', 8, '{}', 'RT.DV.25.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (27, 'khabarovsk', 'Хабаровский край', 8, '{}', 'RT.DV.27.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (28, 'amur', 'Амурская область', 8, '{}', 'RT.DV.28.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (41, 'kamchatka', 'Камчатская область', 8, '{}', 'RT.DV.41.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (49, 'magadan', 'Магаданская область', 8, '{}', 'RT.DV.49.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (65, 'sakhalin', 'Сахалинская область', 8, '{}', 'RT.DV.65.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (79, 'eao', 'Еврейская автономная область', 8, '{}', 'RT.DV.79.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (87, 'chukotka', 'Чукотский автономный округ', 8, '{}', 'RT.DV.87.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (50, 'mosoblast', 'Московская область', 1, '{}', 'RT.MSK.2.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (10, 'karelia', 'Республика Карелия', 2, '{}', 'RT.NW.10.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (5, 'mahachkala', 'Дагестан', 3, '{}', 'RT.SOUTH.05.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (7, 'nalchik', 'Кабардино-Балкарская Республика', 3, '{}', 'RT.SOUTH.07.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (90, 'maykop', 'Республика Адыгея', 3, '{}', 'RT.SOUTH.01.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (58, 'penza', 'Пензенская область', 5, '{}', 'RT.VT.4.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (54, 'novosibirsk', 'Новосибирская область', 7, '{}', 'RT.SIBIR.F008.ACCOUNT_NUM');
INSERT INTO public.td_region (region_id, region_code, region_name, mrf_id, invariant_region_names, svc_type_id)
VALUES (44, 'kostroma', 'Костромская область', 1, '{костромская}', 'RT.CENTER.17.ACCOUNT_NUM');
-- endregion

/* Возвращает все регионы с МРФами. Регионы могут возвращаться дублирующиеся с разными (альтернативными) именами. */
CREATE OR REPLACE FUNCTION public.get_region_dic(OUT po_mrfs REFCURSOR, /* Курсор со список мрф-ов */
                                                 OUT po_regions REFCURSOR, /* Курсор со список регионов */
                                                 OUT po_result_code TEXT, /* Код */
                                                 OUT po_result_message TEXT /* Сообщение */
)
    RETURNS RECORD
    LANGUAGE plpgsql AS
$$
BEGIN
    OPEN po_mrfs FOR
        SELECT m.mrf_id   AS mrf_id,
               m.mrf_code AS mrf_code,
               m.mrf_name AS mrf_name
        FROM public.td_mrf m
        WHERE m.mrf_id <> 0;

    OPEN po_regions FOR
        SELECT r.region_id                                                                   AS region_id,
               r.region_code                                                                 AS region_code,
               unnest((ARRAY [r.region_name] || r.invariant_region_names :: VARCHAR(128)[])) AS region_name,
               r.mrf_id                                                                      AS mrf_id,
               m.mrf_code                                                                    AS mrf_code
        FROM public.td_region r
                 LEFT JOIN public.td_mrf m ON m.mrf_id = r.mrf_id;

    po_result_code := 0;
    po_result_message := 'ok';
    RETURN;

EXCEPTION
    WHEN OTHERS
        THEN
            po_result_code := SQLSTATE;
            po_result_message := SQLERRM;
            RETURN;
END;
$$;

/* Добавление алиаса для региона */
CREATE OR REPLACE FUNCTION public.add_region_alt_name(IN pi_region_id INT, /* id региона */
                                                      IN pi_alt_name VARCHAR(128), /* алиас (псевдоним) для региона */
                                                      OUT po_result_code TEXT, /* Код */
                                                      OUT po_result_message TEXT /* Сообщение */
)
    RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
    cur_alt_names VARCHAR(128)[];
BEGIN
    SELECT r.invariant_region_names
    INTO cur_alt_names
    FROM public.td_region r
    WHERE r.region_id = pi_region_id;

    cur_alt_names = array_append(cur_alt_names, pi_alt_name);

    UPDATE public.td_region
    SET invariant_region_names = cur_alt_names
    WHERE region_id = pi_region_id;

    po_result_code := 0;
    po_result_message := 'ok';
    RETURN;

EXCEPTION
    WHEN OTHERS
        THEN
            po_result_code := SQLSTATE;
            po_result_message := SQLERRM;
            RETURN;
END;
$$;

/* ------------------------------------------------------------------------------------------------------------------------ */
-- region <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<CITY
CREATE TABLE public.t_city
(
    id        SERIAL PRIMARY KEY NOT NULL,
    city_type TEXT               NOT NULL,
    city_name TEXT               NOT NULL,
    region_id INT,
    CONSTRAINT t_city_td_region_region_id_fk FOREIGN KEY (region_id) REFERENCES public.td_region (region_id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON TABLE public.t_city IS 'Автозаполняемый справочник городов';
COMMENT ON COLUMN public.t_city.id IS 'Идентификатор';
COMMENT ON COLUMN public.t_city.city_type IS 'Тип населенного пункта (г., с., п.,...)';
COMMENT ON COLUMN public.t_city.city_name IS 'Название населенного пункта';
COMMENT ON COLUMN public.t_city.region_id IS 'Ссылка на регин';

/* Функция дл создания уникального составного индекса */
CREATE OR REPLACE FUNCTION public.city_tsvector(city_type TEXT, city_name TEXT)
    RETURNS TSVECTOR
    LANGUAGE plpgsql
    IMMUTABLE AS
$$
BEGIN
    RETURN (setweight(to_tsvector('english', city_type), 'B') || setweight(to_tsvector('english', city_name), 'A'));
END
$$;

CREATE UNIQUE INDEX t_city_city_name_city_type_uindex
    ON public.t_city (city_name, city_type, region_id);
CREATE INDEX t_city_fulltext_index
    ON public.t_city USING GIN (city_tsvector(city_type, city_name));

/* ------------------------------------------------------------------------------------------------------------------------ */
/* Получение id населенного пункта */
CREATE OR REPLACE FUNCTION public.get_city_id(IN pi_city_type TEXT, /* тип населенного пункта */
                                              IN pi_city_name TEXT, /* наименование населенного пункта */
                                              IN pi_region_id INT DEFAULT 0 /* id региона */
)
    RETURNS INT
    LANGUAGE plpgsql AS
$$
DECLARE
    city_row      public.T_CITY;
    error_message TEXT;
BEGIN
    SELECT city.*
    INTO city_row
    FROM t_city city
    WHERE (pi_city_type IS NULL OR pi_city_type = '' OR city.city_type = '' OR
           lower(city.city_type) = lower(pi_city_type))
      AND lower(city.city_name) = lower(pi_city_name)
      AND (pi_region_id = 0 OR city.region_id = pi_region_id);

    IF (city_row.id IS NULL)
    THEN
        INSERT INTO public.t_city (city_type, city_name, region_id)
        VALUES (pi_city_type, pi_city_name, pi_region_id)
        RETURNING * INTO city_row;
    ELSIF (city_row.city_type = '' AND pi_city_type IS NOT NULL AND pi_city_type <> '')
    THEN
        UPDATE public.t_city
        SET city_type = pi_city_type
        WHERE id = city_row.id;
    END IF;

    RETURN city_row.id;

EXCEPTION
    WHEN OTHERS
        THEN DECLARE
            exception_diag TEXT;
        BEGIN
            GET STACKED DIAGNOSTICS exception_diag = PG_EXCEPTION_CONTEXT;
            error_message := SQLERRM || ' REGION_ID=' || coalesce(pi_region_id, 'null') || ' CITY_TYPE=' ||
                             coalesce(pi_city_type, 'null') || ' CITY_NAME=' || coalesce(pi_city_name, 'null') ||
                             ' CTX:' || exception_diag;
            PERFORM public.exception_log(SQLSTATE, po_result_message, exception_diag);
            RETURN NULL;
        END;
END;
$$;

/* Поиск городов по запросу */
CREATE OR REPLACE FUNCTION public.search_city(IN pi_search_string TEXT, /* Текст поиска */
                                              OUT po_cities REFCURSOR, /* Курсор со списком городов */
                                              OUT po_result_code TEXT, /* Код */
                                              OUT po_result_message TEXT /* Сообщение */
)
    RETURNS RECORD
    LANGUAGE plpgsql AS
$$
DECLARE
BEGIN
    /* Чёт хз как отдать кошерный пустой курсор с нужными полями по-другому... */
    IF (pi_search_string IS NULL OR pi_search_string = '')
    THEN
        OPEN po_cities FOR
            SELECT NULL city_id,
                   NULL city_type,
                   NULL city_name,
                   NULL region_id,
                   NULL region_name,
                   NULL mrf_code,
                   NULL mrf_name
            FROM unnest(ARRAY [] :: INT[]);
        po_result_code := 0;
        po_result_message := 'ok';
        RETURN;
    END IF;

    OPEN po_cities FOR
        SELECT c.id          city_id,
               c.city_type   city_type,
               c.city_name   city_name,
               c.region_id   region_id,
               r.region_name region_name,
               m.mrf_code    mrf_code,
               m.mrf_name    mrf_name
        FROM public.t_city c
                 JOIN public.td_region r ON r.region_id = c.region_id
                 JOIN public.td_mrf m ON m.mrf_id = r.mrf_id
        WHERE city_tsvector(c.city_type, c.city_name) @@ (
            SELECT to_tsquery(string_agg(w.a, '|'))
            FROM (SELECT replace(trim(unnest(regexp_split_to_array(pi_search_string, '[|&]'))), ' ', '+') || ':*' a) w
        );
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

-- endregion <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<CITY