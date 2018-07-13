CREATE OR REPLACE package body sa.apex_apn_pkg
is
  function  ins_data_mapping (ipv_x_parent_id varchar2,
                              ipv_part_class_objid number,
                              ipv_x_rate_plan varchar2,
                              ipv_user varchar2,
                              ipv_x_data_config_objid number)
  return boolean
  as
  begin
    merge into data_config_mapping a
    using (select 1 from dual)
    on    (a.x_parent_id = ipv_x_parent_id
    and    a.x_part_class_objid = ipv_part_class_objid
    and    a.x_rate_plan = ipv_x_rate_plan
    and    a.x_data_config_objid = ipv_x_data_config_objid)
    when not matched then
    insert
      (x_parent_id,
       x_part_class_objid,
       x_rate_plan,
       x_data_config_objid)
    values
      (ipv_x_parent_id,
       ipv_part_class_objid,
       ipv_x_rate_plan,
       ipv_x_data_config_objid);

    insert into data_config_mapping_log
      (x_parent_id,
       x_part_class_objid,
       x_rate_plan,
       x_data_config_objid,
       action,
       changed_by,
       change_date)
    values
      (ipv_x_parent_id,
       ipv_part_class_objid,
       ipv_x_rate_plan,
       ipv_x_data_config_objid,
       'INSERT',
       ipv_user,
       sysdate);

    return true;

  exception
    when others then
      return false;
  end ins_data_mapping;

  procedure copy_pc_data_mappings(ipv_src varchar2,
                                  ipv_mapping_rowid varchar2,
                                  ipv_dest_list clob,
                                  ipv_user varchar2,
                                  opv_msg out varchar2)
  as
    gen_refcur      sys_refcursor;
    sqlstmt         clob;
    v_src_objid     number;
    v_dest_objid    number;
    v_src_parent_id varchar2(30);
    v_src_rate_plan varchar2(30);
    v_src_dc_objid  number;
    v_dest_list     clob;
    n_success       number := 0;
    n_failures      number := 0;
  begin
    -- REMOVE THE LAST COMMA AND WRAP WITH TICKS
    -- v_dest_list := ''''||replace(substr(ipv_dest_list,1,length(ipv_dest_list)-1),',',''',''')||'''';
    v_dest_list := ''''||replace(ipv_dest_list,',',''',''')||'''';

    -- GET THE SRC OBJID
    begin
      select objid
      into   v_src_objid
      from   table_part_class
      where  name = ipv_src;
    exception
      when others then
        opv_msg := ipv_src||' DOESN''T EXIST';
        goto end_prc;
    end;

    -- GET THE DATA FROM THE SOURCE
    begin
      select x_parent_id,         -- D2
             x_rate_plan,         -- D4
             x_data_config_objid  -- D5
      into   v_src_parent_id,
             v_src_rate_plan,
             v_src_dc_objid
      from   data_config_mapping
      where  x_part_class_objid = v_src_objid
      and    rowid = decode(ipv_mapping_rowid,null,rowid,ipv_mapping_rowid);
    exception
      when others then
        opv_msg := 'ISSUE OBTAINING DATA CONFIG MAPPING FOR '||ipv_src|| sqlerrm;
        -- opv_msg := 'NO DATA CONFIG MAPPING EXISTS FOR '||ipv_src;
        goto end_prc;
    end;

    -- LOOP THRU THE DEST PART CLASSES
    sqlstmt := ' select objid from table_part_class where name in ('||v_dest_list||')';
    open gen_refcur for sqlstmt;
    loop
      fetch gen_refcur into v_dest_objid;
      exit when gen_refcur%NOTFOUND;
        if (ins_data_mapping (v_src_parent_id,
                              v_dest_objid,
                              v_src_rate_plan,
                              ipv_user,
                              v_src_dc_objid)) then
          n_success := n_success+1;
        else
          n_failures := n_failures+1;
        end if;
    end loop;
    close gen_refcur;

    <<end_prc>>
    if opv_msg is null then
      opv_msg := 'COPIED '||ipv_src||' WITH ('||n_success||') SUCCESSFUL AND ('||n_failures||') FAILURES';
    end if;

  end copy_pc_data_mappings;

end apex_apn_pkg;
/