CREATE OR REPLACE package body sa.adfcrm_apn_pkg
as
  ------------------------------------------------------------------------------
  function handset_manuf_list
  return handset_manuf_tab pipelined
  is
  begin
    for i in (select distinct display_order, handset_manufacturer from adfcrm_handset_os where handset_manufacturer is not null order by display_order)
    loop
        handset_manuf_rslt.handset_manufacturer := i.handset_manufacturer;
        pipe row (handset_manuf_rslt);
    end loop;
    return;
  end handset_manuf_list;
  ------------------------------------------------------------------------------
  function handset_os_list
  return handset_os_tab pipelined
  is
  begin
    for i in (select distinct display_order, operating_system from adfcrm_handset_os where operating_system is not null order by display_order)
    loop
        handset_os_rslt.operating_system := i.operating_system;
        pipe row (handset_os_rslt);
    end loop;
    return;
  end handset_os_list;
  ------------------------------------------------------------------------------
  function handset_rslt_list(ip_type varchar2, ip_value varchar2)
  return handset_rslt_tab pipelined
  is
  begin
    if ip_type = 'OS' then
      for i in (select objid,os_desc
                from adfcrm_handset_os
                where operating_system = ip_value
                or operating_system in ('Select One','Other')
                order by display_order)
      loop
          handset_rslt_rslt.objid := i.objid;
          handset_rslt_rslt.obj_desc := i.os_desc;
          pipe row (handset_rslt_rslt);
      end loop;
    else
      for i in (select objid,handset_desc
                from adfcrm_handset_os
                where handset_manufacturer = ip_value
                or handset_manufacturer in ('Select One','Other')
                order by display_order)
      loop
          handset_rslt_rslt.objid := i.objid;
          handset_rslt_rslt.obj_desc := i.handset_desc;
          pipe row (handset_rslt_rslt);
      end loop;
    end if;
    return;
  end handset_rslt_list;
  ------------------------------------------------------------------------------
  function get_settings(ip_esn in varchar2)
  return adfcrm_esn_structure
  is
    apn_tab  sa.adfcrm_esn_structure := sa.adfcrm_esn_structure();
    p_rate_plan varchar2(60);
    p_org_id varchar2(100);
    stmt varchar2(1000);

    p_error_code number;
    p_error_message varchar2(200);

  begin
    sa.service_plan.sp_get_esn_rate_plan (p_esn => ip_esn,
                                          p_rate_plan => p_rate_plan,
                                          p_error_code => p_error_code,
                                          p_error_message => p_error_message);

    select bo.org_id
    into   p_org_id
    from   sa.table_part_inst pi,
           sa.table_mod_level m,
           sa.table_part_num pn,
           sa.table_bus_org bo
    where  pn.objid = m.part_info2part_num
    and    pn.part_num2bus_org = bo.objid
    and    m.objid = pi.n_part_inst2part_mod
    and    pi.part_serial_no = ip_esn;

    stmt := 'select * from sa.x_apn where upper(rate_plan) = upper('''||p_rate_plan||''') and org_id = '''||p_org_id||'''';

    dbms_output.put_line('P_RATE_PLAN = ' || p_rate_plan);
    dbms_output.put_line('stmt = ' || stmt);

    for i in (select   *
              from   xmltable ('//ROW/*' passing dbms_xmlgen.getxmltype (stmt)
                               columns name varchar2 (300) path 'node-name(.)',
                               value varchar2 (300) path '.'))
    loop
      if i.name not in ('X_PARENT_NAME','RATE_PLAN') then
        apn_tab.extend;
        if i.name = 'ORG_ID' then
          apn_tab(apn_tab.last) := adfcrm_esn_structure_row_type('NAME', i.value);
        elsif i.name = 'PROXY_PORT' then
          apn_tab(apn_tab.last) := adfcrm_esn_structure_row_type('PORT', i.value);
        elsif i.name = 'PROXY_ADDRESS' then
          apn_tab(apn_tab.last) := adfcrm_esn_structure_row_type('PROXY', i.value);
        elsif i.name = 'MMS_PROXY_ADDRESS' then
          apn_tab(apn_tab.last) := adfcrm_esn_structure_row_type('MMS PROXY', i.value);
        elsif i.name = 'MMS_PROXY_PORT' then
          apn_tab(apn_tab.last) := adfcrm_esn_structure_row_type('MMS PORT', i.value);
        else
          apn_tab(apn_tab.last) := adfcrm_esn_structure_row_type(i.name, i.value);
        end if;
      end if;
      end loop;

    return apn_tab;

  end get_settings;
  ------------------------------------------------------------------------------
  procedure find_settings_instruction(ip_os_objid number,
                                      ip_language varchar2,
                                      ip_brand varchar2,
                                      op_script_text out varchar2)
  as
    op_objid varchar2(200);
    op_description varchar2(200);
    op_publish_by varchar2(200);
    op_publish_date date;
    op_sm_link varchar2(200);
    v_prefix varchar2(30);
    v_suffix varchar2(30);
    ERR_CODE VARCHAR2(4000) ;
    ERR_MSG VARCHAR2(4000) ;

  begin

    select substr(script_id,0,instr(script_id,'_')-1) prefix,
           substr(script_id,instr(script_id,'_')+1) suffix
    into   v_prefix,v_suffix
    from   adfcrm_handset_os
    where  objid = ip_os_objid;

    scripts_pkg.get_script_prc (ip_sourcesystem => 'TAS',
                                ip_brand_name => ip_brand,
                                ip_script_type => v_prefix,
                                ip_script_id => v_suffix,
                                ip_language => ip_language,
                                ip_carrier_id => null,
                                ip_part_class => null,
                                op_objid => op_objid,
                                op_description => op_description,
                                op_script_text => op_script_text,
                                op_publish_by => op_publish_by,
                                op_publish_date => op_publish_date,
                                op_sm_link => op_sm_link);

--dbms_output.put_line('OP_OBJID = ' || op_objid);
--dbms_output.put_line('OP_DESCRIPTION = ' || op_description);
--dbms_output.put_line('OP_SCRIPT_TEXT = ' || op_script_text);
--dbms_output.put_line('OP_PUBLISH_BY = ' || op_publish_by);
--dbms_output.put_line('OP_PUBLISH_DATE = ' || op_publish_date);
--dbms_output.put_line('OP_SM_LINK = ' || op_sm_link);

  exception
    when others then
        err_code := SQLCODE;
        err_msg := substr(sqlerrm, 1, 200);
  end find_settings_instruction;
  ------------------------------------------------------------------------------
  function find_settings_instruction(ip_os_objid number,
                                     ip_language varchar2,
                                     ip_brand varchar2)
  return find_settings_ins_tab pipelined
  is
  begin
    find_settings_instruction(ip_os_objid => ip_os_objid,
                              ip_language => ip_language,
                              ip_brand => ip_brand,
                              op_script_text => find_settings_ins_rslt.script_text);

    pipe row (find_settings_ins_rslt);
    return;
  end find_settings_instruction;
  ------------------------------------------------------------------------------
  procedure display_link_url(ip_esn varchar2,ip_os_objid varchar2,op_brand out varchar2, op_msg out varchar2)
  as
    cursor c1
    is
    select col, val
    from table(sa.adfcrm_apn_pkg.get_settings(ip_esn =>ip_esn)); -- SIT1

    c1_rec c1%rowtype;

    cursor c2
    is
    select *
    from adfcrm_handset_os
    where objid = ip_os_objid;

    c2_rec c2%rowtype;

    part_class varchar2(30);
    setting_exists number := 0;
    os_exists number := 0;
    is_byop_cnt number := 0;
    os varchar2(30);
    script_id varchar2(30);
  begin
    op_msg := 'NO_LINK_REQUIRED';
    -- THE LINK IS ONLY AVAILABLE TO ANDROID OR A (TMOBILE IPHONE)
    --dbms_output.put_line('ip_esn => '||ip_esn);
    --dbms_output.put_line('ip_os_objid => '||ip_os_objid);

    select pc.name part_class,
           b.org_id org_id
    into   part_class,
           op_brand
    from   table_part_inst i,
           table_mod_level m,
           table_part_num pn,
           table_part_class pc,
           table_bus_org b
    where  1=1
    and    i.x_domain = 'PHONES'
    and    i.n_part_inst2part_mod = m.objid
    and    pn.objid = m.part_info2part_num
    and    pn.part_num2bus_org = b.objid
    and    pn.part_num2part_class = pc.objid
    and    i.part_serial_no = ip_esn;

    select count(*)
    into   is_byop_cnt
    from   pc_params_view
    where  1=1
    and    part_class = part_class
    and    param_name in ('OPERATING_SYSTEM')
    and    param_value = 'BYOP';

    --dbms_output.put_line('part_class => '||part_class);
    --dbms_output.put_line('op_brand => '||op_brand);

    if op_brand in ('NET10','STRAIGHT_TALK','TELCEL') and
       is_byop_cnt > 0 then
      dbms_output.put_line('continue...');
    else
      --dbms_output.put_line('BRAND IS NOT NT,ST,TC OR OPERATING SYSTEM IS NOT BYOP');
      return;
    end if;

    open c2;
    loop
      fetch c2 into c2_rec;
      exit when c2%notfound;
      os_exists := os_exists+1;
      os := c2_rec.operating_system;

      -- dbms_output.put_line('OS => ' || c2_rec.operating_system);
      -- dbms_output.put_line(c2_rec.os_version);
      -- dbms_output.put_line(c2_rec.os_desc);
      -- dbms_output.put_line(c2_rec.handset_manufacturer);
      -- dbms_output.put_line(c2_rec.handset_desc);
      -- dbms_output.put_line(c2_rec.script_id);

        if c2_rec.operating_system = 'Android' then
          op_msg := 'APN_LINK_ANDROID';
          exit;
        end if;

        -- IOS T-MOBILE
        if c2_rec.operating_system = 'IOS' then
          open c1;
          loop
            fetch c1 into c1_rec;
            exit when c1%notfound;
            --dbms_output.put_line(c1_rec.col);
            --dbms_output.put_line(c1_rec.val);
            setting_exists := setting_exists+1;
            if c1_rec.col like '%X_PARENT_NAME%' then
              --dbms_output.put_line('X_PARENT_NAME ==================================================================='||c1_rec.val);
              if c1_rec.val = 'T-Mobile' then
                op_msg := 'APN_LINK_IPHONE_TMOBILE';
              end if;
            end if;
          end loop;
          close c1;

          if setting_exists = 0 then
            op_msg := 'NO_LINK_REQUIRED';
            return;
          end if;
        end if;

    end loop;
    close c2;


    if os_exists = 0 then
      op_msg := 'NO_LINK_REQUIRED';
    end if;

      -- ONE OF THE FOLLOWING MESSAGES BELOW SHOULD RETURN
      -- 1 APN_LINK_ANDROID
      -- 2 APN_LINK_IPHONE_TMOBILE
      -- 3 NO_LINK_REQUIRED
      -- IF THE OS OR SETTINGS ARE NOT FOUND OR NO DATA IS FOUND FROM THE SELECT INTO, THEN NO_LINK_REQUIRED WILL DISPLAY
  exception
    when others then
      op_msg := 'NO_LINK_REQUIRED';
  end display_link_url;
--------------------------------------------------------------------------------
  function get_url_script(ip_esn varchar2,ip_delivery_method varchar2, ip_os_objid varchar2,ip_lang varchar2)
  return varchar2
  as
    cursor c1
    is
    select col, val
    from table(sa.adfcrm_apn_pkg.get_settings(ip_esn =>ip_esn)); -- SIT1

    c1_rec c1%rowtype;

    cursor c2
    is
    select *
    from adfcrm_handset_os
    where objid = ip_os_objid;

    c2_rec c2%rowtype;

    apn_link varchar2(50) := '';
    p_brand varchar2(30);
    d_method varchar2(30) := 'SEND_EMAIL_';
    os varchar2(30);
    script_id varchar2(30);
    OP_SCRIPT_TEXT VARChar2(4000);
  begin
    -- THE LINK IS ONLY AVAILABLE TO ANDROID OR A (TMOBILE IPHONE)
    --dbms_output.put_line('ip_esn => '||ip_esn);
    --dbms_output.put_line('ip_delivery_method => '||ip_delivery_method);
    --dbms_output.put_line('ip_os_objid => '||ip_os_objid);

    if ip_delivery_method  is null then
      return 'MISSING_DELIVERY_METHOD';
    end if;

    if ip_delivery_method = 'sms' then
     d_method := 'SEND_SMS_';
    end if;

    display_link_url(ip_esn => ip_esn,ip_os_objid=> ip_os_objid,op_brand => p_brand, op_msg => apn_link);

    if apn_link = 'NO_LINK_REQUIRED' then
      return apn_link;
    else
      dbms_output.put_line('RQST MAP =>'||d_method||apn_link);
      -- SEND_EMAIL_APN_LINK_ANDROID
      -- SEND_EMAIL_APN_LINK_IPHONE_TMOBILE
      -- SEND_SMS_APN_LINK_ANDROID
      -- SEND_SMS_APN_LINK_IPHONE_TMOBILE

      SCRIPTS_PKG.GET_ERROR_MAP_SCRIPT(
        ip_func_name => d_method||apn_link,
        IP_FLOW_NAME => 'APN_SETTINGS_PG',
        IP_ERROR_CODE => '100',
        IP_DEFAULT_MSG => null,
        ip_default_script_id => null,
        ip_brand => p_brand,
        IP_LANGUAGE => ip_lang,
        ip_source_system => 'TAS',
        ip_part_class => null,
        IP_REPLACE_TOKENS => 'Y',
        OP_SCRIPT_TEXT => OP_SCRIPT_TEXT
      );


      return OP_SCRIPT_TEXT;
    end if;
  end get_url_script;
--------------------------------------------------------------------------------
END adfcrm_apn_pkg;
/