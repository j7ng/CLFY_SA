CREATE OR REPLACE PACKAGE BODY sa."APEX_CASE_RES_PKG" is
  procedure load_data (ipn_resol2conf_hdr     table_x_case_resolutions.resol2conf_hdr%type,
                       ipn_objid              table_x_case_resolutions.objid%type,
                       opv_x_condition        out table_x_case_resolutions.x_condition%type,
                       opv_x_resolution       out table_x_case_resolutions.x_resolution%type,
                       opv_x_status           out table_x_case_resolutions.x_status%type,
                       opn_x_std_resol_time   out table_x_case_resolutions.x_std_resol_time%type,
                       opv_x_agent_resolution out table_x_case_resolutions.x_agent_resolution%type,
                       opv_x_cust_resol_eng   out table_x_case_resolutions.x_cust_resol_eng%type,
                       opv_x_cust_resol_spa   out table_x_case_resolutions.x_cust_resol_spa%type,
                       opv_condition_status   out varchar2)
  as
  begin
    select x_condition,
           x_resolution,
           x_status,
           x_std_resol_time, -- value either 0 or null
           x_agent_resolution,
           x_cust_resol_eng,
           x_cust_resol_spa,
           x_condition||'~'||x_status
    into   opv_x_condition,
           opv_x_resolution,
           opv_x_status,
           opn_x_std_resol_time,
           opv_x_agent_resolution,
           opv_x_cust_resol_eng,
           opv_x_cust_resol_spa,
           opv_condition_status
    from   sa.table_x_case_resolutions
    where  resol2conf_hdr = ipn_resol2conf_hdr
    and    objid = ipn_objid;

  exception
    when others then
      opv_x_condition        := null;
      opv_x_resolution       := null;
      opv_x_status           := null;
      opn_x_std_resol_time   := null;
      opv_x_agent_resolution := null;
      opv_x_cust_resol_eng   := null;
      opv_x_cust_resol_spa   := null;
      opv_condition_status   := null;
  end load_data;
--------------------------------------------------------------------------------
  procedure ins_case_resolution (ipv_condition         table_x_case_resolutions.x_condition%type,
                                 ipv_resolution        table_x_case_resolutions.x_resolution%type,
                                 ipv_agent_resolution  table_x_case_resolutions.x_agent_resolution%type,
                                 ipv_status            table_x_case_resolutions.x_status%type,
                                 ipv_cust_resol_eng    table_x_case_resolutions.x_cust_resol_eng%type,
                                 ipv_cust_resol_spa    table_x_case_resolutions.x_cust_resol_spa%type,
                                 ipn_std_resol_time    table_x_case_resolutions.x_std_resol_time%type,
                                 ipn_resol2conf_hdr    table_x_case_resolutions.resol2conf_hdr%type,
                                 opv_msg out varchar2)
  as
  begin
    insert into sa.table_x_case_resolutions
      (objid,
       x_condition,
       x_resolution,
       x_agent_resolution,
       x_status,
       x_cust_resol_eng,
       x_cust_resol_spa,
       x_std_resol_time,
       resol2conf_hdr)
    values
      (sa.seq('x_case_resolutions'),
       ipv_condition,
       ipv_resolution,
       ipv_agent_resolution,
       decode(ipv_condition,'CLOSED','Closed',ipv_status),
       ipv_cust_resol_eng,
       ipv_cust_resol_spa,
       ipn_std_resol_time,
       ipn_resol2conf_hdr);

    opv_msg := 'INSERT SUCCESS - TOTAL ('||sql%rowcount||')';

  exception
    when others then
      opv_msg := 'ERROR INSERTING - '|| sqlerrm;
  end ins_case_resolution;
--------------------------------------------------------------------------------
  procedure upd_case_resolution (ipn_objid             table_x_case_resolutions.objid%type,
                                 ipv_condition         table_x_case_resolutions.x_condition%type,
                                 ipv_resolution        table_x_case_resolutions.x_resolution%type,
                                 ipv_agent_resolution  table_x_case_resolutions.x_agent_resolution%type,
                                 ipv_status            table_x_case_resolutions.x_status%type,
                                 ipv_cust_resol_eng    table_x_case_resolutions.x_cust_resol_eng%type,
                                 ipv_cust_resol_spa    table_x_case_resolutions.x_cust_resol_spa%type,
                                 ipn_std_resol_time    table_x_case_resolutions.x_std_resol_time%type,
                                 opv_msg out varchar2)
  as
  begin
    update sa.table_x_case_resolutions
    set    x_condition        = ipv_condition,
           x_resolution       = ipv_resolution,
           x_agent_resolution = ipv_agent_resolution,
           x_status           = ipv_status,
           x_cust_resol_eng   = ipv_cust_resol_eng,
           x_cust_resol_spa   = ipv_cust_resol_spa,
           x_std_resol_time   = ipn_std_resol_time
    where  objid = ipn_objid;

    opv_msg := 'UPDATE SUCCESS - TOTAL ('||sql%rowcount||')';

  exception
    when others then
      opv_msg := 'ERROR UPDATING - '|| sqlerrm;
  end upd_case_resolution;
--------------------------------------------------------------------------------
  procedure del_case_resolution (ipn_objid table_x_case_resolutions.objid%type,
                                 opv_msg out varchar2)
  as
  begin
    delete sa.table_x_case_resolutions
    where objid = ipn_objid;

    opv_msg := 'DELETE SUCCESS - TOTAL ('||sql%rowcount||')';

  exception
    when others then
      opv_msg := 'ERROR DELETE - '|| sqlerrm;
  end del_case_resolution;
--------------------------------------------------------------------------------
  function get_case_res_query (ipv_query varchar2,
                               ipv_var_1 varchar2,
                               ipv_src_db varchar2)
  return varchar2
  as
    v_sql_stmt varchar2(4000);
    v_src_db varchar2(30);
  begin
    if ipv_src_db is not null then
      v_src_db := '@'||ipv_src_db;
    end if;

    if ipv_query = 'CONFIG_HDR_DROP_DOWN' then
      v_sql_stmt := ' select ''res cnt: (''||count(res.objid)||'') warehouse: (''||nvl(hdr.x_warehouse,0)||'') - ''||hdr.x_case_type||'' - ''||hdr.x_title d, '||chr(10)
                 || ' hdr.objid r '||chr(10)
                 || ' from   sa.table_x_case_conf_hdr'||v_src_db||' hdr, '||chr(10)
                 || '        sa.table_x_case_resolutions'||v_src_db||' res '||chr(10)
                 || ' where  res.resol2conf_hdr(+) = hdr.objid '||chr(10)
                 || ' group by hdr.x_case_type, hdr.x_title, hdr.x_warehouse,hdr.objid '||chr(10)
                 || ' order by hdr.x_case_type, hdr.x_title ';

    elsif ipv_query = 'RESOLUTION_DROP_DOWN' then
--      v_sql_stmt := ' select x_condition||'' - ''||x_status||'' - ''||nvl(x_resolution,''N/A'') d,'||chr(10)
      v_sql_stmt := ' select x_condition|| decode(x_condition,''CLOSED'','' - '','' - ''||x_status||'' - '')||nvl(x_resolution,''N/A'') d,'||chr(10)
                 || '        objid r'||chr(10)
                 || ' from   sa.table_x_case_resolutions'||v_src_db||' '||chr(10)
                 || ' where  resol2conf_hdr = '||to_number(ipv_var_1);

    elsif ipv_query = 'CONDITION_DROP_DOWN' then
      v_sql_stmt := ' select upper(title) d,'||chr(10)
                 || '        upper(title) r'||chr(10)
                 || ' from   sa.table_gbst_lst'||v_src_db||' '||chr(10)
                 || ' where  title in (''Open'',''Closed'')';

    elsif ipv_query = 'STATUS_DROP_DOWN' then
      v_sql_stmt := ' select elm.title d,'||chr(10)
                 || '        elm.title r'||chr(10)
                 || ' from   sa.table_gbst_elm'||v_src_db||' elm,'||chr(10)
                 || '        sa.table_gbst_lst'||v_src_db||' lst'||chr(10)
                 || ' where  elm.gbst_elm2gbst_lst = lst.objid'||chr(10)
                 || ' and    upper(lst.title) = '''||ipv_var_1||''''||chr(10)
                 || ' and    elm.title = decode(lst.title,''Closed'',''Closed'',elm.title)'||chr(10)
                 || ' order by rank';

    elsif ipv_query = 'CONDITION_STATUS_DROP_DOWN' then
      v_sql_stmt := ' select d, r'||chr(10)
--                 || ' from  (select ''CLOSED - ''||elm.title d,'||chr(10)
                 || ' from  (select elm.title d,'||chr(10)
                 || '               ''CLOSED~''||elm.title r,'||chr(10)
                 || '               rank'||chr(10)
                 || '        from   sa.table_gbst_elm'||v_src_db||' elm,'||chr(10)
                 || '               sa.table_gbst_lst'||v_src_db||' lst'||chr(10)
                 || '        where  elm.gbst_elm2gbst_lst = lst.objid'||chr(10)
                 || '        and    upper(lst.title) = ''CLOSED'''||chr(10)
                 || '        and    elm.title = decode(lst.title,''Closed'',''Closed'',elm.title)'||chr(10)
                 || '        UNION'||chr(10)
                 || '        select ''OPEN - ''||elm.title d,'||chr(10)
                 || '               ''OPEN~''||elm.title r,'||chr(10)
                 || '               rank'||chr(10)
                 || '        from   sa.table_gbst_elm'||v_src_db||' elm,'||chr(10)
                 || '               sa.table_gbst_lst'||v_src_db||' lst'||chr(10)
                 || '        where  elm.gbst_elm2gbst_lst = lst.objid'||chr(10)
                 || '        and    upper(lst.title) = ''OPEN'''||chr(10)
                 || '        and    elm.title = decode(lst.title,''Closed'',''Closed'',elm.title)'||chr(10)
                 || '        order by rank)'||chr(10)
                 || '';
    else
      v_sql_stmt := 'select 1 from dual';
    end if;

    return v_sql_stmt;

  end get_case_res_query;
--------------------------------------------------------------------------------

function display_res_drop_down (ipv_hdr_objid varchar2,
                                ipv_src_db varchar2)
return boolean
as
  v varchar2(1000);
  n number := 0;

  cs sys_refcursor;
  type cur_type is record(d varchar2(1000),
                          r number);
  out_rec cur_type;
begin
  v := get_case_res_query('RESOLUTION_DROP_DOWN',ipv_hdr_objid,ipv_src_db);

  open cs for v;
    loop
      fetch cs into out_rec;
      exit when cs%notfound;
      n := n+1;
    end loop;

    if n > 0 then
      return true;
    else
      return false;
    end if;
  close cs;
end display_res_drop_down;

--------------------------------------------------------------------------------
end apex_case_res_pkg;
/