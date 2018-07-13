CREATE OR REPLACE package body sa.ubi_pkg
as
/*******************************************************************************************************
 --$RCSfile: ubi_package_body.sql,v $
 --$Revision: 1.1 $
 --$Author: Hcampano $
 --$Date: 2017/12/19 21:43:40 $
 --$ $Log: ubi_package_body.sql,v $
 --$ Revision 1.1  2017/12/19 21:43:40  Hcampano
 --$ Initial version
 --$
  * Description: New Package for procedures related to Universal Balance Inquiry
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/
  function get_thresh(ip_get_esn varchar2)
  return varchar2
  is
    v_cos sa.x_cos.cos%type;
    v_threshold sa.x_policy_mapping_config.threshold%type;
  begin
    v_cos := sa.get_cos(ip_get_esn);

    select threshold
    into v_threshold
    from x_policy_mapping_config
    where 1=1
    and cos = v_cos
    and usage_tier_id = 2
    and rownum < 2;

    return v_threshold;
  exception
    when others then
      return null;
  end get_thresh;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  function get_addon_thresh(ip_get_esn varchar2)
  return varchar2
  is
    cst customer_type := customer_type ();
    v_threshold_val   varchar2(300);
  begin
    v_threshold_val := cst.get_add_ons(i_esn=>ip_get_esn);
    return v_threshold_val;
  exception
    when others then
      return null;
  end get_addon_thresh;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  function get_pgm_info(ipgm_esn varchar2)
  return pgm_info_tbl pipelined
  is
    pgm_info_rslt pgm_info_rec;

    v_service_plan_objid          varchar2(100); -- x_service_plan.objid is the source however wrapper method outputs as varchar2
    v_service_type                varchar2(100); -- x_service_plan.webcsr_display_name varchar2(50) is the source however wrapper method outputs as varchar2
    v_program_type                varchar2(100); -- x_program_parameters.x_program_name varchar2(40) is the source however wrapper method outputs as varchar2
    v_next_charge_date            date;          --varchar2(100), -- original was varchar, changed to date - x_program_enrolled.x_next_charge_date date
    v_program_units               number;        --varchar2(100), -- original was varchar, changed to number - validate this value remove when complete
    v_program_days                number;        --varchar2(100), -- original was varchar, changed to number - validate this value remove when complete
    v_prg_script_id               varchar2(30);  -- x_program_parameters.x_prg_script_id
    v_prg_desc_script_id          varchar2(30);  -- x_program_parameters.x_prg_desc_script_id
    v_rate_plan                   varchar2(100);  -- table_x_carrier_features.x_rate_plan%type varchar2(60)
    v_error_num                   number;

  begin
    pgm_info_rslt.pgm_key := null;
    pgm_info_rslt.pgm_value := null;
    sa.phone_pkg.get_program_info(p_esn => ipgm_esn,
                                  p_service_plan_objid => v_service_plan_objid,
                                  p_service_type => v_service_type,
                                  p_program_type => v_program_type,
                                  p_next_charge_date => v_next_charge_date,
                                  p_program_units => v_program_units,
                                  p_program_days => v_program_days,
                                  p_rate_plan => v_rate_plan,
                                  p_x_prg_script_id => v_prg_script_id,
                                  p_x_prg_desc_script_id  => v_prg_desc_script_id,
                                  p_error_num => v_error_num);

    pgm_info_rslt.pgm_key := 'SERVICE_PLAN_OBJID';
    pgm_info_rslt.pgm_value := v_service_plan_objid;
    pipe row (pgm_info_rslt);

    pgm_info_rslt.pgm_key := 'SERVICE_TYPE';
    pgm_info_rslt.pgm_value := v_service_type;
    pipe row (pgm_info_rslt);

    pgm_info_rslt.pgm_key := 'PROGRAM_TYPE';
    pgm_info_rslt.pgm_value := v_program_type;
    pipe row (pgm_info_rslt);

    pgm_info_rslt.pgm_key := 'NEXT_CHARGE_DATE';
    pgm_info_rslt.pgm_value := to_char(v_next_charge_date,'DD-MON-YYYY');
    pipe row (pgm_info_rslt);

    pgm_info_rslt.pgm_key := 'PROGRAM_UNITS';
    pgm_info_rslt.pgm_value := v_program_units;
    pipe row (pgm_info_rslt);

    pgm_info_rslt.pgm_key := 'PROGRAM_DAYS';
    pgm_info_rslt.pgm_value := v_program_days;
    pipe row (pgm_info_rslt);

    pgm_info_rslt.pgm_key := 'RATE_PLAN';
    pgm_info_rslt.pgm_value := v_rate_plan;
    pipe row (pgm_info_rslt);

--    dbms_output.put_line('get_pgm_info => v_prg_script_id'||v_prg_script_id);

    for i in (
              select fea_value
              from adfcrm_serv_plan_feat_matview
              where sp_objid = v_service_plan_objid
              and fea_name = 'SERVICE_PLAN_GROUP'
              )
    loop
      pgm_info_rslt.pgm_key := 'SERVICE_PLAN_GROUP';
      pgm_info_rslt.pgm_value := i.fea_value;
      pipe row (pgm_info_rslt);
    end loop;

    for j in (
              select decode(nvl(count(*),0),'0','N','Y') has_roaming_plan --AKA EXTENDED PLAN
              from adfcrm_serv_plan_feat_matview
              where sp_objid = v_service_plan_objid
              and fea_name like 'INTL_ROAM%'
              )
    loop
      pgm_info_rslt.pgm_key := 'HAS_ROAMING_PLAN';
      pgm_info_rslt.pgm_value := j.has_roaming_plan;
      pipe row (pgm_info_rslt);
    end loop;

    for k in ( -- CARRY OVER BENEFITS
              select sp_objid,
              decode(fea_name,'BENEFIT_TYPE','CARRY_OVER',
                              fea_name) fea_name,
              decode(fea_name,
                      'BENEFIT_TYPE', decode(fea_value,'SWEEP_ADD','No',
                                                       'STACK','Yes',
                                                       'TRANSFER','N/A',
                                                        fea_display),
                        fea_display) fea_display,
                        fea_value
              from (
                    select sp_objid, fea_name,fea_value,fea_display
                    from adfcrm_serv_plan_feat_matview
                    where (
                           fea_name like 'BENEFIT_TYPE' or
                           fea_name like 'CUST_PROFILE_SCRIPT'
                           )
                    and sp_objid = v_service_plan_objid
                )
              )
    loop
      pgm_info_rslt.pgm_key := k.fea_name;
      pgm_info_rslt.pgm_value := k.fea_display;
      pipe row (pgm_info_rslt);
    end loop;

  end get_pgm_info;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- USED BY ret_cos_and_threshold
  procedure ret_min_and_obj(ip_rmao_esn varchar2, op_rmao_min out varchar2, op_rmao_objid out number)
  is
    rmao_n_esn_objid      sa.table_part_inst.objid%type;
    rmao_v_x_min          sa.table_site_part.x_min%type;
    rmao_v_reserved_min   sa.table_part_inst.part_serial_no%type;
  begin
    select objid,
          (select  x_min
           from    table_site_part
           where   objid = x_part_inst2site_part) x_min
    into rmao_n_esn_objid,
         rmao_v_x_min
    from table_part_inst
    where part_serial_no = ip_rmao_esn
    and x_domain = 'PHONES';

    rmao_v_reserved_min := 'NA';

    begin
      select lpi.part_serial_no
      into rmao_v_reserved_min
      from table_part_inst lpi
      where lpi.part_to_esn2part_inst = rmao_n_esn_objid
      and lpi.x_domain = 'LINES'
      and length(lpi.part_serial_no) = 10
      and rownum < 2;
    exception
      when others then
        null;
    end;

    if rmao_v_x_min is null then
      rmao_v_x_min := rmao_v_reserved_min;
    end if;

      op_rmao_objid := rmao_n_esn_objid;
      op_rmao_min := rmao_v_x_min;

  end ret_min_and_obj;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- USED BY get_balance_and_usage
  -- USED BY ret_cos_and_threshold
  function convert_value(unit_value varchar2,convert_from varchar2,convert_to varchar2)
  return number
  is
    rslt number;
    n_unit_value number;
    bytes number := 8;
    kb number := 1024;
    mb number := 1048576;
    gb number := 1073741824;
    tb number := 1099511627776;
  begin
    -- ESCAPE ANYTHING THAT'S NOT DATA
    if  convert_from in ('unit','money','dollars','credits','minutes','min','msg') or
        convert_to in ('unit','money','dollars','credits','minutes','min','msg')
    then
      return unit_value;
    end if;

    -- distinct  measure_unit from ig_buckets returns
    --  kb -- intended to convert this
    --  mb -- intended to convert this
    --  Dollars -- not intended to convert
    --  min -- not intended to convert
    --  msg -- not intended to convert

    if convert_from not in ('kb','mb','gb','tb','bytes') or
       convert_to not in ('kb','mb','gb','tb','bytes') or
       convert_from is null or
       convert_to is null
    then
      return unit_value;
    end if;

    if convert_from = convert_to then
      return unit_value;
    end if;
      select (unit_value*decode(convert_from,
                                             'kb',kb,
                                             'mb',mb,
                                             'gb',gb,
                                             'tb',tb,
                                             'bytes',1))/decode(convert_to,
                                                                           'bytes',1,
                                                                           'kb',kb,
                                                                           'mb',mb,
                                                                           'gb',gb,
                                                                           'tb',tb)
      into rslt from dual;

    if (convert_from = 'kb' and convert_to = 'bytes') or
       (convert_from = 'mb' and convert_to = 'bytes') or
       (convert_from = 'mb' and convert_to = 'kb') or
       (convert_from = 'gb' and convert_to = 'bytes') or
       (convert_from = 'gb' and convert_to = 'kb') or
       (convert_from = 'gb' and convert_to = 'mb') or
       (convert_from = 'tb' and convert_to = 'bytes') or -- new
       (convert_from = 'tb' and convert_to = 'kb') or -- new
       (convert_from = 'tb' and convert_to = 'mb') or -- new
       (convert_from = 'tb' and convert_to = 'gb') -- new
    then
      return round(rslt,-1);
    end if;

    return round(rslt,2);
  exception
    when others then
      return unit_value;
  end convert_value;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- USED BY balance_inq_rslt
  function convert_value(unit_value varchar2,convert_from varchar2,convert_to varchar2,another_param varchar2)
  return varchar2
  is
    retval varchar2(300);
    num_in_bytes number;
  begin
    -- THIS FUNCTION DOES NOT CONVERT VALUES THAT ARE NOT RELATED TO BYTES
    -- SINCE MOSTLY WE TRY TO CONVERT WHATEVER VALUE GETS PASSED IN, INTO GB
    -- THEN IF IT FALLS INTO MIN OR TEXT, RETURN WITH THE CONVERT FROM VALUE
    --dbms_output.put_line('convert_value2 convert_from'||convert_from||', convert_to'||convert_to);
    if  convert_from in ('money','dollars','credits') or
        convert_to in ('money','dollars','credits')
    then
      if convert_to = 'credits' then
        return unit_value||' '||convert_to;
      else
        return '$'||unit_value;
      end if;
    end if;

    if  convert_from in ('unit','minutes','min','msg') or
        convert_to in ('unit','minutes','min','msg')
    then
      return unit_value||' '||convert_to;
    end if;

    if convert_from not in ('kb','mb','gb','tb','bytes') or
       convert_to not in ('kb','mb','gb','tb','bytes') or
       convert_from is null or
       convert_to is null
    then
      return unit_value;
    end if;

    -- GET THE RAW VALUE
    num_in_bytes := convert_value(unit_value,convert_from,'bytes');

    -- SCALE BACK DOWN
--    if num_in_bytes  < 1044480 then -- LESS THAN 1MB SHOW AS KB (REMOVED BECAUSE IT DIDN'T MAKE SENSE)
--      return to_char(convert_value(unit_value,convert_from,'kb'))||' '||upper('kb');
--    end if;

    if num_in_bytes  < 1073741820 then -- LESS THAN 1GB SHOW AS MB
      return to_char(convert_value(unit_value,convert_from,'mb'))||' '||upper('mb');
    end if;

    if num_in_bytes  < 1099511627780 then -- LESS THAN 1TB SHOW AS GB
      return to_char(convert_value(unit_value,convert_from,'gb'))||' '||upper('gb');
    end if;

    if num_in_bytes  >= 1099511627780 then -- GREATER THAN 1TB TRULY UNLIMITED
      return to_char('Truly Unlimited');
    end if;

    return to_char(convert_value(unit_value,convert_from,convert_to))||' '||upper(convert_to);
   exception
    when others then
      return unit_value;
  end convert_value;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- USED BY get_metering_info
  -- USED BY get_balance_request_type
  function get_ubi_transaction_objid (ubi_to_esn varchar2) -- NEW
  return number
  is
    ret_num number := -1;
  begin
      select ubi_transaction_objid
      into ret_num
      from (SELECT nvl(max(OBJID),-1) ubi_transaction_objid
            from sa.x_bi_transaction_log
            where esn             = ubi_to_esn
            and insert_timestamp >= sysdate - (
                                                select to_number(ubi_interval)
                                                from (
                                                      SELECT 0 ob, X_PARAM_VALUE ubi_interval
                                                      from table_x_parameters
                                                      where x_param_name='BI_TRANSACTION_MINUTES_INTERVAL'
                                                      and rownum        =1
                                                      union
                                                      select 1, '15' default_interval_if_no_value from dual
                                                      )
                                                where rownum < 2
                                               )/(24*60)
            ) a
      ;
      return ret_num;
  exception
    when others then
      return ret_num;
  end get_ubi_transaction_objid;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- USED BY get_balance_request_type
  function get_metering_info (ip_esn varchar2,ip_source_system varchar2)
  return mtg_info_tab pipelined
  is
    -- WHAT MUST THIS RETURN
    -- 1. DEFAULT MTG_SRC (DATA AND ILD)
    -- 2. TIMEOUT_THRESHOLD
    -- 3. DAILY ATTEMPTS THRESHOLD
    -- 4. X_BI_TRANSACTION_LOG OBJID
    -- 5. CONFIGURATION ID
    -- 6. ACTION TO TAKE
    -- 7. SHOW ROAMING BUTTONS

    mtg_info_rslt mtg_info_rec;
    v_sp_objid                    number;
    v_sp_group                    varchar2(50);

    v_bus_org varchar2(50);
    v_device_type varchar2(50);
    --v_authorized_source_sys  varchar2(50) := 'X'; -- IF THE SELECT RETURNS 'Y', THEN USE THE SOURCESYSTEM PASSED
    n_esn_objid                   sa.table_part_inst.objid%type;
    v_x_min                       sa.table_site_part.x_min%type;
    v_reserved_min                sa.table_part_inst.part_serial_no%type;
    vm_part_inst2carrier_mkt      sa.table_part_inst.part_inst2carrier_mkt%type;
    v_parent_name                 sa.table_x_parent.x_parent_name%type;

    v_data_mtg_src_str            varchar2(100);
    v_ild_mtg_src_str             varchar2(100);
    v_selected_mtg_src_str        varchar2(100);
    v_timeout_thresh              varchar2(100);
    v_attempts_thresh             varchar2(100);
    v_ubi_attempts                number;
    n_ubi_trans_objid             number;
    n_last_ubi_trans_objid        number;
    b_max_req_param_found         boolean := false;
  begin
      -- THE PARAMETER JUST NEEDS TO EXIST
      for i in (
                select nvl(count(*),0) cnt
                from table_x_parameters
                where x_param_name = 'UBI_MAX_REQUESTS'
               )
      loop
        if i.cnt > 0 then
          b_max_req_param_found := true;
        end if;
      end loop;


    n_ubi_trans_objid := ubi_pkg.get_ubi_transaction_objid (ubi_to_esn =>ip_esn);
    --dbms_output.put_line('ip_source_system =>'||ip_source_system);

    for j in (
              select *
              from table(ubi_pkg.get_pgm_info(ipgm_esn=>ip_esn))
    )
    loop
      if j.pgm_key = 'SERVICE_PLAN_GROUP' then
        v_sp_group := j.pgm_value;
      end if;
      if j.pgm_key = 'SERVICE_PLAN_OBJID' then
        v_sp_objid := j.pgm_value;
      end if;
    end loop;

    --dbms_output.put_line('v_sp_group =>'||v_sp_group);

    select objid,
          (select  x_min
           from    table_site_part
           where   objid = x_part_inst2site_part) x_min
    into n_esn_objid,
         v_x_min
    from table_part_inst
    where part_serial_no = ip_esn
    and x_domain = 'PHONES';

    v_reserved_min := 'NA';

    begin
      select lpi.part_serial_no
      into v_reserved_min
      from table_part_inst lpi
      where lpi.part_to_esn2part_inst = n_esn_objid
      and lpi.x_domain = 'LINES'
      and length(lpi.part_serial_no) = 10
      and rownum < 2;
    exception
      when others then
        null;
    end;

    --dbms_output.put_line('v_reserved_min =>'||v_reserved_min);

    if v_x_min is null then
      v_x_min := v_reserved_min;
    end if;

    --dbms_output.put_line('n_esn_objid =>'||n_esn_objid);
    --dbms_output.put_line('v_x_min =>'||v_x_min);

    --NEW MIN OBJID AND MIN STATUS
    begin
      select  part_inst2carrier_mkt
      into    vm_part_inst2carrier_mkt
      from    table_part_inst
      where   part_serial_no = v_x_min;

    exception
      when others then
        null;
    end;

    begin
      select x_parent_name
      into v_parent_name
      from table_x_parent
      where objid = (select x_carrier_group2x_parent
                     from table_x_carrier_group
                     where objid in (
                                     select carrier2carrier_group
                                     from   table_x_carrier car
                                     where  car.objid = vm_part_inst2carrier_mkt
                                      ));
    exception
      when others then
        mtg_info_rslt.mtg_src := 'ERROR';
        mtg_info_rslt.mtg_action := 'CARRIER INFO NOT FOUND, NOT ALLOWED TO PROCEED';
        pipe row (mtg_info_rslt);
        return;
    end;

    --dbms_output.put_line('vm_part_inst2carrier_mkt =>'||vm_part_inst2carrier_mkt);
    --dbms_output.put_line('n_esn_objid =>'||n_esn_objid);
    --dbms_output.put_line('v_x_min =>'||v_x_min);
    --dbms_output.put_line('v_parent_name =>'||v_parent_name);

    -- THIS SQL STMT DEPRECATES FUNCTION TRANSFORM_DEVICE_TYPE --TESTED W/PART NUM SMZEZ291DGP5
    -- THIS SQL STMT ALSO ASSUMES THE BYOP IS TREATED AS SMARTPHONE AS FUNCTION DEPRECATES MEMBER FUNCTION get_meter_sources (
    -- CHANGED THE QUERY TO REFLECT CORRECTLY MOBILE BROADBRAND NON PPE
      select  nvl(sub_brand,bus_org) bus_org,
              decode(pcpv.device_type,
                     'BYOP','SMARTPHONE',
                     'MOBILE_BROADBAND',decode(pcpv.non_ppe,
                                               '1',pcpv.device_type||'_NONPPE',
                                               pcpv.device_type), -- defect 37922
                                               pcpv.device_type,
                      pcpv.device_type) device_type
      into   v_bus_org, v_device_type
      from   table_part_inst pi,
             table_mod_level ml,
             table_part_num pn,
             pcpv_mv pcpv
      where  1 = 1 and
             pi.part_serial_no = ip_esn and
             pi.x_domain = 'PHONES' and
             pi.n_part_inst2part_mod = ml.objid and
             ml.part_info2part_num = pn.objid and
             pn.domain = 'PHONES' and
             pn.part_num2part_class = pcpv.pc_objid --and
             --pcpv.non_ppe = '1';
             ;

    --dbms_output.put_line('v_bus_org =>'||v_bus_org);
    --dbms_output.put_line('v_device_type =>'||v_device_type);

    -- ATTEMPTS MADE
    select count(objid) cnt
    into   v_ubi_attempts
    from  sa.x_bi_transaction_log
    where esn             = ip_esn
    and insert_timestamp >= trunc(sysdate);

    --dbms_output.put_line('v_ubi_attempts =>'||v_ubi_attempts);

    -- THIS SQL STMT DEPRECATES CARRIER_SW_PKG.GET_METER_SOURCES
    for i in (
              select *
              from (
                    select *
                    from   x_product_config
                    where  1= 1
                    and    brand_name = v_bus_org
                    and    device_type = decode(v_device_type,'BYOP','SMARTPHONE',v_device_type)
                    and    parent_name = v_parent_name
                    and    ( service_plan_group = v_sp_group or
                            service_plan_group is null)
                    order by case when service_plan_group = v_sp_group then 1 else 2 end
              ) where rownum = 1
             )
    loop
      --dbms_output.put_line('v_mtg_source =>'||i.voice_mtg_source);
      --dbms_output.put_line('d_mtg_source =>'||i.data_mtg_source);
      v_selected_mtg_src_str := 'VOICE_MTG_SRC:'||i.voice_mtg_source||
                                ',DATA_MTG_SRC:'||i.data_mtg_source||
                                ',ILD_MTG_SRC:'||i.ild_mtg_source;

      --dbms_output.put_line('v_selected_mtg_src_str =>'||v_selected_mtg_src_str);
      -- POTENTIAL ISSUE HERE, IF THE ILD_MTG_SRC IS DIFFERENT TO THE DATA, THEN WHICH ONE DO WE USE?
      for j in (
                select substr(rl,0,instr(rl,':')-1) r1, substr(rl,instr(rl,':')+1) r2
                from
                      (select distinct *
                               from  (with t as (select to_char(v_selected_mtg_src_str) repl_list  from dual)
                               select replace(regexp_substr(repl_list,'[^,]+',1,lvl),'null','') rl
                               from  (select repl_list, level lvl
                                      from   t
                                      connect by level <= length(repl_list) - length(replace(repl_list,',')) + 1)
                       )) p
                )
      loop
        -- I NEED SPECIFICALLY OBJID,DATA_MTG_SOURCE,ILD_MTG_SOURCE,BAL_CFG_ID_WEB
        if j.r2 is not null then
          begin
            select short_name,
                   timeout_minutes_threshold,
                   daily_attempts_threshold
            into   mtg_info_rslt.mtg_src,
                   mtg_info_rslt.timeout_minutes_threshold,
                   mtg_info_rslt.daily_attempts_threshold
            from   x_usage_host
            where  short_name = j.r2;

            mtg_info_rslt.ubi_objid := n_ubi_trans_objid;
            mtg_info_rslt.mtg_src_val := j.r1;
            mtg_info_rslt.config_id := i.bal_cfg_id_tas;
            mtg_info_rslt.attempts_made_today := v_ubi_attempts;

            --dbms_output.put_line('n_ubi_trans_objid checking ... =>'||n_ubi_trans_objid);
            --dbms_output.put_line('v_ubi_attempts checking ... =>'||v_ubi_attempts);

            if v_ubi_attempts >= to_number(nvl(mtg_info_rslt.daily_attempts_threshold,0)) and
               b_max_req_param_found and
               n_ubi_trans_objid != '-1'
            then
              -- GET THE MOST RECENT UI, CURR IN PROD, SOA ALLOWS CONTINUOUS
              -- REQUESTS. IT IS ASSUMED THAT THE SOA SERVICE WILL NO LONGER DO
              -- THAT BASED OFF THIS RETURNED VALUE
              select max(objid) cnt
              into   n_last_ubi_trans_objid
              from  sa.x_bi_transaction_log
              where esn             = ip_esn
              and insert_timestamp >= trunc(sysdate);

              mtg_info_rslt.mtg_action := 'MAX_REQUESTS_MADE_FOR_TODAY';
              mtg_info_rslt.ubi_objid := n_last_ubi_trans_objid;

            else
              if n_ubi_trans_objid = -1 then
                mtg_info_rslt.mtg_action := 'CREATE_UBI_REQUEST';
              else
                mtg_info_rslt.mtg_action := 'CONTINUE_WITH_UBI_REQUEST';
              end if;
            end if;

            for p in (
                      -- DEFAULTS
                      -- MAX_REQUEST_1 - IF PAYGO,PAY_GO
                      -- MAX_REQUEST_1 - IF MP_LIMITED
                      -- MAX_REQUEST_1 - IF NO SP - "NO_SERVICE_PLAN"
                      -- MAX_REQUEST_2 - IF NO SPG - "HAS_SERVICE_PLAN_BUT_NO_GROUP"
                      -- MAX_REQUEST_2 - IF NOT CONFIGURED - "UNIDENTIFIED_SERVICE_PLAN_GROUP"
                      -- THESE ARE DEFAULTS REQUESTED BY SONIA.

                      select *
                      from (
                            select *
                            from max_rqst_config
                            where active_config = 'Y'
                            and service_plan_group = decode(v_sp_objid,null,
                                                                       'NO_SERVICE_PLAN'
                                                                       ,decode(v_sp_group,null,
                                                                                         'HAS_SERVICE_PLAN_BUT_NO_GROUP'
                                                                                         ,v_sp_group
                                                                              )
                                                            )
                            or service_plan_group = 'UNIDENTIFIED_SERVICE_PLAN_GROUP'
                            )
                      where rownum = 1
                      )
            loop
              mtg_info_rslt.max_call := p.max_rqst;
            end loop;

            pipe row (mtg_info_rslt);

          exception
            when others then
              null;
          end;
        end if;
      end loop;

    end loop;

    return;
  end get_metering_info;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- USED BY SOA
  function get_balance_request_type (ip_esn varchar2,
                                     ip_source_system varchar2,
                                     ip_config_id_override number default null,
                                     -- OVERRIDE AND ADDITIONAL NOT REQUIRED BECAUSE IT WILL BE HANDLED AT THE SOA LAYER
                                     --ip_mtg_src_override varchar2 default null,
                                     --ip_mtg_src_additional varchar2 default null,
                                     ip_external_request_override varchar2 default null)
  return brt_tab pipelined
  is
    brt_rslt brt_rec;

    op_last_trans_flag varchar2(200);
    op_bi_count varchar2(200);
    op_trans_tab     sa.bi_mtg_trans_tab;
    op_err_code varchar2(200);
    op_err_msg varchar2(200);
    v_org_id varchar2(30) := '';
    v_sub_brand varchar2(30) := '';

    i_source_system varchar2(200) := '';
    o_meter_sources  meter_source_tab := meter_source_tab();
    num_changed number;

    sp_get_current_mtg_out_cur sa.return_met_source_tbl;

    n_ubi_trans_obj number := null; -- NEW
    get_bi_trans_rec sa.typ_bi_trans_tbl; -- NEW
    get_bi_trans_tab sa.bi_mtg_trans_tab; -- NEW
    v_mtg_src_string varchar2(4000);
    v_voice_mtg_src varchar2(30); -- NEW
    v_sms_mtg_src varchar2(30); -- NEW
    v_data_mtg_src varchar2(30); -- NEW
    v_wallet_ica_mtg_src varchar2(30); -- NEW
    v_wallet_pb_mtg_src varchar2(30); -- NEW
    v_voice_trans_id varchar2(30); -- NEW
    v_data_trans_id varchar2(30); -- NEW
    v_inquirytype varchar2(30); -- NEW
    v_sourcesystem varchar2(30); -- NEW
    v_request_balance_type varchar2(30) := 'REQUIRES_BI_TRANSACTION_ID'; -- NEW
    is_safelink boolean := false;
    v_trans_date varchar2(50);
    n_configuration_id number:= ip_config_id_override;
    v_max_req_msg varchar2(300) := 'N';
    v_has_roaming_plan varchar2(30);
    v_pc varchar2(40);
    v_has_external_ild varchar2(1);
    v_mtg_action varchar2(1000);
    v_max_call varchar2(50);
  begin
    ----------------------------------------------------------------------------
    -- IF YOU ARE HERE, IT'S ASSUMED THAT
    -- * MTG SRC HAS BEEN VALIDATED
    -- * A UBI TRANSACTION ID EXISTS (ip_ubi_trans_obj)
    -- * THIS FUNCTION PICKS UP THE MOST RECENT INSERT IN X_BI_TRANSACTION_LOG
    --   ALL BALANCE REQUESTS GO TO TABLE X_BI_TRANSACTION_LOG
    --   TEXT,VOICE AND DATA TRANSACTION IDS SHOULD ALL BE STORED HERE
    ----------------------------------------------------------------------------
    -- OPTIONAL OVERRIDES
    -- * ip_config_id_override (FOR PAGE CONFIGURATIONS)S
    -- * ip_mtg_src_override (NO LONGER REQUIRED - 12.28.2017)
        -- UPDATE: THE MTG SRC OVERRIDE IS NO LONGER REQUIRED, BECAUSE SOA WILL
        -- WRITE THE X_BI_TRANSACTION_LOG BEFORE COMING TO THIS PROCEDURE, SO THIS WILL
        -- BEHAVE BAU
        -- WHEN THE MTG SRC OVERRIDE APPLIES (3RD PARTY CALLS, MAX, AURIS, NULEEF, ETC.)
        -- * IT'S EXPECTED SOA WILL CREATE A BI_TRANSACTION_LOG PRIOR TO CALLING THIS
        -- * IT'S EXPECTED, NO BALANCE CAME BACK, WHICH IS WHY YOU'RE OVERRIDING
        -- * IF YOU ARE CALLING A THIRD PARTY FOR ILD LIKE AURIS / NULEEF
        -- MTG SRC OVERRIDE DOES NOT APPLY TO WALLET,WALLETPB,WALLETICA (TMO - CASH AND ILDs)
    ----------------------------------------------------------------------------
    -- THIS RETURNS WHAT ACTION SOA SHOULD BE TAKING ALONG W/A STRING
    -- CONTAINING THE RELEVANT ID/S
    -- EXAMPLES:
    -- * PPE_BALANCE, PPE_BALANCE:12345
    -- * CARRIER_BALANCE, CARRIER_BALANCE:12345
    -- * PCRF_DATA_USAGE,	PCRF_DATA_USAGE:23456
    -- * PCRF_DATA_BALANCE,	PCRF_DATA_BALANCE: 23457
    -- * MAX_DATA_USAGE, null
    -- * MAX_SAFELINK_BALANCE, null
    ----------------------------------------------------------------------------
    if ip_external_request_override is not null then
      v_request_balance_type := ip_external_request_override||'_BALANCE';
      brt_rslt.balance_action := v_request_balance_type;
      if ip_external_request_override like 'MAX%' then -- THIS IS DUE TO THE NEW MAX CONFIGS
        brt_rslt.items_list := 'CONFIG_ID:'||ip_config_id_override||',DATA_MTG_SRC:MAX';
      else
        brt_rslt.items_list := 'CONFIG_ID:'||ip_config_id_override||',DATA_MTG_SRC:'||ip_external_request_override;
      end if;
      pipe row (brt_rslt);
      return;
    end if;

    brt_rslt.balance_action := null;
    brt_rslt.items_list := null;

    select   pcpv.part_class
    into     v_pc
      from   table_part_inst pi,
             table_mod_level ml,
             table_part_num pn,
             pcpv_mv pcpv
      where  1 = 1 and
             pi.part_serial_no = ip_esn and
             pi.x_domain = 'PHONES' and
             pi.n_part_inst2part_mod = ml.objid and
             ml.part_info2part_num = pn.objid and
             pn.domain = 'PHONES' and
             pn.part_num2part_class = pcpv.pc_objid
             ;
      for m in (
                select ubi_objid,
                       config_id,
                       mtg_action, -- CREATE_UBI_REQUEST
                       mtg_src_val,
                       mtg_src,
                       max_call
                from table(ubi_pkg.get_metering_info (ip_esn =>ip_esn,ip_source_system =>ip_source_system))
                )
      loop
        v_max_call := m.max_call;
        v_mtg_action := m.mtg_action; -- DEFECT 37906 IF A METERING ACTION IS NOT FOUND LET IT BE KNOWN
        -- TO ADDRESS A BUG WHERE THE MTG SOURCE IS NOT POPULATED INTO THE CORRESPONDING BI TABLE
        -- WE'RE GOING TO PULL IT FROM X_PRODUCT_CONFIG
        if m.mtg_src_val = 'DATA_MTG_SRC' then
          v_data_mtg_src := m.mtg_src;
        end if;
        -- VALIDATE METERING GETS THE METERING CONFIGURATION
        -- THEN SEARCHES AGAINST X_BI_TRANSACTION_LOG TO SEE REQUEST COUNT IN THE LAST 24HRS
        -- THE CONFIGURATION ID RETURNS THE SAME FOR ALL MTG SRCS
        if m.mtg_action = 'MAX_REQUESTS_MADE_FOR_TODAY' then
          v_max_req_msg := 'Y';
        end if;
        n_ubi_trans_obj := m.ubi_objid;
        n_configuration_id := m.config_id;

        if m.mtg_action is not null and m.ubi_objid is null then
          brt_rslt.balance_action := m.mtg_action;
          brt_rslt.items_list := '-1';
          pipe row (brt_rslt);
          return;
        end if;
      end loop;

      if v_mtg_action is null then
        brt_rslt.balance_action := 'UNABLE_TO_DETERMINE_METERING';
        brt_rslt.items_list := '-1';
        pipe row (brt_rslt);
        return;
      end if;
      if n_configuration_id is null then
        brt_rslt.balance_action := 'CONFIGURATION_MISSING';
        brt_rslt.items_list := '-1';
        pipe row (brt_rslt);
        return;
      end if;

      --dbms_output.put_line('get_balance_request_type => ubi_pkg.get_ubi_transaction_objid ('||n_ubi_trans_obj||')');

      -- COLLECT THE BRAND INFO TO DETERMINE WHICH PCR OR MAX CALL (WHEN APPLICABLE)
      if n_ubi_trans_obj != -1 then
        select b.org_id,pc.sub_brand
        into  v_org_id,v_sub_brand
        from table_mod_level m,
             table_part_inst pi,
             table_part_num pn,
             table_bus_org b,
             pcpv_mv pc
        where m.objid = pi.n_part_inst2part_mod
        and   m.part_info2part_num = pn.objid
        and   b.objid = pn.part_num2bus_org
        and   pn.part_num2part_class = pc.pc_objid
        and   pi.part_serial_no = ip_esn;

        --dbms_output.put_line('ORG ID <=========================================================> '||v_org_id||','||v_sub_brand);

        for bi_trans_rec in (select * from table(sa.ubi_pkg.get_bi_trans_id_rslt(ip_trans_id =>n_ubi_trans_obj)))
        loop
          v_trans_date := to_char(bi_trans_rec.trans_date,'MM/DD/YYYY HH:MIAM');
          -- FOR CARRIER AND PCRF
          if bi_trans_rec.mtg_type = 'DATA' then
            --dbms_output.put_line('GETTING DATA');
            -- WE ALREADY CAPTURED THE DATA_MTG_SRC FROM THE X_PRODUCT_CONFIG TABLE.
            -- HOWEVER, GETTING IT FROM THE UBI IS PREFERABLE.
            if bi_trans_rec.mtg_src is not null then
              v_data_mtg_src := bi_trans_rec.mtg_src;
              --dbms_output.put_line('USE THE METERING SOURCE FROM THE UBI ID RSLT ('||v_data_mtg_src||')');
            end if;
            v_data_trans_id := bi_trans_rec.trans_id;
          end if;
          --exit when bi_trans_rec.mtg_type = 'DATA';
          -- FOR PPE
          if bi_trans_rec.mtg_type = 'VOICE' then
            --dbms_output.put_line('GETTING VOICE');
            v_voice_mtg_src := bi_trans_rec.mtg_src;
            v_voice_trans_id := bi_trans_rec.trans_id;
          end if;
        end loop;
      end if;

      -- THIS CODE WAS FOR DETERMINING WHO NEEDED TO CALL MAX FOR ROAMING
      -- THIS IS NO LONGER THE CASE BECAUSE THE MAX SERVICE CALLS HAVE BEEN
      -- BROKEN SINCE 11/2017 - BY NARESH MIGLANI
--      for j in ( -- THIS IS LOGIC TO DISPLAY ROAMING BUTTON
--                select *
--                from table(ubi_pkg.get_pgm_info(ipgm_esn=>ip_esn))
--                where pgm_key = 'HAS_ROAMING_PLAN'
--                )
--      loop
--        v_has_roaming_plan := j.pgm_key||':'||j.pgm_value;
--      end loop;

      select decode(count(*),'0','N','Y')  has_external_ild
      into v_has_external_ild
      from sa.table_x_ild_transaction i,
           sa.x_program_enrolled x,
           sa.x_program_parameters p
      WHERE i.x_esn = x.x_esn
      and x.pgm_enroll2pgm_parameter = p.objid
      --and i.x_product_id in ('BPNT_ILD_10','BPSM_ILD_10','BPTF_ILD_10','BPST_ILD_10','BPTC_ILD_10')
      and i.x_ild_trans_type = 'A'
      and i.x_ild_status = 'COMPLETED'
      AND x.x_enrollment_status = 'ENROLLED'
      and p.x_prog_class = 'LOWBALANCE'
      and i.x_esn = ip_esn;

      if v_trans_date is not null then
        v_mtg_src_string := 'UBI_OBJID:'||n_ubi_trans_obj||',TRANSACTION_DATE:'||v_trans_date||',BUS_ORG:'||v_org_id||',SUB_BRAND:'||v_sub_brand||',PART_CLASS:'||v_pc||',EXTRL_ILD:'||v_has_external_ild||','; --||v_has_roaming_plan||',';
      end if;

      if ip_config_id_override is not null then
        n_configuration_id := ip_config_id_override;
        v_mtg_src_string := v_mtg_src_string||'CONFIG_ID:'||ip_config_id_override;
      elsif n_configuration_id is not null then
        v_mtg_src_string := v_mtg_src_string||'CONFIG_ID:'||n_configuration_id;
      end if;

      if n_ubi_trans_obj != -1 then
        if v_data_mtg_src is null then
          v_data_mtg_src := 'MAX';
        end if;
      end if;

--      if v_data_mtg_src != 'MAX' then
        v_mtg_src_string := v_mtg_src_string||',DATA_MTG_SRC:'||v_data_mtg_src||',MAX_RQST_REACHED:'||v_max_req_msg||',MAX_FALL_BACK:'||v_max_call||',';
--      else
--        v_mtg_src_string := v_mtg_src_string||',DATA_MTG_SRC:'||v_data_mtg_src||',MAX_RQST_REACHED:'||v_max_req_msg||',';
--      end if;

      -- PPE, CARRIER, PCR RETURN OBJIDS
      if n_ubi_trans_obj = '-1' and
         v_data_mtg_src not in ('MAX')
      then
        brt_rslt.balance_action := v_request_balance_type;
        brt_rslt.items_list := n_ubi_trans_obj;
        pipe row (brt_rslt);
        return;
      end if;

      --dbms_output.put_line('v_mtg_src_string ('||v_mtg_src_string||')');
      -- PPE ACTION
      if (v_voice_mtg_src = 'PPE' or v_sms_mtg_src = 'PPE' or v_data_mtg_src = 'PPE') then
        v_request_balance_type := 'PPE_BALANCE';
        brt_rslt.balance_action := v_request_balance_type;
        brt_rslt.items_list := v_mtg_src_string||'PPE_BALANCE:'||v_voice_trans_id;
        pipe row (brt_rslt);
        return;
      end if;

      -- CARRIER ACTION
      if v_data_mtg_src not in ('MAX','PCR') and v_data_trans_id is not null then
        v_request_balance_type := 'CARRIER_BALANCE';
        --dbms_output.put_line('v_data_mtg_src ('||v_data_mtg_src||')');
        --dbms_output.put_line('return id ('||v_data_trans_id||')');
        brt_rslt.balance_action := v_request_balance_type;
        brt_rslt.items_list := v_mtg_src_string||'CARRIER_BALANCE:'||v_data_trans_id;
        pipe row (brt_rslt);
      end if;

      -- WE ARE ONLY USING DATA CONFIGURATIONS (X_PRODUCT_CONFIG) AS OF THIS EFFORT, ALL OTHER SCENARIOS IS BEING INGORED.
      -- ONLY ONE METERING SOURCE PER SERVICE COMBINATIONS ARE NOT BEING CONSIDERED
      -- UP TO TWO MTG_SRC's ARE ACCEPTED - WE WILL BE USING DATA_MTG_SRC AS THE FIRST, THE SECOND WILL BE FOR THIRD PARTY ILD, LIKE AURIS AND NULEEF

      if (v_data_mtg_src = 'PCR') then -- PCRF USAGE DATA OR BALANCE
        if v_org_id in ('TOTAL_WIRELESS') then
          v_request_balance_type := 'PCRF_DATA_BALANCE';
          --dbms_output.put_line('return id ('||v_data_trans_id||') for pcrf data balance');
          brt_rslt.balance_action := v_request_balance_type;
          brt_rslt.items_list := v_mtg_src_string||'PCRF_DATA_BALANCE:'||v_data_trans_id;
          pipe row (brt_rslt);
        else
          v_request_balance_type := 'PCRF_DATA_USAGE';
          --dbms_output.put_line('return id ('||v_data_trans_id||') for pcrf data usage');
          brt_rslt.balance_action := v_request_balance_type;
          brt_rslt.items_list := v_mtg_src_string||'PCRF_DATA_USAGE:'||v_data_trans_id;
          pipe row (brt_rslt);
        end if;
      end if;

      if v_data_mtg_src = 'MAX' then
          v_request_balance_type := v_max_call;
          brt_rslt.balance_action := v_request_balance_type;
          brt_rslt.items_list := v_mtg_src_string||null;
          pipe row (brt_rslt);
--        if v_org_id in ('TRACFONE') and sa.ubi_pkg.is_still_safelink(ip_esn,v_org_id) = 'true'
--        then
--          -- CALL THE SOA SERVICE FOR MAX GETSAFELINKESNLASTBALANCE PROCESS
--          v_request_balance_type := 'MAX_SAFELINK_BALANCE';
--          brt_rslt.balance_action := v_request_balance_type;
--          brt_rslt.items_list := v_mtg_src_string||null;
--          pipe row (brt_rslt);
--       else
--          --dbms_output.put_line('=======================> GET MAX DATA USAGE <========================');
--          v_request_balance_type := 'MAX_DATA_USAGE';
--          brt_rslt.balance_action := v_request_balance_type;
--          brt_rslt.items_list := v_mtg_src_string||null;
--          pipe row (brt_rslt);
--        end if;
      end if;


    if v_request_balance_type = 'REQUIRES_BI_TRANSACTION_ID' then
      brt_rslt.balance_action := v_request_balance_type;
      brt_rslt.items_list := n_ubi_trans_obj;
      pipe row (brt_rslt);
    end if;

    return;
  end get_balance_request_type;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- USED BY SOA BECAUSE THEY ARE UNABLE TO USE PIPELINE FUNCTIONS
  procedure get_balance_request_type( i_esn                   in  varchar2,
                                      i_source_system         in  varchar2,
                                      i_config_id_override    in  number    default null,
                                      i_external_request_override in  varchar2  default null,
                                      o_balance_request_rc    out sys_refcursor,
                                      o_err_num               out number ,
                                      o_err_msg               out varchar2 )
  as
  begin
    open   o_balance_request_rc for
    select *
    from table (
                sa.ubi_pkg.get_balance_request_type (
                                                    ip_esn                  =>  i_esn,
                                                    ip_source_system        =>  i_source_system,
                                                    ip_config_id_override   =>  i_config_id_override,
                                                    ip_external_request_override =>  i_external_request_override
                                                    )
               );
    o_err_num := 0;
    o_err_msg := 'SUCCESS';
  exception
    when others then
      o_err_num := 99;
      o_err_msg := 'ERROR GETTING GET_BALANCE_REQUEST_TYPE : ' || sqlerrm;
  end get_balance_request_type;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- USED BY balance_inq_rslt
  -- USED BY get_configured_ubi
  function get_balance_and_usage(ip_esn varchar2, ip_balance_action_list varchar2)
  return balance_and_usage_info_tab pipelined
  is
    balance_and_usage_info_rslt balance_and_usage_info_rec;

    v_balance_type varchar2(100); -- NEW
    v_ubi_info_storage_location varchar2(30); -- NEW
    v_ubi_objid varchar2(30);

    n_threshold number;

    sp_get_balance_cur sa.return_bucket_bal_tbl;
    op_err_code varchar2(200);
    op_err_msg varchar2(200);

    o_data_usage number;
    o_total_addon_data_usage number;
    o_total_data_usage number;
    o_hi_speed_data_usage number;

    o_addon_balance number;
    o_hi_speed_total_balance number;
    o_hi_speed_balance number;

    -- OUTPUT ELEMENT NAMES
      op_data_mtg_source                    varchar2(30);
      op_rate_plan_name                     varchar2(30) := 'RATE_PLAN';
      op_cos_name                           varchar2(30) := 'COS';                           -- SUBSCRIBER TABLE
      op_data_threshold_name                varchar2(30) := 'DATA_THRESHOLD';                -- SUBSCRIBER TABLE
      op_addon_data_threshold_name          varchar2(30) := 'ADDON_DATA_THRESHOLD';          -- CALCULATED
      op_tether_data_balance_name           varchar2(30) := 'TETHERED_DATA_BALANCE';

      op_data_mtg_source_name               varchar2(30);
      op_voice_balance_name                 varchar2(30) := 'VOICE_BALANCE';                 -- CARRIER
      op_text_balance_name                  varchar2(30) := 'TEXT_BALANCE';                  -- CARRIER
      op_data_balance_name                  varchar2(30) := 'DATA_BALANCE';                  -- CARRIER / PCRF / MAX (BASE_BALANCE)
      op_extra_data_balance_name            varchar2(30) := 'EXTRA_DATA_BALANCE';            -- EXTRA BUCKET GROUP

      op_addon_data_balance_name            varchar2(30) := 'ADDON_DATA_BALANCE';            -- PCRF / MAX  -- ADDON_DATA COULD ALSO BE REFERRED TO AS PROMO DATA
      op_group_data_balance_name            varchar2(30) := 'GROUP_DATA_BALANCE';            -- PCRF

      op_roam_voice_balance_name            varchar2(30) := 'ROAMING_VOICE_BALANCE';         -- MAX (ROAMING_VOICE_USAGE) THESE VALUES I WILL NOT BE USING HERE
      op_roam_text_balance_name             varchar2(30) := 'ROAMING_TEXT_BALANCE';          -- MAX  THESE VALUES I WILL NOT BE USING HERE
      op_roam_data_balance_name             varchar2(30) := 'ROAMING_DATA_BALANCE';          -- MAX (ROAMING_DATA_USAGE) THESE VALUES I WILL NOT BE USING HERE

      -- CARRIER - WALLETICA, WALLET, WALLETPB -  FLEX WALLET - For ILD (WALLETICA),FLEX WALLET - For ILD and Roaming (WALLET), FLEX WALLET - Prepaid Bucket (WALLETPB) --Dollars IN IG_BUCKETS
      op_cash_bene_ild_balance_name         varchar2(30) := 'CASHBENEFITS_ILD_BALANCE';      -- WALLETICA
      op_cash_bene_cashcard_bal_name        varchar2(30) := 'CASHBENEFITS_CASHCARD_BALANCE'; -- WALLETPB
      op_spcl_promo_bucket_bal_name         varchar2(30) := 'SPECIAL_PROMO_BUCKET_BALANCE';  -- NO USED
      op_wallet_name                        varchar2(30) := 'ILD_CASH_WALLET';               -- WALLET

      op_base_usage_name                    varchar2(30) := 'BASE_USAGE';                    -- PCRF / MAX (DATA_USAGE)
      op_addon_usage_name                   varchar2(30) := 'ADDON_USAGE';                   -- PCRF

      op_balance_date_name                  varchar2(30) := 'BALANCE_DATE';                  -- MAX THESE VALUES I WILL NOT BE USING HERE
      op_customer_type_name                 varchar2(30) := 'CUSTOMER_TYPE';                 -- MAX THESE VALUES I WILL NOT BE USING HERE
      op_start_usage_date_name              varchar2(30) := 'START_USAGE_DATE';              -- MAX THESE VALUES I WILL NOT BE USING HERE
      op_last_usage_date_name               varchar2(30) := 'LAST_USAGE_DATE';               -- MAX THESE VALUES I WILL NOT BE USING HERE
      op_last_pull_date_name                varchar2(30) := 'LAST_PULL_DATE';                -- MAX THESE VALUES I WILL NOT BE USING HERE
      op_last_red_date_name                 varchar2(30) := 'LAST_REDEMPTION_DATE';          -- MAX THESE VALUES I WILL NOT BE USING HERE

      op_free_voice_bal_name                varchar2(30) := 'FREE_VOICE_BALANCE';            -- CARRIER LOOK AT THE DESCRIPTION
      op_free_text_bal_name                 varchar2(30) := 'FREE_TEXT_BALANCE';             -- CARRIER LOOK AT THE DESCRIPTION
      op_free_data_bal_name                 varchar2(30) := 'FREE_DATA_BALANCE';             -- CARRIER LOOK AT THE DESCRIPTION

      op_ttl_voice_bal_name                 varchar2(30) := 'TOTAL_VOICE_BALANCE';
      op_ttl_text_bal_name                  varchar2(30) := 'TOTAL_TEXT_BALANCE';
      op_ttl_data_bal_name                  varchar2(30) := 'TOTAL_DATA_BALANCE';            -- CARRIER / PCRF / MAX
      op_ttl_data_usage_name                varchar2(30) := 'TOTAL_DATA_USAGE';              -- PCRF / MAX

      op_max_rqst_name                      varchar2(30) := 'MAX_RQST_REACHED';              -- X_USAGE_HOST

      -- TEMP VALS
      temp_data                             varchar2(300);

      -- OUTPUT ELEMENT VALUES
      op_data_mtg_source_val                varchar2(30)  := '';
      op_rate_plan_val                      varchar2(300) := '';
      op_cos_val                            varchar2(300) := '';                              -- SUBSCRIBER TABLE
      op_data_threshold_val                 varchar2(300) := '0';                             -- SUBSCRIBER TABLE
      op_addon_data_threshold_val           varchar2(300) := '0';                             -- CALCULATED
      n_addon_data_threshold_val            number;
      op_tether_data_balance_val            varchar2(300) := '';

      op_voice_balance_val                  varchar2(300) := '0';                             -- CARRIER
      op_text_balance_val                   varchar2(300) := '0';                             -- CARRIER
      op_data_balance_val                   varchar2(300) := '0';                             -- CARRIER / PCRF / MAX (BASE_BALANCE)
      op_extra_data_balance_val             varchar2(300) := '0';                             -- EXTRA BUCKET GROUP

      op_addon_data_balance_val             varchar2(300) := '0';                             -- PCRF / MAX
      op_group_data_balance_val             varchar2(300) := '0';                             -- PCRF

      op_cash_bene_ild_balance_val          varchar2(300) := '0';                             -- WALLETICA
      op_cash_bene_cashcard_bal_val         varchar2(300) := '0';                             -- WALLETPB
      op_spcl_promo_bucket_bal_val          varchar2(300) := '0';                             --
      op_wallet_val                         varchar2(300) := '0';                             -- WALLET

      op_base_usage_val                     varchar2(300) := '0';                             -- PCRF / MAX (DATA_USAGE)
      op_addon_usage_val                    varchar2(300) := '0';                             -- PCRF

      op_balance_date_val                   varchar2(300) := null;
      op_free_voice_bal_val                 varchar2(300) := '0';                             -- CARRIER LOOK AT THE DESCRIPTION
      op_free_text_bal_val                  varchar2(300) := '0';                             -- CARRIER LOOK AT THE DESCRIPTION
      op_free_data_bal_val                  varchar2(300) := '0';                             -- CARRIER LOOK AT THE DESCRIPTION

      op_ttl_voice_bal_val                  varchar2(300) := '0';
      op_ttl_text_bal_val                   varchar2(300) := '0';
      op_ttl_data_bal_val                   varchar2(300) := '0';
      op_ttl_data_usage_val                 varchar2(300) := '0';

      op_max_rqst_val                       varchar2(300) := 'You have reached the maximum balance requests. This is your most recent balance.'; -- this is a result based off the X_USAGE_HOST max req value

      -- OUTPUT ELEMENT METERING VALUES
      op_addon_data_threshold_mtg          varchar2(30) := '';                  -- DEFECT 37927
      op_data_mtg_source_mtg               varchar2(30) := '';
      op_voice_balance_mtg                 varchar2(30) := '';                  -- CARRIER
      op_text_balance_mtg                  varchar2(30) := '';                  -- CARRIER
      op_data_balance_mtg                  varchar2(30) := '';                  -- CARRIER / PCRF / MAX (BASE_BALANCE)
      op_extra_data_balance_mtg            varchar2(30) := '';                  -- EXTRA BUCKET GROUP

      op_addon_data_balance_mtg            varchar2(30) := '';                  -- PCRF / MAX
      op_group_data_balance_mtg            varchar2(30) := '';                  -- PCRF
      op_tether_data_balance_mtg           varchar2(30) := '';

      op_roam_voice_balance_mtg            varchar2(30) := '';                  -- MAX (ROAMING_VOICE_USAGE) THESE VALUES I WILL NOT BE USING HERE
      op_roam_text_balance_mtg             varchar2(30) := '';                  -- MAX  THESE VALUES I WILL NOT BE USING HERE
      op_roam_data_balance_mtg             varchar2(30) := '';                  -- MAX (ROAMING_DATA_USAGE) THESE VALUES I WILL NOT BE USING HERE

      op_cash_bene_ild_balance_mtg         varchar2(30) := '';                  -- WALLETICA
      op_cash_bene_cashcard_bal_mtg        varchar2(30) := '';                  -- WALLETPB

      op_spcl_promo_bucket_bal_mtg         varchar2(30) := '';                  --
      op_wallet_mtg                        varchar2(30) := '';                  -- WALLET

      op_base_usage_mtg                    varchar2(30) := '';                  -- PCRF / MAX (DATA_USAGE)
      op_addon_usage_mtg                   varchar2(30) := '';                  -- PCRF

      op_free_voice_bal_mtg                varchar2(30) := '';                  -- CARRIER LOOK AT THE DESCRIPTION
      op_free_text_bal_mtg                 varchar2(30) := '';                  -- CARRIER LOOK AT THE DESCRIPTION
      op_free_data_bal_mtg                 varchar2(30) := '';                  -- CARRIER LOOK AT THE DESCRIPTION

      op_ttl_voice_bal_mtg                 varchar2(30) := '';
      op_ttl_text_bal_mtg                  varchar2(30) := '';
      op_ttl_data_bal_mtg                  varchar2(30) := '';                  -- CARRIER / PCRF / MAX
      op_ttl_data_usage_mtg                varchar2(30) := '';                  -- PCRF / MAX

      op_max_rqst_mtg                      varchar2(30) := '';

      -- STATUS MESSAGES
      v_ubi_status_message                 varchar2(30) := '';
      v_ubi_status_message_mtg             varchar2(30) := '';

      n_unidentified_buckets                 number := 0;                       -- FOR ERROR HANDLING IN CARRIER BUCKETS

      -- GET THE ADDON_DATA_THRESHOLD
      cst customer_type := customer_type ();
      v_err_str                              varchar2(30);
  begin

    -- GET COS AND THRESHOLD (AUTOCONVERTED AND RETURNED IN BYTES)
    sa.ubi_pkg.ret_cos_and_threshold(ip_cat_esn => ip_esn, op_rate_plan => op_rate_plan_val, op_cos => op_cos_val,op_threshold => n_threshold);
    op_data_threshold_val := n_threshold;

    -- GET THE ADDON_DATA_THRESHOLD (PROVIDED BY SURESH MEGANATHAN)
    -- IT'S INITIALIZED AS "0", BUT, IF WHAT COMES BACK IS NOT A NUMBER, CHANGE IT BACK TO "O"
    -- IF WHAT COMES BACK IS A NULL VAL ASSIGN IT A "0"
    op_addon_data_threshold_val := cst.get_add_ons(i_esn=>ip_esn);
    if op_addon_data_threshold_val is not null then -- DEFECT 37927 (IF NO ADDON THRESHOLD, THEN DON'T SHOW ADDON USAGE)
      op_addon_data_threshold_mtg := 'bytes';
    end if;
    op_addon_data_threshold_val := ubi_pkg.convert_value(unit_value => op_addon_data_threshold_val,convert_from => 'mb', convert_to => 'bytes');
    begin
      if op_addon_data_threshold_val is null then
        op_addon_data_threshold_val := '0';
      else
        n_addon_data_threshold_val := to_number(op_addon_data_threshold_val);
      end if;
    exception
      when others then
        op_addon_data_threshold_val := '0';
    end;

    -- COS VALUE
    if op_cos_val is not null then
      balance_and_usage_info_rslt.balance_ele              := op_cos_name;
      balance_and_usage_info_rslt.balance_ele_value        := op_cos_val;
      balance_and_usage_info_rslt.balance_ele_measure_unit := 'text';
      pipe row (balance_and_usage_info_rslt);
    end if;

    -- RATE PLAN
    if op_rate_plan_val is not null then
      balance_and_usage_info_rslt.balance_ele              := op_rate_plan_name;
      balance_and_usage_info_rslt.balance_ele_value        := op_rate_plan_val;
      balance_and_usage_info_rslt.balance_ele_measure_unit := 'text';
      pipe row (balance_and_usage_info_rslt);
    end if;

    -- EXIPRATION_DATE
    begin
      balance_and_usage_info_rslt.balance_ele              := 'EXPIRATION_DATE';
      select pe.x_next_delivery_date
      into balance_and_usage_info_rslt.balance_ele_value
      from x_program_enrolled pe, x_program_parameters pp
      where pe.x_esn = ip_esn
      and pp.objid = pe.pgm_enroll2pgm_parameter
      and pp.x_prog_class = 'LIFELINE'
      and pe.x_enrollment_status = 'ENROLLED';
      balance_and_usage_info_rslt.balance_ele_measure_unit := 'date';
      pipe row (balance_and_usage_info_rslt);
    exception
      when others then
        null;
    end;

    v_err_str := 'READ_ACTION_LIST';

    -- READ FROM THE ACTION LIST STRING
    for i in (
              select substr(rl,0,instr(rl,':')-1) r1, substr(rl,instr(rl,':')+1) r2
                from
                      (select distinct *
                               from  (with t as (select to_char(ip_balance_action_list) repl_list  from dual)
                               select replace(regexp_substr(repl_list,'[^,]+',1,lvl),'null','') rl
                               from  (select repl_list, level lvl
                                      from   t
                                      connect by level <= length(repl_list) - length(replace(repl_list,',')) + 1)
                       )) p
              )
    loop
        --dbms_output.put_line('BALANCE INQ RESULTS FOR =========================================> '||i.r1||','||i.r2);
        if i.r1 = 'TRANSACTION_DATE' then
          op_balance_date_val := i.r2;
        end if;

        if i.r1 = 'MAX_RQST_REACHED' then
          if i.r2 = 'Y' then
            op_max_rqst_mtg := 'text';
          end if;
        end if;

        if i.r1 = 'DATA_MTG_SRC' then
          op_data_mtg_source                                   := i.r1;
          op_data_mtg_source_val                               := i.r2;
          op_data_mtg_source_mtg                               := 'text';

          if i.r2 = 'AUR' then
            v_ubi_info_storage_location := 'EXTERNAL';
          else
            begin
              select ubi_info_storage_location
              into v_ubi_info_storage_location
              from x_usage_host
              where short_name = op_data_mtg_source_val;
            exception
              when others then
                v_ubi_info_storage_location := 'UBI_STORAGE_LOC_NOT_FOUND';
            end;
          end if;
        end if;

        if nvl(instr(i.r1,'CARRIER_BALANCE'),0)>0 or
           nvl(instr(i.r1,'PCRF_DATA_USAGE'),0)>0 or
           i.r1 in ('PCRF_DATA_BALANCE')
        then
          v_balance_type := i.r1;
          v_ubi_objid := i.r2;
        end if;

    end loop;

    v_err_str := 'READ_ACTION_LIST_CARR';
    --dbms_output.put_line('START ('||v_balance_type||') - INFO LOCATION ('||v_ubi_info_storage_location||')');

    -- START STORAGE LOCATION CHECK
    if v_ubi_info_storage_location = 'CLARIFY' then

      -- START CARRIER
      -- CAPTURE/RETURN CARRIER_BALANCE
      if nvl(instr(v_balance_type,'CARRIER_BALANCE'),0)>0 then

          begin
            select decode(count(*),'0','Pending','completed') status
            into v_ubi_status_message
            from x_swb_tx_balance_bucket
            where balance_bucket2x_swb_tx in (
                                              select objid
                                              from x_switchbased_transaction
                                              where x_sb_trans2x_call_trans = v_ubi_objid
                                             );
            v_ubi_status_message_mtg := 'text';
          exception
            when others then
              null;
          end;

          --dbms_output.put_line('carrier_sw_pkg.sp_get_balance using ('||v_ubi_objid||')');

          for j in (select lower(x_type) x_type,x_value,bucket_desc,bucket_group from table(sa.ubi_pkg.get_balance_buckets_rslt(ip_trans_id =>v_ubi_objid)))
          loop
            if j.x_type in ('kb','mb') then
                begin
                  -- ALWAYS CONVERT THE DATA TO BYTES
                  temp_data := ubi_pkg.convert_value(unit_value => j.x_value,convert_from => j.x_type, convert_to => 'bytes');
                exception
                  when others then
                    temp_data := null;
                end;
                if lower(j.bucket_desc) like '%government%' then
                  op_free_data_bal_val := temp_data;
                  op_free_data_bal_mtg := 'bytes';
                elsif j.bucket_group = 'BASE_DATA' then
                  op_data_balance_val := temp_data;
                  op_data_balance_mtg := 'bytes';
                elsif j.bucket_group = 'PROMO_DATA' then
                  op_addon_data_balance_val := to_number(temp_data)+to_number(op_addon_data_balance_val);
                  op_addon_data_balance_mtg := 'bytes';
                elsif j.bucket_group = 'DATA_TETHERING' then
                  op_tether_data_balance_val := temp_data;
                  op_tether_data_balance_mtg := 'bytes';
                elsif lower(j.bucket_desc) like '%roam%' then
                  op_extra_data_balance_val := temp_data;
                  op_extra_data_balance_mtg := 'bytes';
                else
                  -- IF UNABLE TO CLASSIFY THE TYPE OF DATA BUCKET, THEN JUST ADD THEM UP AS THE BASE_DATA
                  op_data_balance_val := to_number(temp_data)+to_number(op_data_balance_val);
                  op_data_balance_mtg := 'bytes';
                  null;
                end if;
                temp_data := null;
            elsif j.x_type in ('min') then
              --dbms_output.put_line('VOICE_BALANCE'||' is ('||j.x_value||') measure unit is ('||j.x_type||')'||') BUCKET_DESC ('||j.bucket_desc||')');
              if lower(j.bucket_desc) like '%government%' then
                op_free_voice_bal_val := j.x_value;
                op_free_voice_bal_mtg := j.x_type;
              else
              op_voice_balance_val := j.x_value;
              op_voice_balance_mtg := j.x_type;
              end if;
            elsif j.x_type in ('msg') then
              --dbms_output.put_line('TEXT_BALANCE'||' is ('||j.x_value||') measure unit is ('||j.x_type||')'||') BUCKET_DESC ('||j.bucket_desc||')');
              if lower(j.bucket_desc) like '%government%' then
                if lower(j.x_value) = 'unlimited' then -- defect where the word unlimited is written as the bucket value
                  op_free_text_bal_val := '59999940';
                else
                  op_free_text_bal_val := j.x_value;
                end if;
                op_free_text_bal_mtg := j.x_type;
              else
                op_text_balance_val := j.x_value;
                op_text_balance_mtg := j.x_type;
              end if;
            elsif j.x_type in ('dollars') then
              -- CASHBENEFITS_ILD_BALANCE -- WALLETICA IS KNOWN IN TAS AS ILD BALANCE
              -- CASHBENEFITS_CASHCARD_BALANCE -- WALLETPB IS KNOWN AS CASHCARD BALANCE
              if j.bucket_desc in ('FLEX WALLET - For ILD') then -- WALLETICA (SM)
                --dbms_output.put_line('ILD BALANCE - WALLETICA'||' is ('||j.x_value||') measure unit is ('||j.x_type||')');
                op_cash_bene_ild_balance_val := j.x_value;
                op_cash_bene_ild_balance_mtg := j.x_type;
              end if;
              if j.bucket_desc in ('FLEX WALLET - For ILD and Roaming') then -- WALLET (WFM)
                --dbms_output.put_line('ILD_CASH_WALLET - WALLET'||' is ('||j.x_value||') measure unit is ('||j.x_type||')');
                op_wallet_val := j.x_value;
                op_wallet_mtg := j.x_type;
              end if;
              if j.bucket_desc in ('FLEX WALLET - Prepaid Bucket') then -- WALLETPB (SM)
                --dbms_output.put_line('CASHCARD - WALLETPB'||' is ('||j.x_value||') measure unit is ('||j.x_type||')');
                op_cash_bene_cashcard_bal_val := j.x_value;
                op_cash_bene_cashcard_bal_mtg := j.x_type;
              end if;
              -- END CASHBENEFITS
            else
              -- UNIDENTIFIED BUCKETS --DEFECT 38279
              -- dbms_output.put_line('THIS ESN''S TRANS ID ('||v_ubi_objid||') MEASURE UNIT IS ==> ('||j.x_type||') value ('||j.x_value||') BUCKET_GROUP ('||j.bucket_group||') BUCKET_DESC ('||j.bucket_desc||')');
              balance_and_usage_info_rslt.balance_ele              := 'UNIDENTIFIED_'||n_unidentified_buckets;
              balance_and_usage_info_rslt.balance_ele_value        := j.x_value;
              balance_and_usage_info_rslt.balance_ele_measure_unit := j.x_type;
              pipe row (balance_and_usage_info_rslt);
              n_unidentified_buckets := n_unidentified_buckets+1;
            end if;
          end loop;
      end if;
      -- END CARRIER

      -- START PCR
      v_err_str := 'READ_ACTION_LIST_PCR';
      -- CAPTURE/RETURN PCRF_DATA_BALANCE OR PCRF_DATA_USAGE
      -- THIS WILL CAPTURE AND RETURN THE PCRF USAGE FOR (PCRF_DATA_USAGE,CARRIER_BALANCE_AND_PCRF_DATA_USAGE)
      -- IF YOU'RE IN PCRF, CHANCES ARE YOU HAVE AN UNLIMITED PLAN
      if nvl(instr(v_balance_type,'PCRF_DATA_USAGE'),0)>0
      or
         v_balance_type in ('PCRF_DATA_BALANCE')
      then

        begin
          select status -- IF, it's not S, then Pending
          into v_ubi_status_message
          from (
                select esn,insert_timestamp,update_timestamp,decode(pcrf_status_code,'S','completed','W','completed','Pending') status
                from x_pcrf_transaction
                where objid = v_ubi_objid
                union
                select esn,insert_timestamp,update_timestamp,decode(pcrf_status_code,'S','completed','W','completed','Pending')
                from x_pcrf_trans_low_prty
                where objid = v_ubi_objid
                order by insert_timestamp desc
                )
          where rownum = 1;
          v_ubi_status_message_mtg := 'text';
        exception
          when others then
            null;
        end;

        sa.service_profile_pkg.get_pcrf_data_usage (
                                                    i_pcrf_transaction_id => v_ubi_objid,
                                                    o_data_usage => o_data_usage,
                                                    o_total_addon_data_usage => o_total_addon_data_usage, -- THIS IS ACTUALLY A CALCULATED BALANCE, NOT USAGE
                                                    o_total_data_usage => o_total_data_usage,
                                                    o_hi_speed_data_usage => o_hi_speed_data_usage -- THIS IS CURRENTLY USED GROUP BALANCES, IT CALCULATES THRESHOLD-DATA_USAGE(AKA BASE_USAGE) = GROUP_BALANCE
                                                    );

        op_base_usage_val := o_data_usage;
        op_base_usage_mtg := 'bytes';
        if o_total_addon_data_usage is not null then -- THIS IS ACTUALLY A CALCULATED BALANCE, NOT USAGE
          op_addon_data_balance_val := o_total_addon_data_usage;-- THIS IS ACTUALLY A CALCULATED BALANCE, NOT USAGE
          op_addon_data_balance_mtg := 'bytes';
        end if;
        op_ttl_data_usage_val := o_total_data_usage;
        op_ttl_data_usage_mtg := 'bytes';
        op_group_data_balance_val := to_number(n_threshold-o_total_data_usage);
        op_group_data_balance_mtg := 'bytes';
      end if;
      -- END PCR
    end if;
    -- END STORAGE LOCATION CHECK

    -- DONE READING FROM THE ACTION LIST STRING
    v_err_str := 'ASSIGN_VALS';

    -- ASSIGN THE FINAL VALUES
    balance_and_usage_info_rslt.balance_ele              := op_data_mtg_source;
    balance_and_usage_info_rslt.balance_ele_value        := op_data_mtg_source_val;
    balance_and_usage_info_rslt.balance_ele_measure_unit := op_data_mtg_source_mtg;
    pipe row (balance_and_usage_info_rslt);

    if op_balance_date_val is not null then
      balance_and_usage_info_rslt.balance_ele              := op_balance_date_name;
      balance_and_usage_info_rslt.balance_ele_value        := op_balance_date_val;
      balance_and_usage_info_rslt.balance_ele_measure_unit := 'date';
      pipe row (balance_and_usage_info_rslt);
    end if;

    if v_ubi_status_message_mtg is not null then
      balance_and_usage_info_rslt.balance_ele              := 'BI_STATUS';
      balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
      balance_and_usage_info_rslt.balance_ele_measure_unit := null;
      pipe row (balance_and_usage_info_rslt);
    end if;

    if op_max_rqst_mtg is not null then
      --op_max_rqst_val varchar2(300) := 'You have reached the maximum balance requests. This is your most recent balance.'; -- this is a result based off the X_USAGE_HOST max req value
      balance_and_usage_info_rslt.balance_ele       := op_max_rqst_name;
      balance_and_usage_info_rslt.balance_ele_value := op_max_rqst_val;
      pipe row (balance_and_usage_info_rslt);
    end if;

    if op_tether_data_balance_mtg is not null then
      balance_and_usage_info_rslt.balance_ele              := op_tether_data_balance_name;
      balance_and_usage_info_rslt.balance_ele_value        := op_tether_data_balance_val;
      balance_and_usage_info_rslt.balance_ele_measure_unit := op_tether_data_balance_mtg;
      pipe row (balance_and_usage_info_rslt);
    end if;

    if op_extra_data_balance_mtg is not null then
      balance_and_usage_info_rslt.balance_ele              := op_extra_data_balance_name;
      balance_and_usage_info_rslt.balance_ele_value        := op_extra_data_balance_val;
      balance_and_usage_info_rslt.balance_ele_measure_unit := op_extra_data_balance_mtg;
      pipe row (balance_and_usage_info_rslt);
    end if;

    -- PREPARE THE RESULTS IF WE STORE THE RESULTS IN OUR SYSTEM
    if v_ubi_info_storage_location = 'CLARIFY' then

      -- CALCULATED BALANCES FOR CARRIER
      if v_balance_type = 'CARRIER_BALANCE' then
        if v_ubi_status_message != 'Pending' then
          -- TOTAL_DATA_BALANCE
          op_ttl_data_bal_mtg := 'bytes';
          op_ttl_data_bal_val := (
                                  to_number(nvl(op_data_balance_val,'0'))+
                                  to_number(nvl(op_free_data_bal_val,'0'))+
                                  to_number(nvl(op_addon_data_balance_val,'0'))
                                  );

          -- BASE_USAGE
          if op_data_threshold_val is not null then -- defect 37852
            op_base_usage_mtg := 'bytes';
            op_base_usage_val := (
                                  to_number(op_data_threshold_val)-
                                  (to_number(nvl(op_data_balance_val,'0')+
                                   to_number(nvl(op_free_data_bal_val,'0'))))
                                  );
          end if;
          -- ADDON_USAGE
          if op_addon_data_threshold_mtg is not null then -- DEFECT 37927
            if op_addon_data_balance_mtg is not null then -- DEFECT 37963
            -- THIS CALCULATED AMOUNT BRAKES IF THERE IS NO THRESHOLD TO SUBTRACT FROM
            op_addon_usage_mtg := 'bytes';
            op_addon_usage_val := (
                                  to_number(nvl(op_addon_data_threshold_val,'0'))-
                                  to_number(nvl(op_addon_data_balance_val,'0')) --defect 37691
                                  );
            end if;
          end if;

          -- TOTAL_DATA_USAGE
          op_ttl_data_usage_mtg := 'bytes';
          op_ttl_data_usage_val := (
                                    to_number(nvl(op_base_usage_val,'0'))+
                                    to_number(nvl(op_addon_usage_val,'0'))
                                   );

          -- TOTAL_VOICE_BALANCE
          op_ttl_voice_bal_mtg := 'minutes';
          op_ttl_voice_bal_val := (
                                   to_char(
                                           to_number(op_free_voice_bal_val)+
                                           to_number(op_voice_balance_val)
                                           )
                                   );
          -- TOTAL_TEXT_BALANCE
          op_ttl_text_bal_mtg := 'msg';
          op_ttl_text_bal_val := (
                                  to_char(
                                          to_number(op_free_text_bal_val)+
                                          to_number(op_text_balance_val)
                                          )
                                  );
        end if;
      end if;

      -- CALCULATED BALANCES FOR PCRF ------------------------------------------
      if v_balance_type in ('PCRF_DATA_BALANCE','PCRF_DATA_USAGE') then
--        dbms_output.put_line('v_balance_type ('||
--                                               v_balance_type||
--                                              ') o_total_data_usage ('||
--                                               o_total_data_usage||
--                                               ') o_data_usage ('||
--                                               o_data_usage||')'||
--                                               ' o_total_addon_data_usage ('||
--                                               o_total_addon_data_usage||') op_data_threshold_val ('||
--                                               op_data_threshold_val||') op_addon_data_threshold_val ('||
--                                               op_addon_data_threshold_val||') op_ttl_data_usage_val ('||
--                                              op_ttl_data_usage_val||')');

        -- ADDON_USAGE
        --if o_total_data_usage != o_total_data_usage then --THIS CHANGE WAS LOST, BUT, IT MUST BE COMPARED TO SOMETHING
        if op_addon_data_threshold_mtg is not null then -- DEFECT 37927
          op_addon_usage_mtg := 'bytes';
          op_addon_usage_val := (
                                 to_char(
                                         to_number(o_total_data_usage)-
                                         to_number(o_data_usage)
                                        )
                                );
        end if;
        --end if;

        -- DATA_BALANCE
        op_data_balance_mtg := 'bytes';
        op_data_balance_val := (
                                to_char(
                                        to_number(op_data_threshold_val)-
                                        to_number(o_data_usage) -- WAS o_total_data_usage FIXING DEFECT
                                        )
                                );

        -- ADDON_DATA_THRESHOLD
        -- o_total_addon_data_usage IS ACTUALLY A CALCULATED BALANCE, NOT USAGE
        if o_total_addon_data_usage is not null then

          op_addon_data_threshold_val := (
                                          to_char(
                                                  to_number(o_total_addon_data_usage)+
                                                  to_number(op_addon_usage_val)
                                                  )
                                          );
        end if;
        -- TOTAL_DATA_BALANCE
        if v_ubi_status_message != 'Pending' then
          op_ttl_data_bal_mtg := 'bytes';
          op_ttl_data_bal_val := (
                                  to_char(
                                          (to_number(op_data_threshold_val)+
                                           to_number(op_addon_data_threshold_val))-
                                           to_number(op_ttl_data_usage_val)
                                          )
                                  );



          -- PCR DOESN'T RETURN THESE VALUES AND THEY ARE UNLIMITED
          -- VOICE_BALANCE
          op_voice_balance_val := '99999';
          op_voice_balance_mtg := 'min';

          op_ttl_voice_bal_val := '99999';
          op_ttl_voice_bal_mtg := 'min';

          -- TEXT_BALANCE
          op_text_balance_val := '99999';
          op_text_balance_mtg := 'msg';

          -- TOTAL_TEXT_BALANCE
          op_ttl_text_bal_val := '99999';
          op_ttl_text_bal_mtg := 'msg';
        end if;

      end if;

      if v_ubi_status_message = 'Pending' then
        balance_and_usage_info_rslt.balance_ele              := 'PENDING_MSG';
        balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
        balance_and_usage_info_rslt.balance_ele_measure_unit := 'text';
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- VOICE BALANCE NATIVE (CARRIER) / HARD-CODED 99999 (PCR)
      if op_voice_balance_mtg is not null then
        balance_and_usage_info_rslt.balance_ele              := op_voice_balance_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value        := op_voice_balance_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit := op_voice_balance_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- TEXT BALANCE NATIVE (CARRIER) / HARD-CODED 99999 (PCR)
      -- THE MEASURE UNIT HAS TO HAVE A VALUE IN ORDER TO DISPLAY
      if op_text_balance_mtg is not null then
        balance_and_usage_info_rslt.balance_ele              := op_text_balance_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value        := op_text_balance_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit := op_text_balance_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- FREE/GOVERNMENT VOICE (CARRIER) / NA (PCR)
      -- THE MEASURE UNIT HAS TO HAVE A VALUE IN ORDER TO DISPLAY
      if op_free_voice_bal_mtg is not null then
        balance_and_usage_info_rslt.balance_ele              := op_free_voice_bal_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value        := op_free_voice_bal_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit := op_free_voice_bal_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- FREE/GOVERNMENT TEXT (CARRIER) / NA (PCR)
      -- THE MEASURE UNIT HAS TO HAVE A VALUE IN ORDER TO DISPLAY
      if op_free_text_bal_mtg is not null then
        balance_and_usage_info_rslt.balance_ele              := op_free_text_bal_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value        := op_free_text_bal_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit := op_free_text_bal_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- FREE/GOVERNMENT DATA (CARRIER) / NA (PCR)
      -- THE MEASURE UNIT HAS TO HAVE A VALUE IN ORDER TO DISPLAY
      if op_free_data_bal_mtg is not null then
        balance_and_usage_info_rslt.balance_ele              := op_free_data_bal_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value        := op_free_data_bal_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit := op_free_data_bal_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- DATA BALANCE NATIVE (CARRIER) / CALCULATED (PCR)
      if op_data_balance_mtg is not null then
        balance_and_usage_info_rslt.balance_ele                 := op_data_balance_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value         := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value         := op_data_balance_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit    := op_data_balance_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- BASE USAGE NATIVE (PCR) / CALCULATED (CARRIER)
      -- THE MEASURE UNIT HAS TO HAVE A VALUE IN ORDER TO DISPLAY
      if op_base_usage_mtg is not null then
        balance_and_usage_info_rslt.balance_ele              := op_base_usage_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value        := op_base_usage_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit := op_base_usage_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- ADDON USAGE CALCULATED (PCR) / CALCULATED (CARRIER)
      -- THE MEASURE UNIT HAS TO HAVE A VALUE IN ORDER TO DISPLAY
      if op_addon_usage_mtg is not null
      then
        balance_and_usage_info_rslt.balance_ele              := op_addon_usage_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value        := op_addon_usage_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit := op_addon_usage_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- ADDON_DATA_BALANCE NATIVE (CARRIER) / NATIVE (PCR)
      -- THE MEASURE UNIT HAS TO HAVE A VALUE IN ORDER TO DISPLAY
      if op_addon_data_balance_mtg is not null then
        balance_and_usage_info_rslt.balance_ele              := op_addon_data_balance_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value        := op_addon_data_balance_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit := op_addon_data_balance_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- TOTAL_DATA_USAGE NATIVE (PCR) / CALCULATED (CARRIER)
      if op_ttl_data_usage_mtg is not null then
        balance_and_usage_info_rslt.balance_ele              := op_ttl_data_usage_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value        := op_ttl_data_usage_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit := op_ttl_data_usage_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- DATA THRESHOLD CALCULATED (CARRIER) / CALCULATED (PCR) / (PPE) -- MOVING FROM LINE 1707 DEFECT #37936

      -- ADDON DATA THRESHOLD (CARRIER PROMO_DATA BUCKET OR PCR)
      -- USED SURESH'S CODE IN CUSTOMER_TYPE TO DETERMINE THIS, FROM HIS EMAIL SENT 12/27/2017
      -- IF THE CUSTOMER TYPE RETURNS NULL, IT'S SUBSTITUTED WITH "0" SO IT ALWAYS HAS A VALUE
      if op_addon_data_threshold_val != '0' then
        balance_and_usage_info_rslt.balance_ele              := op_addon_data_threshold_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value        := op_addon_data_threshold_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit := op_addon_data_balance_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- TOTAL VOICE BALANCE
      if op_ttl_voice_bal_mtg is not null then -- INTIAL VOICE MUST EXIST TO CALCULATE TOTAL
        balance_and_usage_info_rslt.balance_ele              := op_ttl_voice_bal_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value        := op_ttl_voice_bal_val;
        end if;
          balance_and_usage_info_rslt.balance_ele_measure_unit := op_ttl_voice_bal_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- TOTAL_TEXT_BALANCE
      if op_ttl_text_bal_mtg is not null then -- INTIAL TEXT MUST EXIST TO CALCULATE TOTAL
        balance_and_usage_info_rslt.balance_ele              := op_ttl_text_bal_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value        := op_ttl_text_bal_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit := op_ttl_text_bal_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- TOTAL DATA BALANCE
      if op_ttl_data_bal_mtg is not null then
        balance_and_usage_info_rslt.balance_ele              := op_ttl_data_bal_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
          op_ttl_data_bal_mtg                                  := null;
        elsif op_ttl_data_bal_val != '0' then
          balance_and_usage_info_rslt.balance_ele_value        := op_ttl_data_bal_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit := op_ttl_data_bal_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- CASH WALLET (CARRIER - WALLET)
      -- THE MEASURE UNIT HAS TO HAVE A VALUE IN ORDER TO DISPLAY
      if op_wallet_mtg is not null then
        balance_and_usage_info_rslt.balance_ele              := op_wallet_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value        := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value        := op_wallet_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit := op_wallet_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- CASH BENEFIT ILD BALANCE (CARRIER - WALLETICA)
      -- THE MEASURE UNIT HAS TO HAVE A VALUE IN ORDER TO DISPLAY
      if op_cash_bene_ild_balance_mtg is not null then
        balance_and_usage_info_rslt.balance_ele                 := op_cash_bene_ild_balance_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value         := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value         := op_cash_bene_ild_balance_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit    := op_cash_bene_ild_balance_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

      -- CASH BENEFIT CASH CARD BALANCE (CARRIER - WALLETPB)
      -- THE MEASURE UNIT HAS TO HAVE A VALUE IN ORDER TO DISPLAY
      if op_cash_bene_cashcard_bal_mtg is not null then
        balance_and_usage_info_rslt.balance_ele                 := op_cash_bene_cashcard_bal_name;
        if v_ubi_status_message = 'Pending' then
          balance_and_usage_info_rslt.balance_ele_value         := v_ubi_status_message;
        else
          balance_and_usage_info_rslt.balance_ele_value         := op_cash_bene_cashcard_bal_val;
        end if;
        balance_and_usage_info_rslt.balance_ele_measure_unit    := op_cash_bene_cashcard_bal_mtg;
        pipe row (balance_and_usage_info_rslt);
      end if;

    else
      -- FOR EXTERNAL METERING SOURCES ARE CALCULATED BY SOA
      for k in (
                select balance_element,reference_units
                from ubi_mtg_src_configurations
                where 1=1
                and mtg_short_name = op_data_mtg_source_val
                )
      loop
        balance_and_usage_info_rslt.balance_ele              := k.balance_element;
        balance_and_usage_info_rslt.balance_ele_value        := 'VALUES_OBTAINED_FROM_'||op_data_mtg_source_val;
        balance_and_usage_info_rslt.balance_ele_measure_unit := k.reference_units;
        pipe row (balance_and_usage_info_rslt);
      end loop;
    end if; -- v_ubi_info_storage_location

    -- DATA THRESHOLD CALCULATED (CARRIER) / CALCULATED (PCR) / (PPE) -- MOVING FROM LINE 1707 DEFECT #37936
    if op_data_threshold_val != '0' then
      balance_and_usage_info_rslt.balance_ele_measure_unit := 'bytes';
      balance_and_usage_info_rslt.balance_ele_value        := op_data_threshold_val;
      balance_and_usage_info_rslt.balance_ele              := op_data_threshold_name;
      pipe row (balance_and_usage_info_rslt);
    end if;

    return;
  exception
    when others then
      balance_and_usage_info_rslt.balance_ele              := 'ERROR';
      balance_and_usage_info_rslt.balance_ele_value        := v_err_str||sqlerrm;
      pipe row (balance_and_usage_info_rslt);
  end get_balance_and_usage;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- USED BY SOA - NOT BE CALLED BY MULESOFT
  function get_configured_ubi(ip_gcu_esn varchar2, ip_gcu_balance_action_list varchar2)
  return balance_and_usage_info_tab pipelined
  is
    get_configured_ubi_rslt balance_and_usage_info_rec;
    v_mtg_src varchar2(50);
    n_config_id number;
  begin

    for i in (
              select substr(rl,0,instr(rl,':')-1) r1, substr(rl,instr(rl,':')+1) r2
                from
                      (select distinct *
                               from  (with t as (select to_char(ip_gcu_balance_action_list) repl_list  from dual)
                               select replace(regexp_substr(repl_list,'[^,]+',1,lvl),'null','') rl
                               from  (select repl_list, level lvl
                                      from   t
                                      connect by level <= length(repl_list) - length(replace(repl_list,',')) + 1)
                       )) p
              )
    loop
      if i.r1 = 'DATA_MTG_SRC' then
        v_mtg_src := i.r2;
      end if;
      if i.r1 = 'CONFIG_ID' then
        n_config_id := i.r2;
      end if;
    end loop;

    -- IDENTIFY WHICH METERING SOURCE WILL RETRIEVE
    -- BALANCE/USAGE INFO FROM CLARFY VS WHICH ONE WILL REQUIRE TO MANUALLY CAPTURE AND
    -- CALCULATE THE INFORMATION FROM AN EXTERNAL CALL
    for j in (
              select *
              from table(ubi_pkg.get_balance_and_usage(ip_esn =>ip_gcu_esn,ip_balance_action_list =>ip_gcu_balance_action_list))
              where balance_ele in (select balance_element
                                    from ubi_mtg_src_configurations where mtg_short_name = v_mtg_src)
              and balance_ele_measure_unit is not null
              )
    loop
      get_configured_ubi_rslt.balance_ele              := j.balance_ele;
      get_configured_ubi_rslt.balance_ele_value        := j.balance_ele_value;
      get_configured_ubi_rslt.balance_ele_measure_unit := j.balance_ele_measure_unit;
      pipe row (get_configured_ubi_rslt);
    end loop;

  end get_configured_ubi;
  ------------------------------------------------------------------------------
  procedure get_configured_ubi  ( i_gcu_esn                   in  varchar2,
                                  i_gcu_balance_action_list   in  varchar2,
                                  o_configured_ubi_rc         out sys_refcursor,
                                  o_err_num                   out number ,
                                  o_err_msg                   out varchar2 )
  as
  begin
    open o_configured_ubi_rc
    for
    select *
    from table  (ubi_pkg.get_configured_ubi(ip_gcu_esn                  =>  i_gcu_esn,
                                            ip_gcu_balance_action_list  =>  i_gcu_balance_action_list));
    o_err_num := 0;
    o_err_msg := 'SUCCESS';
  exception
    when others then
      o_err_num := 99;
      o_err_msg := 'ERROR GETTING GET_CONFIGURED_UBI : ' || sqlerrm;
  end get_configured_ubi;
  ------------------------------------------------------------------------------
  -- USED BY get_balance_and_usage
  procedure ret_cos_and_threshold(ip_cat_esn varchar2, op_rate_plan out varchar2, op_cos out varchar2,op_threshold out varchar2)
  is
    v_service_plan_objid varchar2(200); -- MOVED TO PROC
    v_carry_over varchar2(200);
    n_esn_objid      sa.table_part_inst.objid%type;
  begin

    for i in (
              select *
              from table(ubi_pkg.get_pgm_info(ipgm_esn=>ip_cat_esn))
              WHERE pgm_key in ('SERVICE_PLAN_OBJID','RATE_PLAN','CARRY_OVER','CUST_PROFILE_SCRIPT')
              )
    loop
      if i.pgm_key = 'SERVICE_PLAN_OBJID' then
        v_service_plan_objid := i.pgm_value;
      end if;
      if i.pgm_key = 'CUST_PROFILE_SCRIPT' then --RATE_PLAN
        op_rate_plan := i.pgm_value;
      end if;
      if i.pgm_key = 'CARRY_OVER' then
        v_carry_over := i.pgm_value;
      end if;

    end loop;

    -- THIS WILL NOT APPLY TO PAYGO DEVICES
    -- GET THE COS VALUE AND THRESHOLD
    -- IF CARRY OVER = NO THEN GET THE COS VALUE
    if v_service_plan_objid is not null then
        if v_carry_over = 'No' then
          -- FROM 12.27.2017 EMAIL FROM JUDA USE GET_GOS FUNCTION
          -- DO NOT READ DIRECTLY FROM SUBSCRIBER TABLE
          op_cos := sa.get_cos(ip_cat_esn);
          begin

            select threshold
            into op_threshold
            from x_policy_mapping_config
            where 1=1
            and cos = op_cos
            and usage_tier_id = 2
            and rownum < 2;

          exception
            when others then
              null;
          end;
        end if;
      -- ALL THRESHOLD IS IN MB
      op_threshold := ubi_pkg.convert_value(unit_value => op_threshold,convert_from => 'mb',convert_to =>'bytes');
    end if;
    --dbms_output.put_line('op_cos <====================================================> '||op_cos);
    --dbms_output.put_line('op_threshold <==============================================> '||op_threshold);
  end ret_cos_and_threshold;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- USED BY balance_inq_rslt
  function balance_inq_page_elements(ip_esn varchar2, ip_language varchar2, ip_source_system varchar2, ip_balance_action_list varchar2)
  return balance_inq_page_elements_tab pipelined
  is
    balance_inq_page_elements_rslt balance_inq_page_elements_rec;
    n_config_id number;
    v_mtg_source varchar2(30);
    v_part_class varchar2(40);
    v_bus_org varchar2(40);
    v_script_bus_org varchar2(40);
    n_ild_count number;
  begin

    -- THIS SHOULD NEVER FAIL
    select count(*)
    into n_ild_count
    from sa.table_x_ild_transaction
    where x_esn = ip_esn
    and x_ild_status = 'COMPLETED'
    and x_ild_trans_type = 'A' -- A IS ILD_CREATE, D IS ILD_DEACT
    and x_transact_date between sysdate-182 and sysdate;

    for i in (
              select substr(rl,0,instr(rl,':')-1) r1, substr(rl,instr(rl,':')+1) r2
                from
                      (select distinct *
                               from  (with t as (select to_char(ip_balance_action_list) repl_list  from dual)
                               select replace(regexp_substr(repl_list,'[^,]+',1,lvl),'null','') rl
                               from  (select repl_list, level lvl
                                      from   t
                                      connect by level <= length(repl_list) - length(replace(repl_list,',')) + 1)
                       )) p
              )
    loop
      if i.r1 = 'DATA_MTG_SRC' and i.r2 is not null then
        begin
          v_mtg_source := i.r2;
        exception
          when others then
            v_mtg_source := null;
        end;
      end if;
      if i.r1 = 'CONFIG_ID' and i.r2 is not null then
        begin
          n_config_id := i.r2;
        exception
          when others then
            n_config_id := -1;
        end;
      end if;
      if i.r1 = 'PART_CLASS' and i.r2 is not null then
        begin
          v_part_class := i.r2;
        exception
          when others then
            null;
        end;
      end if;
      if i.r1 = 'BUS_ORG' and i.r2 is not null then
        begin
          v_bus_org := i.r2;
        exception
          when others then
            v_bus_org := 'GENERIC';
        end;
      end if;
      if i.r1 = 'SUB_BRAND' and i.r2 is not null then
        begin
          v_script_bus_org := i.r2;
        exception
          when others then
            null;
        end;
      end if;
    end loop;

    if v_script_bus_org is null then
      v_script_bus_org := v_bus_org;
    end if;

    for j in (
              select distinct
                      nvl((select display_order
                           from ubi_page_ele
                           where element_id = dd.parent_element),dd.display_order)||'.'||
                            to_number(nvl(dd.parent_element,dd.element_id))||
                            decode(nvl(dd.parent_element,-1),'-1','A','B') ele_order,
                            dd.mtg_short_name,
                            dd.config_objid,
                            dd.balance_element,
                            dd.html_type,
                            dd.html_label,
                            dd.source_system,
                            dd.reference_units,
                            dd.display_unit,
                            dd.display_row,
                            dd.display_col,
                            dd.overwrite_val_with
              from (
                    -- ALL PAGE ELEMENTS THAT ARE NOT DISPLAY FIELDS
                    select
                            pe.display_order,
                            pe.element_id,
                            pe.parent_element,
                            v_mtg_source/*null*/ mtg_short_name,
                            pe.config_objid,
                            pe.balance_element,
                            pe.html_type,
                            pe.html_label,
                            pe.source_system,
                            null reference_type,
                            null reference_element,
                            null reference_units,
                            pe.display_row,
                            pe.display_col,
                            pe.display_unit,
                            pe.overwrite_val_with
                    from ubi_page_ele pe
                    where 1=1
                    and   pe.source_system = ip_source_system
                    and   pe.lang = ip_language
                    and   pe.config_objid = n_config_id
                    and   pe.html_type != 'DISPLAY_FIELD'
                    union
                    -- DISPLAY FIELD PAGE ELEMENTS BASED OFF THE METERING SOURCE
                    select
                            pe2.display_order,
                            pe2.element_id,
                            pe2.parent_element,
                            mtg.mtg_short_name,
                            pe2.config_objid,
                            pe2.balance_element,
                            pe2.html_type,
                            pe2.html_label,
                            pe2.source_system,
                            mtg.reference_type,
                            mtg.reference_element,
                            mtg.reference_units,
                            pe2.display_row,
                            pe2.display_col,
                            pe2.display_unit,
                            pe2.overwrite_val_with
                    from ubi_page_ele pe2
                         ,ubi_mtg_src_configurations mtg
                    where 1=1
                    and pe2.config_objid = n_config_id
                    and pe2.source_system = ip_source_system
                    and pe2.lang = ip_language
                    and pe2.balance_element = mtg.balance_element
                    and pe2.html_type = 'DISPLAY_FIELD'
                    and (mtg.mtg_short_name = v_mtg_source or
                         mtg.mtg_short_name = 'DB')
                    ) dd
              order by ele_order,display_row,display_col
            )
      loop
        if j.html_type like 'SCRIPT_CONTENT%' then
          --dbms_output.put_line('SCRIPT CONTENT');
          if (j.html_type like 'SCRIPT_CONTENT_ILD' and n_ild_count > 0) or
              j.html_type = 'SCRIPT_CONTENT'
          then
            if j.html_label is not null then
              -- SHOW SCRIPT
              --dbms_output.put_line('GET SCRIPT CONTENT ('||j.html_type||') n_ild_count ('||n_ild_count||') script_id ('||j.html_label||')');
              balance_inq_page_elements_rslt.html_label := null;
              balance_inq_page_elements_rslt.balance_ele_value := sa.ubi_pkg.get_generic_script (ip_script_type =>substr(j.html_label,0,instr(j.html_label,'_')-1),
                                                                                                      ip_script_id =>substr(j.html_label,instr(j.html_label,'_')+1),
                                                                                                      ip_language => ip_language,
                                                                                                      ip_sourcesystem => ip_source_system,
                                                                                                      ip_brand => v_script_bus_org,
                                                                                                      ip_pc => v_part_class);
              balance_inq_page_elements_rslt.display_value := balance_inq_page_elements_rslt.balance_ele_value;
              balance_inq_page_elements_rslt.display_unit := 'text';
            else
              --dbms_output.put_line('DO NOT GET SCRIPT CONTENT');
              balance_inq_page_elements_rslt.html_label := j.html_label;
            end if;
            balance_inq_page_elements_rslt.ele_order := j.ele_order;
            balance_inq_page_elements_rslt.mtg_short_name := j.mtg_short_name;
            balance_inq_page_elements_rslt.config_objid := j.config_objid;
            balance_inq_page_elements_rslt.balance_element := j.balance_element;
            balance_inq_page_elements_rslt.html_type := j.html_type;

            balance_inq_page_elements_rslt.source_system := j.source_system;
            balance_inq_page_elements_rslt.display_row := j.display_row;
            balance_inq_page_elements_rslt.display_col := j.display_col;
            balance_inq_page_elements_rslt.display_unit := j.display_unit;
            balance_inq_page_elements_rslt.overwrite_val_with := j.overwrite_val_with;
            pipe row (balance_inq_page_elements_rslt);
          end if;
        else
          --dbms_output.put_line('NOT SCRIPT CONTENT');
          balance_inq_page_elements_rslt.ele_order := j.ele_order;
          balance_inq_page_elements_rslt.mtg_short_name := j.mtg_short_name;
          balance_inq_page_elements_rslt.config_objid := j.config_objid;
          balance_inq_page_elements_rslt.balance_element := j.balance_element;
          balance_inq_page_elements_rslt.html_type := j.html_type;
          balance_inq_page_elements_rslt.html_label := j.html_label;
          balance_inq_page_elements_rslt.source_system := j.source_system;
          balance_inq_page_elements_rslt.display_row := j.display_row;
          balance_inq_page_elements_rslt.display_col := j.display_col;
          balance_inq_page_elements_rslt.display_unit := j.display_unit;
          balance_inq_page_elements_rslt.overwrite_val_with := j.overwrite_val_with;
          balance_inq_page_elements_rslt.balance_ele_value := null;
          balance_inq_page_elements_rslt.display_value := null;
          pipe row (balance_inq_page_elements_rslt);
        end if;
      end loop;

  end balance_inq_page_elements;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- USED BY TAS
  function balance_inq_rslt(ip_esn varchar2, ip_language varchar2, ip_source_system varchar2, ip_balance_action_list varchar2)
  return balance_inq_page_elements_tab pipelined
  is
    balance_inq_page_elements_rslt balance_inq_page_elements_rec;
    v_config_id varchar2(30);
    v_bus_org varchar2(30);
    v_script_bus_org varchar2(30);
    v_part_class varchar2(30);
  begin
    for j in (
               select substr(rl,0,instr(rl,':')-1) r1, substr(rl,instr(rl,':')+1) r2
                            from
                                  (select distinct *
                                           from  (with t as (select to_char(ip_balance_action_list) repl_list  from dual)
                                           select replace(regexp_substr(repl_list,'[^,]+',1,lvl),'null','') rl
                                           from  (select repl_list, level lvl
                                                  from   t
                                                  connect by level <= length(repl_list) - length(replace(repl_list,',')) + 1)
                                   )) p
            )
    loop
      if j.r1 = 'CONFIG_ID' then
        v_config_id := j.r2;
      end if;
      if j.r1 = 'BUS_ORG' then
        v_bus_org := j.r2;
      end if;
      if j.r1 = 'PART_CLASS' then
        v_part_class := j.r2;
      end if;
      if j.r1 = 'SUB_BRAND' and j.r2 is not null then
        begin
          v_script_bus_org := j.r2;
        exception
          when others then
            null;
        end;
      end if;
    end loop;

    if v_script_bus_org is null then
      v_script_bus_org := v_bus_org;
    end if;

    for k in (
              select *
              from (
                    select
                            case
                            when b.html_type = 'DISPLAY_FIELD' AND a.balance_ele_value is null then
                              'N'
                            else
                              'Y'
                            end show_field, -- ONLY SHOW THE FIELDS THAT HAVE VALUE
                            b.ele_order, -- ORDER THE ELMENTS SHOULD BE DISPLAYED
                            b.html_type, -- SECTION,DISPLAY_FIELD,TEXT_CONTENT,SCRIPT_CONTENT,BUTTON
                            a.balance_ele_measure_unit,b.display_unit,b.mtg_short_name,b.source_system,a.balance_ele,to_number(b.display_row) display_row,b.display_col,
                            -- HTML LABEL
                            case
                            when b.html_type = 'TEXT_CONTENT' or
                                 b.html_type like 'SCRIPT_CONTENT%' then
                              null
                            else b.html_label -- DO NOT SHOW LABELS FOR TEXTS THAT TAKE UP THE WHOLE ROW
                            end html_label,
                            -- BALANCE_ELEMENT_VALUE -----------------------------
                            case
                            when b.html_type = 'TEXT_CONTENT' then
                              b.html_label
                            when b.html_type like 'SCRIPT_CONTENT%' then
                              b.balance_ele_value
                            else
                              a.balance_ele_value
                            end balance_ele_value,
                            -- DISPLAY_VALUE -------------------------------------
                            case -- CHECK ALL NON-CHARACTER STRINGS
                            when b.overwrite_val_with is not null then
                              b.overwrite_val_with
                            when b.html_type = 'TEXT_CONTENT' then
                              b.html_label
                            when regexp_like(a.balance_ele_value, '^[^a-zA-Z]*$')
                            then
                              ubi_pkg.convert_value(unit_value => a.balance_ele_value,convert_from => a.balance_ele_measure_unit, convert_to => b.display_unit,another_param=>'')||''
                            when b.html_type like 'SCRIPT_CONTENT%' then
                              b.balance_ele_value
                            else a.balance_ele_value
                            end display_value,
                            -- OVERWRITE VALUE -----------------------------------
                            b.overwrite_val_with
                  from (
                        select *
                        from table(ubi_pkg.get_balance_and_usage(ip_esn =>ip_esn, ip_balance_action_list=>ip_balance_action_list))
                        ) a,
                        (
                        select *
                        from table(ubi_pkg.balance_inq_page_elements(ip_esn =>ip_esn, ip_language => ip_language, ip_source_system =>ip_source_system, ip_balance_action_list=>ip_balance_action_list))
                        )b
                  where a.balance_ele(+) = b.balance_element

                  order by ele_order,display_row,display_col
                ) where show_field = 'Y'
              )
    loop
      -- BUTTON CONTROL LOGIC
      if k.html_type = 'BUTTON' and k.display_unit != 'STATIC' then
        -- FALL BACK CALL BUTTONS
        if (k.display_unit like k.mtg_short_name||'%') or -- FALL BACK CALL BUTTONS MUST HAVE THE METERING SHORT NAME AT THE START
            k.display_unit like 'BTN_%' -- k.display_unit in ('REFRESH','SEND_SMS','GET_LATEST_BAL','DAILY_USAGE') -- BASIC BUTTONS TO SHOW ALL
        then
          balance_inq_page_elements_rslt.config_objid := v_config_id;
          balance_inq_page_elements_rslt.ele_order := k.ele_order;
          balance_inq_page_elements_rslt.html_type := k.html_type;
          balance_inq_page_elements_rslt.html_label := k.html_label;
          balance_inq_page_elements_rslt.balance_ele_value := k.balance_ele_value;
          balance_inq_page_elements_rslt.balance_ele_measure_unit := k.balance_ele_measure_unit;
          balance_inq_page_elements_rslt.display_unit := k.display_unit;
          balance_inq_page_elements_rslt.mtg_short_name := k.mtg_short_name;
          balance_inq_page_elements_rslt.source_system := k.source_system;
          balance_inq_page_elements_rslt.balance_element := k.balance_ele;
          balance_inq_page_elements_rslt.display_row := k.display_row;
          balance_inq_page_elements_rslt.display_col := k.display_col;
          balance_inq_page_elements_rslt.display_value := k.display_value;
          balance_inq_page_elements_rslt.overwrite_val_with := k.overwrite_val_with;
          pipe row (balance_inq_page_elements_rslt);
        end if;
      else
        balance_inq_page_elements_rslt.config_objid := v_config_id;
        balance_inq_page_elements_rslt.ele_order := k.ele_order;
        balance_inq_page_elements_rslt.html_type := k.html_type;
        balance_inq_page_elements_rslt.html_label := k.html_label;
        if k.balance_ele = 'RATE_PLAN' then
          balance_inq_page_elements_rslt.balance_ele_value := sa.ubi_pkg.get_generic_script (ip_script_type =>substr(k.balance_ele_value,0,instr(k.balance_ele_value,'_')-1),
                                                                                            ip_script_id =>substr(k.balance_ele_value,instr(k.balance_ele_value,'_')+1),
                                                                                            ip_language => ip_language,
                                                                                            ip_sourcesystem => ip_source_system,
                                                                                            ip_brand => v_script_bus_org,
                                                                                            ip_pc => v_part_class);
          balance_inq_page_elements_rslt.display_value := balance_inq_page_elements_rslt.balance_ele_value;
        else
          balance_inq_page_elements_rslt.balance_ele_value := k.balance_ele_value;
          balance_inq_page_elements_rslt.display_value := k.display_value;
        end if;
        balance_inq_page_elements_rslt.balance_ele_measure_unit := k.balance_ele_measure_unit;
        balance_inq_page_elements_rslt.display_unit := k.display_unit;
        balance_inq_page_elements_rslt.mtg_short_name := k.mtg_short_name;
        balance_inq_page_elements_rslt.source_system := k.source_system;
        balance_inq_page_elements_rslt.balance_element := k.balance_ele;
        balance_inq_page_elements_rslt.display_row := k.display_row;
        balance_inq_page_elements_rslt.display_col := k.display_col;
        balance_inq_page_elements_rslt.overwrite_val_with := k.overwrite_val_with;
        pipe row (balance_inq_page_elements_rslt);
      end if;
    end loop;
  end balance_inq_rslt;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- USED BY get_balance_and_usage
  function get_balance_buckets_rslt(ip_trans_id varchar2)
  return get_balance_buckets_tab pipelined
  is
      b_switch_buckets_found boolean := false;
      get_balance_buckets_rslt get_balance_buckets_rec;

      cursor c_deenroll_bi is
      select ig.esn,
            ig.order_type,
            sp.benefit_type,
            ig.transaction_id,
            tsp.part_status,
            tt.title,
            ct.x_reason,
            spsp.x_service_plan_id,
            (select tp.x_parent_name
            from table_x_carrier tc,
              table_x_carrier_group cg,
              table_x_parent tp
            where 1         = 1
            and tp.objid    = cg.x_carrier_group2x_parent
            and cg.objid    = tc.carrier2carrier_group
            and tc.objid    = ct.x_call_trans2carrier
            and tp.x_status = 'ACTIVE'
            and rownum      = 1
            ) parent_name
        from ig_transaction ig,
          table_task tt,
          table_x_call_trans ct,
          table_site_part tsp,
          x_service_plan_site_part spsp,
          service_plan_feat_pivot_mv sp
        where ct.objid    = ip_trans_id
        and ct.x_sub_sourcesystem='TRACFONE'
        and spsp.x_service_plan_id=252
        and ig.action_item_id      = tt.task_id
        and tt.x_task2x_call_trans = ct.objid
        and ig.esn                 = tsp.x_service_id
        and tsp.objid              =
          (select max(tsp1.objid)
          from table_site_part tsp1
          where tsp1.x_service_id = tsp.x_service_id
          )
        and tsp.objid              = spsp.table_site_part_id
        and spsp.x_service_plan_id = sp.service_plan_objid;

        cursor cur_tfsl_unl is
        select spsp.x_service_plan_id,
               fea.service_plan_group,
               upper(fea.voice) service_plan_voice,
               upper(fea.sms) service_plan_sms
        from   table_x_call_trans ct,
               x_service_plan_site_part spsp,
               sa.service_plan_feat_pivot_mv fea
        where  ct.objid                = ip_trans_id
          and  spsp.table_site_part_id = ct.call_trans2site_part
          and  spsp.x_service_plan_id  = fea.service_plan_objid;

        rec_tfsl_unl      cur_tfsl_unl%rowtype;
        l_id_count        number := 0;
        l_skip_bucket_ids sa.bucket_id_tab :=  bucket_id_tab();

  begin
    -- THIS DEPRECATES CARRIER_SW_PKG.SP_GET_BALANCE
    -- THE CODE RETURNS THE SAME QUERIS. CHANGED THE RETURN FORMAT FOR SLUNLTD
    -- FROM IT'S ORGINAL
    -- THIS DEPRECATES CARRIER_SW_PKG.SP_GET_BALANCE
    -- CR52587 IMPLEMENTED A RULE if > 100GB data should be UNLIMITED
    -- HOWEVER, I'M NOW RETURNING VALUE 99999, Based off conversations w/Mansi

    --l_skip_bucket_ids := sa.carrier_sw_pkg.f_skip_bucket_ids ( i_calltrans_id => ip_trans_id );

    for i in (
              select  bk.objid,
                      balance_bucket2x_swb_tx,
                      bk.x_type,
                      bk.x_value,
                      bk.recharge_date,
                      bk.expiration_date,
                      bk.bucket_desc,
                      sa.carrier_sw_pkg.get_bucket_group (
                                                          i_bucket_id => bk.bucket_id,
                                                          i_call_trans_objid => ip_trans_id
                                                         ) bucket_group
--                     (select b.bucket_group
--                      from   ig_transaction i,
--                             table_task t,
--                             ig_buckets b
--                       where  i.action_item_id = t.task_id
--                       and    b.rate_plan = i.rate_plan
--                       and    t.x_task2x_call_trans = ip_trans_id
--                       and    b.bucket_id = bk.bucket_id) bucket_group -- THIS QUERY CAN REPLACE THE GET_BUCKET_GROUP FUNCTION
              from    x_swb_tx_balance_bucket bk,
                      x_switchbased_transaction xsb
              where   xsb.x_sb_trans2x_call_trans = ip_trans_id
              and     bk.balance_bucket2x_swb_tx = xsb.objid
              and     bk.bucket_id not in (
                                            select bucket_id
                                            from table(sa.ubi_pkg.skip_bucket_ids_rslt(ip_trans_id =>ip_trans_id))
                                          )
              )
    loop
      b_switch_buckets_found := true;
      get_balance_buckets_rslt.objid := i.objid;
      get_balance_buckets_rslt.balance_bucket2x_swb_tx := i.balance_bucket2x_swb_tx;
      get_balance_buckets_rslt.x_type := i.x_type;
      get_balance_buckets_rslt.x_value := i.x_value;
      get_balance_buckets_rslt.recharge_date := i.recharge_date;
      get_balance_buckets_rslt.expiration_date := i.expiration_date;
      get_balance_buckets_rslt.bucket_desc := i.bucket_desc;
      get_balance_buckets_rslt.bucket_group := i.bucket_group;
      pipe row (get_balance_buckets_rslt);
    end loop;

    if b_switch_buckets_found then
      -- IF BUCKETS ARE FOUND, CHECK IF IT'S A SAFELINK SERVICE PLAN W/UNLIMITED
      for i in (
                select ct.objid,spsp.x_service_plan_id,
                       fea.service_plan_group,
                       decode(upper(fea.voice),'UNLIMITED','99999') service_plan_voice,
                       decode(upper(fea.sms),'UNLIMITED','99999')  service_plan_sms
                from   table_x_call_trans ct,
                       x_service_plan_site_part spsp,
                       sa.service_plan_feat_pivot_mv fea
                where  1=1
                  AND   ct.objid                = ip_trans_id
                  and  spsp.table_site_part_id = ct.call_trans2site_part
                  and  spsp.x_service_plan_id  = fea.service_plan_objid
                  and service_plan_group = 'TFSL_UNLIMITED'
                )
      loop
        if i.service_plan_voice = '99999' then
          get_balance_buckets_rslt.objid := null;
          get_balance_buckets_rslt.balance_bucket2x_swb_tx := null;
          get_balance_buckets_rslt.x_type := 'min';
          get_balance_buckets_rslt.x_value := i.service_plan_voice;
          get_balance_buckets_rslt.recharge_date := null;
          get_balance_buckets_rslt.expiration_date := null;
          get_balance_buckets_rslt.bucket_desc := 'Purchase Voice';
          get_balance_buckets_rslt.bucket_group := null;
          pipe row (get_balance_buckets_rslt);
        end if;
        if i.service_plan_sms = '99999' then
          get_balance_buckets_rslt.objid := null;
          get_balance_buckets_rslt.balance_bucket2x_swb_tx := null;
          get_balance_buckets_rslt.x_type := 'msg';
          get_balance_buckets_rslt.x_value := i.service_plan_voice;
          get_balance_buckets_rslt.recharge_date := null;
          get_balance_buckets_rslt.expiration_date := null;
          get_balance_buckets_rslt.bucket_desc := 'Purchase Message';
          get_balance_buckets_rslt.bucket_group := null;
          pipe row (get_balance_buckets_rslt);
        end if;
      end loop;
    else
      -- IF SWITCHBASED RETURNS NOTHING, CHECK IG_BUCKETS
      for rec_c_deenroll_bi in c_deenroll_bi
      loop
        if rec_c_deenroll_bi.parent_name like '%SAFELINK%' then
            null;
          for j in (
                    select null objid,
                           null balance_bucket2x_swb_tx,
                           igb.measure_unit x_type,
                           igtb.bucket_balance x_value,
                           igtb.recharge_date recharge_date,
                           igtb.expiration_date expiration_date,
                           igb.bucket_desc bucket_desc,
                           null bucket_group
                    from gw1.ig_buckets igb,
                         gw1.ig_transaction_buckets igtb,
                         ig_transaction ig
                    where 1 = 1
                       and igb.bucket_id = igtb.bucket_id
                       and igtb.direction != 'OUTBOUND'
                       and igtb.transaction_id = rec_c_deenroll_bi.transaction_id
                       and ig.transaction_id=igtb.transaction_id
                       and igb.rate_plan = sa.util_pkg.get_esn_rate_plan(rec_c_deenroll_bi.esn)
                    )
          loop
            get_balance_buckets_rslt.objid := j.objid;
            get_balance_buckets_rslt.balance_bucket2x_swb_tx := j.balance_bucket2x_swb_tx;
            get_balance_buckets_rslt.x_type := j.x_type;
            get_balance_buckets_rslt.x_value := j.x_value;
            get_balance_buckets_rslt.recharge_date := j.recharge_date;
            get_balance_buckets_rslt.expiration_date := j.expiration_date;
            get_balance_buckets_rslt.bucket_desc := j.bucket_desc;
            get_balance_buckets_rslt.bucket_group := j.bucket_group;
            pipe row (get_balance_buckets_rslt);
          end loop;
        end if;
      end loop;
    end if;

  exception
    when others then
      null;
  end get_balance_buckets_rslt;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- USED BY get_balance_buckets_rslt
  function skip_bucket_ids_rslt(ip_trans_id varchar2)
  return simple_bucket_id_list_tab pipelined
  is
    simple_bucket_id_list_rslt simple_bucket_id_list_rec;
    l_esn                     sa.table_part_inst.part_serial_no%type;
    v_service_plan_days       varchar2(50);
  begin

    simple_bucket_id_list_rslt.bucket_id := null;

    begin
      select  x_service_id
      into    l_esn
      from    table_x_call_trans
      where   objid   = ip_trans_id;
    exception
      when others then
      null;
    end;

    begin
      select trim(regexp_replace(nvl(fea.service_days,0),'[[:alpha:]]','') ) service_plan_days
      into   v_service_plan_days
      FROM   x_service_plan_site_part spsp,
             sa.service_plan_feat_pivot_mv fea
      where  spsp.table_site_part_id = (select x_part_inst2site_part
                                        from table_part_inst
                                        where part_serial_no = l_esn)
      and    spsp.x_service_plan_id = fea.service_plan_objid;
    exception
      when others then
        null;
    end;

    --dbms_output.put_line('l_esn               =>'||l_esn||'<=');
    --dbms_output.put_line('v_service_plan_days =>'||v_service_plan_days||'<=');

    for i in (
              SELECT bk.bucket_id
              FROM   x_swb_tx_balance_bucket bk,
                     x_switchbased_transaction xsb
              WHERE  xsb.x_sb_trans2x_call_trans   = ip_trans_id
              AND    bk.balance_bucket2x_swb_tx    = xsb.objid
              /* Intergate returns the Wallet bucket balance as 0 in both cases i.e. if the bucket balance is 0 and if the bucket is not purchased.
                 Customer should not get balance, if he didn't purchase*/
              and    bk.bucket_id in ('WALLETICA','WALLETPB','WALLET')
              AND    bk.x_value = 0
              AND    bk.bucket_id NOT IN (SELECT bucket_list.bucket_id
                                           FROM  table_x_call_trans ct,
                                                 table_x_call_trans_ext ctext,
                                                 table(ctext.bucket_id_list) bucket_list
                                           WHERE ct.objid = ip_trans_id
                                           AND   ctext.call_trans_ext2call_trans = ct.objid
                                           AND   TRUNC(ct.x_transact_date) >  TRUNC(SYSDATE) - NVL(v_service_plan_days,0))
            )
    loop
      --dbms_output.put_line('bucket_id           =>'||i.bucket_id||'<=');
      simple_bucket_id_list_rslt.bucket_id := i.bucket_id;
      pipe row (simple_bucket_id_list_rslt);
    end loop;

  exception
    when others then
      null;
  end skip_bucket_ids_rslt;
  ------------------------------------------------------------------------------
  -- LOGIC TAKEN FROM ADFCRM_SAFELINK TO AVOID HAVING SOA DEPENDANCY ON TAS OBJECTS - CONSULTED W/NATALIO
  ------------------------------------------------------------------------------
  function is_still_safelink (ip_esn varchar2, ip_org_id varchar2) return varchar2
  as
    ret_val VARCHAR2(5) := 'false';
  begin
     if (ip_org_id in ('NET10','TRACFONE') and sa.ubi_pkg.is_phone_safelink(ip_esn) = 'true') or
        (ip_org_id in ('TRACFONE') and sa.ubi_pkg.is_past_safelink_enrolled(ip_esn) = 'true')
     then
        ret_val := 'true';
     end if;
     return ret_val;
  end;
  ------------------------------------------------------------------------------
  -- LOGIC TAKEN FROM ADFCRM_SAFELINK TO AVOID HAVING SOA DEPENDANCY ON TAS OBJECTS - CONSULTED W/NATALIO
  ------------------------------------------------------------------------------
  function is_phone_safelink (ip_esn varchar2) return varchar2
  as
    cnt number;
  begin
    select count(*)
    into   cnt
    from x_program_enrolled enroll, sa.x_program_parameters param
    where enroll.x_esn = ip_esn
    and enroll.x_enrollment_status not in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
    and param.x_prog_class = 'LIFELINE'
    and enroll.pgm_enroll2pgm_parameter = param.objid;

    if cnt > 0 then
      return 'true';
    else
      return 'false';
    end if;

  end is_phone_safelink;
  ------------------------------------------------------------------------------
  -- LOGIC TAKEN FROM ADFCRM_SAFELINK TO AVOID HAVING SOA DEPENDANCY ON TAS OBJECTS - CONSULTED W/NATALIO
  ------------------------------------------------------------------------------
  function is_past_safelink_enrolled(
    ip_esn varchar2)
  return varchar2
  as
    ret_val varchar2(5) := 'false';
    cnt     number;
  begin
    select count(1)
    into cnt
    from sa.x_program_enrolled pe,
      sa.x_program_parameters pgm,
      sa.x_sl_currentvals slcur,
      sa.x_sl_subs slsub
    where 1                     = 1
    and pgm.objid               = pe.pgm_enroll2pgm_parameter
    and slcur.x_current_esn     = pe.x_esn
    and slcur.lid               = slsub.lid
    and pgm.x_prog_class        = 'LIFELINE'
    and pe.x_sourcesystem      in ('VMBC', 'WEB')
    and pgm.x_is_recurring      = 1
    and pe.x_esn                = ip_esn
    and pe.x_enrollment_status <> 'ENROLLED'
    and pe.x_enrolled_date      =
      (select max(i_pe.x_enrolled_date)
      from sa.x_program_enrolled i_pe,
        sa.x_program_parameters i_pgm
      where i_pe.x_esn         = pe.x_esn
      and i_pgm.objid          = i_pe.pgm_enroll2pgm_parameter
      and i_pgm.x_prog_class   = 'LIFELINE'
      and i_pgm.x_is_recurring = 1
      )
    and not exists
      (select 1
      from sa.x_program_enrolled i_pe,
        sa.x_program_parameters i_pgm
      where i_pe.x_esn             = pe.x_esn
      and i_pgm.objid              = i_pe.pgm_enroll2pgm_parameter
      and i_pgm.x_prog_class       = 'LIFELINE'
      and i_pgm.x_is_recurring     = 1
      and i_pe.x_enrollment_status = 'ENROLLED'
      ) ;
    if cnt     > 0 then
      ret_val := 'true';
    end if;
    return ret_val;
  exception
  when others then
    return ret_val;
  end is_past_safelink_enrolled;
  ------------------------------------------------------------------------------
  function get_bi_trans_id_rslt(ip_trans_id varchar2)
  return get_bi_trans_id_tab pipelined
  is
    get_bi_trans_id_rslt get_bi_trans_id_rec;

    v_mtg_src  x_bi_transaction_log_detail.mtg_type%type;
    v_mtg_type x_bi_transaction_log_detail.mtg_src%type;
    v_trans_id x_bi_transaction_log_detail.trans_id%type;

    d_mtg_src  x_bi_transaction_log_detail.mtg_type%type;
    d_mtg_type x_bi_transaction_log_detail.mtg_src%type;
    d_trans_id x_bi_transaction_log_detail.trans_id%type;

  begin
    get_bi_trans_id_rslt.mtg_type := null;
    get_bi_trans_id_rslt.mtg_src := null;
    get_bi_trans_id_rslt.trans_id := null;

    -- THIS DEPRECATES BOTH PROCEDURES FROM CARRIER_SW_PKG.GET_BI_TRANS
    for i in (
              --EXECUTION PLAN CHECKOUTS GOOD IN SIT1
              select mtg_type,
                     mtg_src,
                     trans_id
              from   sa.x_bi_transaction_log_detail
              where  trans2trans_log_dtl = ip_trans_id
              and mtg_type in ('VOICE','DATA')
              )
    loop
      if i.mtg_type = 'VOICE' then
        v_mtg_type := i.mtg_type;
        v_mtg_src := i.mtg_src;
        v_trans_id := i.trans_id;
      end if;
      if i.mtg_type = 'DATA' then
        d_mtg_type := i.mtg_type;
        d_mtg_src := i.mtg_src;
        d_trans_id := i.trans_id;
      end if;
    end loop;
    if v_trans_id is null and d_trans_id is null then
      for i in (
                select voice_mtg_source,
                       voice_trans_id,
                       data_mtg_source,
                       data_trans_id
                from sa.x_bi_transaction_log
                where objid = ip_trans_id
                )
      loop
        v_mtg_type := 'VOICE';
        v_mtg_src := i.voice_mtg_source;
        v_trans_id := i.voice_trans_id;
        d_mtg_type := 'DATA';
        d_mtg_src := i.data_mtg_source;
        d_trans_id := i.data_trans_id;
      end loop;
    end if;

    begin
      select trans_creation_date
      into get_bi_trans_id_rslt.trans_date
      from sa.x_bi_transaction_log
      where objid = ip_trans_id;
    exception
      when others then
        null;
    end;

    if v_mtg_type is not null then
      get_bi_trans_id_rslt.mtg_type := v_mtg_type;
      get_bi_trans_id_rslt.mtg_src := v_mtg_src;
      get_bi_trans_id_rslt.trans_id := v_trans_id;
      pipe row (get_bi_trans_id_rslt);
    end if;
    if d_mtg_type is not null then
      get_bi_trans_id_rslt.mtg_type := d_mtg_type;
      get_bi_trans_id_rslt.mtg_src := d_mtg_src;
      get_bi_trans_id_rslt.trans_id := d_trans_id;
      pipe row (get_bi_trans_id_rslt);
    end if;

  end get_bi_trans_id_rslt;
  ------------------------------------------------------------------------------
  function get_generic_script  (ip_script_type varchar2,
                                ip_script_id varchar2,
                                ip_language varchar2,
                                ip_sourcesystem  varchar2,
                                ip_brand varchar2,
                                ip_pc varchar2) return varchar2

  as

    ip_brand_name varchar2(30);
    ip_carrier_id varchar2(10);
    op_objid varchar2(30);
    op_description varchar2(1000);
    op_script_text varchar2(4000);
    op_publish_by varchar2(30);
    op_publish_date date;
    op_sm_link varchar2(300);

    v_language varchar2(30);
    v_sourcesystem     varchar2(30);

  begin

    if ip_sourcesystem is null then
       v_sourcesystem := 'TAS';
    else
       v_sourcesystem := ip_sourcesystem;
    end if;

    if ip_language is null then
       v_language := 'ENGLISH';
    else
       select decode(upper(substr(ip_language,1,2)),'EN','ENGLISH','ES','SPANISH','ENGLISH')
       into v_language
       from dual;
    end if;

    sa.scripts_pkg.get_script_prc(
      ip_sourcesystem => v_sourcesystem,
      ip_brand_name => ip_brand,
      ip_script_type => ip_script_type,
      ip_script_id => ip_script_id,
      ip_language => v_language,
      ip_carrier_id => null,
      ip_part_class => ip_pc,
      op_objid =>   op_objid,
      op_description => op_description,
      op_script_text => op_script_text,
      op_publish_by => op_publish_by,
      op_publish_date => op_publish_date,
      op_sm_link => op_sm_link
    );

    return op_script_text;

  end get_generic_script;
  ------------------------------------------------------------------------------

PROCEDURE create_ubi_transaction  ( i_esn                 IN    VARCHAR2,
                                    i_min                 IN    VARCHAR2,
                                    i_action_text         IN    VARCHAR2, -- 'PERSGENCODE'
                                    i_source_system       IN    VARCHAR2,
                                    i_reason              IN    VARCHAR2, -- 'Balance Inquiry'
                                    i_action_type         IN    VARCHAR2, -- 7
                                    i_rsid                IN    VARCHAR2, -- 5050
                                    i_swb_status          IN    VARCHAR2, -- 'CarrierPending'
                                    i_swb_order_type      IN    VARCHAR2, -- BI
                                    i_x_value             IN    VARCHAR2, -- 0
                                    i_ig_order_type       IN    VARCHAR2, -- 'Balance Inquiry'
                                    i_pcrf_order_type     IN    VARCHAR2, -- 'BI'
                                    i_pcrf_status_code    IN    VARCHAR2, -- 'Q'
                                    o_err_code            OUT   VARCHAR2,
                                    o_err_msg             OUT   VARCHAR2
                                  )
IS
  l_meter_sources_tab                   meter_source_tab;
  --
  c_voice_metering_source               VARCHAR2(50);
  c_sms_metering_source                 VARCHAR2(50);
  c_data_metering_source                VARCHAR2(50);
  c_walletica_metering_source           VARCHAR2(50);
  c_walletpb_metering_source            VARCHAR2(50);
  n_data_daily_attempts_tshold          NUMBER;
  n_data_timeout_mins_tshold            NUMBER;
  --
  n_call_trans_objid                    NUMBER;
  --
  n_service_plan_id                     NUMBER;
  c_service_plan_name                   VARCHAR2(1000);
  n_serviceplanunlimited_flag           NUMBER;
  n_autorefill_flag                     NUMBER;
  d_service_end_dt                      DATE;
  d_forecast_date                       DATE;
  n_creditcardreg_flag                  NUMBER;
  n_redempcardqueue                     NUMBER;
  n_creditcardsch_flag                  NUMBER;
  c_statusid                            VARCHAR2(100);
  c_statusdesc                          VARCHAR2(1000);
  c_email                               VARCHAR2(100);
  c_part_num                            VARCHAR2(50);
  n_err_num                             NUMBER;
  --
  n_ai_status_code                      NUMBER;
  n_destination_queue                   NUMBER;
  n_ig_tran_status                      NUMBER;
  n_action_item_objid                   NUMBER;
  c_action_item_id                      VARCHAR2(30);
  --
  c                                     customer_type := customer_type();
  --
BEGIN
  -- Get Brand
  c.bus_org_id  := c.get_bus_org_id (i_esn =>  i_esn);
  -- Get Metering Sources
  carrier_sw_pkg.get_meter_sources (  i_esn               =>  i_esn,
                                      i_source_system     =>  i_source_system,
                                      o_meter_sources     =>  l_meter_sources_tab,
                                      o_err_code          =>  o_err_code,
                                      o_err_msg           =>  o_err_msg);
  --
  IF l_meter_sources_tab IS NOT NULL
  THEN
    FOR each_rec  IN   1 .. l_meter_sources_tab.COUNT
    LOOP
      --
      IF l_meter_sources_tab(each_rec).type     = 'VOICE'
      THEN
        c_voice_metering_source   :=  l_meter_sources_tab(each_rec).meter_source;
        --
      ELSIF l_meter_sources_tab(each_rec).type  = 'SMS'
      THEN
        c_sms_metering_source     :=  l_meter_sources_tab(each_rec).meter_source;
        --
      ELSIF l_meter_sources_tab(each_rec).type  = 'DATA'
      THEN
        c_data_metering_source            :=  l_meter_sources_tab(each_rec).meter_source;
        n_data_daily_attempts_tshold      :=  l_meter_sources_tab(each_rec).timeout_minutes_threshold;
        n_data_timeout_mins_tshold        :=  l_meter_sources_tab(each_rec).daily_attempts_threshold;
        --
      ELSIF l_meter_sources_tab(each_rec).type  = 'WALLETICA'
      THEN
        c_walletica_metering_source   :=  l_meter_sources_tab(each_rec).meter_source;
        --
      ELSIF l_meter_sources_tab(each_rec).type  = 'WALLETPB'
      THEN
        c_walletpb_metering_source    :=  l_meter_sources_tab(each_rec).meter_source;
        --
      END IF;
    END LOOP;
  END  IF;
  --
  -- Create Call Trans
  convert_bo_to_sql_pkg.sp_create_call_trans_2 (  ip_esn              =>  i_esn ,
                                                  ip_action_type      =>  i_action_type ,
                                                  ip_sourcesystem     =>  i_source_system ,
                                                  ip_brand_name       =>  c.bus_org_id ,
                                                  ip_reason           =>  i_reason ,
                                                  ip_result           =>  NULL ,
                                                  ip_ota_req_type     =>  NULL ,
                                                  ip_ota_type         =>  NULL ,
                                                  ip_total_units      =>  NULL ,
                                                  ip_orig_login_objid =>  NULL ,
                                                  ip_action_text      =>  i_action_text ,
                                                  op_calltranobj      =>  n_call_trans_objid ,
                                                  op_err_code         =>  o_err_code ,
                                                  op_err_msg          =>  o_err_msg);
  -- proceed if call trans is successful
  IF o_err_code = 0   AND n_call_trans_objid <> 0  -- Check this logic
  THEN
    -- Get service plan details
    Service_Plan.get_service_plan_prc( ip_esn                   =>  i_esn,
                                       op_serviceplanid         =>  n_service_plan_id ,
                                       op_serviceplanname       =>  c_service_plan_name ,
                                       op_serviceplanunlimited  =>  n_serviceplanunlimited_flag,  --1 if true and 0 if false
                                       op_autorefill            =>  n_autorefill_flag,            --1 if true and 0 if false
                                       op_service_end_dt        =>  d_service_end_dt,
                                       op_forecast_date         =>  d_forecast_date ,
                                       op_creditcardreg         =>  n_creditcardreg_flag,         --1 if true and 0 if false
                                       op_redempcardqueue       =>  n_redempcardqueue,
                                       op_creditcardsch         =>  n_creditcardsch_flag,         --1 if true and 0 if false
                                       op_statusid              =>  c_statusid,
                                       op_statusdesc            =>  c_statusdesc,
                                       op_email                 =>  c_email,
                                       op_part_num              =>  c_part_num,
                                       op_err_num               =>  n_err_num,
                                       op_err_string            =>  o_err_msg);
    --
    -- Create switch based transaction
    carrier_sw_pkg.create_swb_transaction(  ip_call_trans =>  n_call_trans_objid,
                                            ip_status     =>  i_swb_status,
                                            ip_x_type     =>  i_swb_order_type,
                                            ip_x_value    =>  i_x_value,
                                            ip_exp_date   =>  d_forecast_date,
                                            ip_rsid       =>  i_rsid,
                                            op_err_code   =>  n_err_num,
                                            op_err_msg 	  =>  o_err_msg);
    --
    -- Create Action item
    igate.sp_set_action_item_ig_trans(  in_contact_objid        => NULL, -- in_contact_objid,
                                        in_call_trans_objid     => n_call_trans_objid,
                                        in_order_type           => i_ig_order_type,
                                        in_bypass_order_type    => NULL, -- in_bypass_order_type,
                                        in_case_code            => NULL, --in_case_code,
                                        in_trans_method         => NULL, --in_trans_method,
                                        in_application_system   => 'IG',
                                        in_service_days         => NULL,
                                        in_voice_units          => NULL,
                                        in_text_units           => NULL,
                                        in_data_units           => NULL,
                                        out_ai_status_code      => n_ai_status_code,
                                        out_destination_queue   => n_destination_queue,
                                        out_ig_tran_status      => n_ig_tran_status,
                                        out_action_item_objid   => n_action_item_objid,
                                        out_action_item_id      => c_action_item_id,
                                        out_errorcode           => o_err_code,
                                        out_errormsg            => o_err_msg
                                      );
    --
    -- Create BI Transaction
    -- CARRIER_SW_PKG. CREATE_BI_TRANS
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END create_ubi_transaction;
--
end ubi_pkg;
/