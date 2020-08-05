/* Функция собирает тестовые счета по параметрам */
create or replace function smfd_data.get_test_forming_ids(in pi_period_id int, /* период */
                                                          in pi_region_id int, /* регион */
                                                          in pi_forming_type_id int, /* тип формирования */
                                                          in pi_delivery_type_id int, /* фильтр по типу доставки */
                                                          in pi_different_advert int, /* фильтр по рекалме */
                                                          in pi_need_email int, /* фильтр по обязательности email */
                                                          in pi_count int, /* максимальное кол-во тестовых счетов для подбора */
                                                          out po_ids refcursor, /* курсор результат */
                                                          OUT po_result_code TEXT,
                                                          OUT po_result_message TEXT) RETURNS RECORD
    LANGUAGE plpgsql AS
$$
declare
    l_count_limit int;
begin
    if pi_different_advert = 1 then
        open po_ids for
            with list_avd as (
                select distinct on (num_list.id) num_list.id as list_id, bb.id
                from smfd_advert.t_advert_target_by_numbers adv_by_num
                         join smfd_advert.t_targeting_number_list num_list
                              on num_list.id = adv_by_num.number_list_id and num_list.period_id = adv_by_num.period_id
                         join smfd_advert.t_targeting_number_list_numbers nums on num_list.id = nums.num_list_id
                         join smfd_data.t_bill_base bb on bb.period_id = num_list.period_id
                         join smfd_data.t_bill_accounts_base bab
                              on bab.bill_id = bb.id and bab.period_id = bb.period_id and
                                 bab.account_number = nums.svc_nls_number
                where bb.period_id = pi_period_id
                  and bb.forming_type = pi_forming_type_id
                  and bb.region_id = pi_region_id
                  and (pi_delivery_type_id is null or pi_delivery_type_id = 0 or pi_delivery_type_id = bb.delivery_type)
                  and (pi_need_email is null or pi_need_email = 0 or (pi_need_email > 0 and bb.email is not null))
            ),
                 cities_adv as (
                     select distinct on (cities.city_id) cities.city_id, bb.id
                     from smfd_advert.t_targeting_city_list_cities cities
                              join smfd_advert.t_advert_target_by_city advt_city
                                   ON advt_city.city_list_id = cities.city_list_id
                              join t_city c on c.id = cities.city_id
                              join smfd_data.t_bill_base bb
                                   on bb.region_id = c.region_id and bb.period_id = advt_city.period_id and
                                      bb.forming_type = advt_city.forming_type_id
                              join smfd_data.t_bill_accounts_base bab
                                   on bab.bill_id = bb.id and bab.period_id = bb.period_id
                              join smfd_data.t_bill_abonent ab on ab.id = bab.abonent_id
                              join smfd_data.t_address adr on adr.id = ab.address and adr.region_id = bb.region_id
                     where bb.period_id = pi_period_id
                       and bb.forming_type = pi_forming_type_id
                       and bb.region_id = pi_region_id
                       and bb.id not in (select list_avd.id from list_avd)
                       and (pi_delivery_type_id is null or pi_delivery_type_id = 0 or
                            pi_delivery_type_id = bb.delivery_type)
                       and (pi_need_email is null or pi_need_email = 0 or (pi_need_email > 0 and bb.email is not null))
                 )
            select list_avd.id, adv_by_num.advt_block as advt_block, adv_by_num.advt_module as advt_module
            from list_avd
                     join smfd_advert.t_advert_target_by_numbers adv_by_num
                          on list_avd.list_id = adv_by_num.number_list_id
            union all
            select cities_adv.id, advt_city.advt_block as advt_block, advt_city.advt_module as advt_module
            from cities_adv
                     join smfd_advert.t_targeting_city_list_cities cities on cities.city_id = cities_adv.city_id
                     join smfd_advert.t_advert_target_by_city advt_city ON advt_city.city_list_id = cities.city_list_id
            union all
            (select bb.id, adv_by_reg.advt_block as advt_block, adv_by_reg.advt_module as advt_module
             from smfd_data.t_bill_base bb
                      join smfd_advert.t_advert_target_by_region adv_by_reg
                           on adv_by_reg.period_id = bb.period_id and adv_by_reg.forming_type_id = bb.forming_type and
                              adv_by_reg.region_id = bb.region_id
             where bb.period_id = pi_period_id
               and bb.region_id = pi_region_id
               and bb.forming_type = pi_forming_type_id
               and bb.id not in (select list_avd.id from list_avd)
               and bb.id not in (select cities_adv.id from cities_adv)
               and (pi_delivery_type_id is null or pi_delivery_type_id = 0 or pi_delivery_type_id = bb.delivery_type)
               and (pi_need_email is null or pi_need_email = 0 or (pi_need_email > 0 and bb.email is not null))
             limit 1);
    else
        -- в ходе сдачи выяснили что конкретно для типа формирования  rtk_ural_lit (ид = 60) для случайной выборки нужно выбирать все
        l_count_limit := pi_count;
        if pi_forming_type_id in (60) then
            l_count_limit := 1000000; --поэтому указываем большое число, чтобы гарантированно получить все счета
        end if;
        open po_ids for
            select bb.id, 0 as advt_block, 0 as advt_module
            from smfd_data.t_bill_base bb
            where bb.period_id = pi_period_id
              and bb.region_id = pi_region_id
              and bb.forming_type = pi_forming_type_id
              and (pi_delivery_type_id is null or pi_delivery_type_id = 0 or pi_delivery_type_id = bb.delivery_type)
              and (pi_need_email is null or pi_need_email = 0 or (pi_need_email > 0 and bb.email is not null))
            order by random()
            limit l_count_limit;
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