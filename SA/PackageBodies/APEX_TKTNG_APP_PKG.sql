CREATE OR REPLACE PACKAGE BODY sa."APEX_TKTNG_APP_PKG"
is
--------------------------------------------------------------------------------
-- CREATE TRIGGER --------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure ins_trig (ip_star_rank number,
                      ip_auto_carrier number,
                      ip_hours2escalate number,
                      ip_prev_case_count number,
                      ip_prev_case_days number,
                      ip_re_open_count number,
                      ip_tat_hours number,
                      ip_ec_objid number,
                      op_msg_out out varchar2)
  as
  v_objid number;
  begin
    select sa.seq('x_escalation_speed')
    into v_objid
    from dual;

    insert into sa.table_x_escalation_speed (objid,
                                             x_star_rank,
                                             x_auto_carrier,
                                             x_hours2escalate,
                                             x_prev_case_count,
                                             x_prev_case_days,
                                             x_re_open_count,
                                             x_tat_hours,
                                             speed2escalation)
    values (v_objid,
            ip_star_rank,
            ip_auto_carrier,
            ip_hours2escalate,
            ip_prev_case_count,
            ip_prev_case_days,
            ip_re_open_count,
            ip_tat_hours,
            ip_ec_objid);

    op_msg_out := 'ins_trig - ' || v_objid;
  exception
    when dup_val_on_index then
    null;
    when others then
    op_msg_out := 'ins_trig - ' || sqlerrm;
    dbms_output.put_line('ins_trig - trigger combination already exists');
  end;
--------------------------------------------------------------------------------
-- UPDATE TRIGGER --------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure upd_trig (ip_objid number,
                      ip_hours2escalate number,
                      ip_prev_case_count number,
                      ip_prev_case_days number,
                      ip_re_open_count number,
                      ip_tat_hours number,
                      op_msg_out out varchar2)
  as
  begin
      update sa.table_x_escalation_speed
      set x_hours2escalate  = ip_hours2escalate,
          x_prev_case_count = ip_prev_case_count,
          x_prev_case_days  = ip_prev_case_days,
          x_re_open_count   = ip_re_open_count,
          x_tat_hours       = ip_tat_hours
      where objid = ip_objid;
    op_msg_out := 'upd_trig - ' || ip_objid;
  exception when others then
    op_msg_out := 'upd_trig - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- DELETE TRIGGER --------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure del_trig (ip_objid number,
                      op_msg_out out varchar2)
  as
  v_default_trig_check number;
  v_ec_id number;
  v_msg_out varchar2(3000);
  begin
      if ip_objid is not null then
      -- IF IT'S A DEFAULT TRIGGER DELETE
      -- THE ASSOCIATED PARENT CONFIGURATION
      select x_star_rank, speed2escalation
      into   v_default_trig_check, v_ec_id
      from   sa.table_x_escalation_speed
      where objid = ip_objid;

      if v_default_trig_check = -1 then
          apex_tktng_app_pkg.del_conf(v_ec_id,v_msg_out);
      end if;

      if instr(v_msg_out,'ORA')>0 then
          op_msg_out := 'del_trig - ' || v_msg_out;
          return;
      end if;

      delete sa.table_x_escalation_speed
      where objid = ip_objid;

      op_msg_out := 'del_trig - ' || ip_objid;
    end if;
  exception when others then
    op_msg_out := 'del_trig - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- CHECK CONFIGURATION ---------------------------------------------------------
--------------------------------------------------------------------------------
  function config_check (ip_h_objid number,
                         ip_p_objid number,
                         ip_carrier_val number,
                         op_ec_objid out number) return boolean
  is
    v_ec_objid number;
  begin
    select distinct ec_objid
    into   v_ec_objid
    from   (select decode(p_objid, '-1',carrier_value,p_objid) p_objid,
                   h_objid,
                   ec_objid
            from   sa.tktng_app_esc_triggers)
    where  h_objid = ip_h_objid
    and    p_objid = decode(ip_p_objid,'-1',ip_carrier_val,ip_p_objid);

    op_ec_objid := v_ec_objid;

    dbms_output.put_line('config_check - true - a configuration exists - ' || op_ec_objid);
    return true;

    exception when others then
    dbms_output.put_line('config_check - false');
    dbms_output.put_line('config_check - a configuration must be created');
    return false;
  end;
--------------------------------------------------------------------------------
-- CREATE CONFIGURATION --------------------------------------------------------
--------------------------------------------------------------------------------
  procedure ins_conf (ip_objid number,
                      ip_hot_transfer number,
                      ip_script_id_hot varchar2,
                      ip_script_id_cold varchar2,
                      ip_script_id_grace varchar2,
                      ip_eval_escalation number,
                      ip_escal2conf_hdr number,
                      ip_from_prty2gbst_elm number,
                      ip_to_prty2gbst_elm number,
                      op_msg_out out varchar2)
  as
  v_ec_objid number;
  begin

    if ip_objid is null then
      -- GET THE CONFIGURATION SEQUENCE
      select sa.seq('x_escalation_conf')
      into   v_ec_objid
      from   dual;
    end if;

    insert into sa.table_x_escalation_conf (objid,
                                            x_hot_transfer,
                                            x_script_id_hot,
                                            x_script_id_cold,
                                            x_script_id_grace,
                                            x_eval_escalation,
                                            escal2conf_hdr,
                                            from_prty2gbst_elm,
                                            to_prty2gbst_elm)
    values (nvl(ip_objid,v_ec_objid),
            nvl(ip_hot_transfer,0),
            nvl(ip_script_id_hot,''),
            nvl(ip_script_id_cold,''),
            nvl(ip_script_id_grace,''),
            nvl(ip_eval_escalation,0),
            ip_escal2conf_hdr,
            ip_from_prty2gbst_elm,
            ip_to_prty2gbst_elm);

    op_msg_out := 'ins_conf - created successfully - ' || v_ec_objid;
  exception when others then
    op_msg_out := 'ins_conf - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- UPDATE CONFIGURATION --------------------------------------------------------
--------------------------------------------------------------------------------
  procedure upd_conf (ip_objid number,
                      ip_hot_transfer number,
                      ip_script_id_hot varchar2,
                      ip_script_id_cold varchar2,
                      ip_script_id_grace varchar2,
                      ip_eval_escalation number,
                      op_msg_out out varchar2)
  as
  begin

    if not apex_tktng_app_pkg.script_exists(ip_script_id_hot) then
        op_msg_out := ip_script_id_hot;
        raise no_data_found;
    elsif not apex_tktng_app_pkg.script_exists(ip_script_id_cold) then
        op_msg_out := ip_script_id_cold;
        raise no_data_found;
    elsif not apex_tktng_app_pkg.script_exists(ip_script_id_grace) then
        op_msg_out := ip_script_id_grace;
        raise no_data_found;
    end if;

    update sa.table_x_escalation_conf
    set x_hot_transfer = ip_hot_transfer,
        x_script_id_hot = ip_script_id_hot,
        x_script_id_cold = ip_script_id_cold,
        x_script_id_grace = ip_script_id_grace,
        x_eval_escalation = ip_eval_escalation
    where objid = ip_objid;

    op_msg_out := 'upd_conf - updated ' || ip_objid || ' successfully';

    exception
      when no_data_found then
        op_msg_out := 'upd_conf - invalid scpt_id - ' || op_msg_out || ' - ' || sqlerrm;
      when others then
        op_msg_out := 'upd_conf - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- DELETE CONFIGURATION --------------------------------------------------------
--------------------------------------------------------------------------------
  procedure del_conf (ip_objid number,
                      op_msg_out out varchar2)
  as
  begin
    if ip_objid is not null then
      delete sa.table_x_escalation_conf
      where objid = ip_objid;
      op_msg_out := 'del_conf - ' || ip_objid || ' successfully';
    end if;
  exception when others then
    op_msg_out := 'del_conf - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- INSERT DISPATCH -------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure ins_disp(ip_hdr_id number,
                     ip_s_id number,
                     ip_p_id number,
                     ip_q_id number,
                     op_msg_out out varchar2)
  as
  v_objid number;
  v_exist_check number;
  begin

    if ip_s_id = -2 then
      op_msg_out := 'Must enter a value for status';
      return;
    end if;

    if ip_p_id = -2 then
      op_msg_out := 'Must enter a value for priority';
      return;
    end if;

    if ip_q_id = -2 then
      op_msg_out := 'Must enter a value for queue';
      return;
    end if;

    -- NEED TO DO AN IF EXISTS SEARCH
    select 1
    into   v_exist_check
    from   sa.table_x_case_dispatch_conf
    where  dispatch2conf_hdr = ip_hdr_id
    and    status2gbst_elm = ip_s_id
    and    priority2gbst_elm = ip_p_id
    and    dispatch2queue = ip_q_id;

    op_msg_out := 'ins_disp - dispatch already exists';

  exception when no_data_found then
    select sa.seq('x_case_dispatch_conf')
    into v_objid
    from dual;
    insert into sa.table_x_case_dispatch_conf (objid,
                                               dispatch2conf_hdr,
                                               status2gbst_elm,
                                               priority2gbst_elm,
                                               dispatch2queue)
    values (v_objid,
            ip_hdr_id,
            ip_s_id,
            ip_p_id,
            ip_q_id);

    op_msg_out := 'ins_disp - created successfully - ' || v_objid;

  when others then
    op_msg_out := 'ins_disp - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- UPDATE DISPATCH -------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure upd_disp(ip_objid number,
                     ip_dispatch2conf_hdr number,
                     ip_status2gbst_elm number,
                     ip_priority2gbst_elm number,
                     ip_dispatch2queue number,
                     op_msg_out out varchar2)
  as
  begin
    update sa.table_x_case_dispatch_conf
    set  dispatch2conf_hdr = ip_dispatch2conf_hdr,
         status2gbst_elm   = ip_status2gbst_elm,
         priority2gbst_elm = ip_priority2gbst_elm,
         dispatch2queue = ip_dispatch2queue
    where  objid = ip_objid;

    op_msg_out := 'upd_disp - ' || ip_objid;

  exception when others then
    op_msg_out := 'upd_disp - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- DELETE DISPATCH -------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure del_disp(ip_objid number,
                     op_msg_out out varchar2)
  as
  begin
    if ip_objid is not null then
      delete sa.table_x_case_dispatch_conf
      where  objid = ip_objid;
      op_msg_out := 'Deleted ' || ip_objid || ' successfully';
    end if;
  exception when others then
    op_msg_out := 'del_disp - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- INSERT SINGLE OR BULK TRIGGERS ----------------------------------------------
--------------------------------------------------------------------------------
  procedure ins_single_or_bulk_trig(ip_hdr_id number,
                                   ip_auto_carrier varchar2,
                                   ip_star_rank varchar2,
                                   ip_priority number,
                                   ip_hours2escalate  number,
                                   ip_prev_case_count  number,
                                   ip_prev_case_days  number,
                                   ip_re_open_count  number,
                                   ip_tat_hours  number,
                                   op_msg_out out varchar2)
  as
    v_auto_carrier varchar2(10);
    v_priority number;
    v_priority_2 number;
    v_star_rank varchar2(10);
    v_star_rank_2 varchar2(10);
    v_ec_objid number;
    v_msg_out varchar2(3000);
    v_msg_out_2 varchar2(3000);

    procedure evaluate_conf_ins_conf_n_trig(p_hdr_id number,
                                            p_from_p_id number,
                                            p_star_rank number,
                                            v_auto_carrier number,
                                            p_hours2escalate number,
                                            p_prev_case_count number,
                                            p_prev_case_days number,
                                            p_re_open_count number,
                                            p_tat_hours number,
                                            v_ec_objid in out number,
                                            op_msg_out out varchar2)
    as
      v_msg_out varchar2(3000);
      v_msg_out_2 varchar2(3000);
    begin

      -- VERIFY CONFIGURATION EXISTS
      if apex_tktng_app_pkg.config_check(p_hdr_id,p_from_p_id,v_auto_carrier, v_ec_objid) then
          -- INSERT TRIGGER
          apex_tktng_app_pkg.ins_trig (p_star_rank,v_auto_carrier,p_hours2escalate,p_prev_case_count,p_prev_case_days,p_re_open_count,p_tat_hours,v_ec_objid,v_msg_out);

      else
        -- GET THE CONFIGURATION SEQUENCE
        select sa.seq('x_escalation_conf')
        into   v_ec_objid
        from   dual;
        -- CREATE DEFAULT CONFIGURATION
        apex_tktng_app_pkg.ins_conf (v_ec_objid,null,null,null,null,null,p_hdr_id,-1,-1,v_msg_out);
        -- INSERT DEFAULT TRIGGER
        apex_tktng_app_pkg.ins_trig(p_star_rank,v_auto_carrier,p_hours2escalate,p_prev_case_count,p_prev_case_days,p_re_open_count,p_tat_hours,v_ec_objid,v_msg_out_2);

      end if;
        op_msg_out := v_msg_out || ' - ' || v_msg_out_2;
    exception when others then
      op_msg_out := 'ins_single_or_bulk_trig - evaluate_conf_ins_conf_n_trig - ' || sqlerrm;
    end;
  begin
     v_priority := ip_priority;
     v_star_rank_2 := ip_star_rank;
     v_auto_carrier := ip_auto_carrier ||',';

       while v_auto_carrier is not null
       loop
           v_star_rank := v_star_rank_2 || ',';
           while v_star_rank is not null
           loop
              for i in (select distinct decode(v_priority,'-2','-1',from_priority) from_priority,
                               decode(v_priority,'-2','-1',p_objid) p_objid,
                               decode(v_priority,'-2','-1',priority_rank) priority_rank
                        from   sa.tktng_app_esc_triggers
                        where  h_objid = ip_hdr_id
                        and    p_objid = decode(v_priority,'-2',p_objid, '-1',p_objid,v_priority)
                        and    p_objid != decode(v_priority,'-2','-1','-1','-1',-3))
                  loop

                  if v_priority = '-2' then
                  v_star_rank := '-1,';
                  end if;

                  if ip_star_rank = '-1' then
                  v_priority_2 := -1;
                  else
                  v_priority_2 := i.p_objid;
                  end if;

                  evaluate_conf_ins_conf_n_trig(ip_hdr_id,
                                                v_priority_2, --i.p_objid,
                                                substr(v_star_rank,1,instr(v_star_rank,',')-1),
                                                substr(v_auto_carrier,1,instr(v_auto_carrier,',')-1),
                                                ip_hours2escalate,
                                                ip_prev_case_count,
                                                ip_prev_case_days,
                                                ip_re_open_count,
                                                ip_tat_hours,
                                                v_ec_objid,
                                                v_msg_out);
                  v_msg_out_2 := v_msg_out_2 ||' - '|| v_msg_out;
                  end loop;
              v_star_rank:= substr(v_star_rank,instr(v_star_rank,',')+1);
          end loop;
          v_star_rank := v_star_rank_2;
          v_auto_carrier:= substr(v_auto_carrier,instr(v_auto_carrier,',')+1);
      end loop;
      -- use to debug
      --op_msg_out := 'ins_single_or_bulk_trig - success ' || substr(v_msg_out_2,1);
      if instr(v_msg_out_2,'ORA')>0 then
      op_msg_out := v_msg_out_2;
      else
      op_msg_out := 'ins_single_or_bulk_trig - success ';
      end if;

      exception when others then
      op_msg_out := 'ins_single_or_bulk_trig - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- UNASSIGN ATTRIBUTE ----------------------------------------------------------
--------------------------------------------------------------------------------
  procedure unassign_att(ip_objid number,
                         op_msg_out out varchar2)
  as
  begin
    delete from sa.table_x_mtm_case_hdr_dtl
    where  objid = ip_objid;
    op_msg_out := 'Deleted ' || ip_objid || ' successfully';
  exception when others then
    op_msg_out := 'del_attribute - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- ASSIGN ATTRIBUTE ------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure assign_att(p_h_objid in number,
                       p_d_objid in number,
                       op_msg_out out varchar2)
  as
    v_exist_check number;
    v_mtm_objid number;
    max_x_order number;
  begin
    -- VERIFY EXISTANCE
    select 1
    into   v_exist_check
    from   table_x_case_conf_hdr hdr,
           table_x_case_conf_dtl dtl,
           table_x_mtm_case_hdr_dtl mtm
    where  1=1
    and    mtm.mtm_conf2conf_hdr = hdr.objid
    and    mtm.mtm_conf2conf_dtl = dtl.objid
    and    hdr.objid = p_h_objid
    and    dtl.objid = p_d_objid;

    op_msg_out := 'ins_att - attribute already assigned';

  exception
    when no_data_found then
    -- PREP THE NEXT INSERT - GET THE MAX NUMBER +1
    select nvl(max(x_order)+1,0)
    into   max_x_order
    from   sa.table_x_mtm_case_hdr_dtl
    where mtm_conf2conf_hdr = p_h_objid;

    -- GET THE NEXT SEQUENCE
    select sa.seq('x_mtm_case_hdr_dtl')
    into   v_mtm_objid
    from dual;

    -- ASSIGN THE ATTRIBUTE
    insert into sa.table_x_mtm_case_hdr_dtl(objid,
                                            dev,
                                            x_mandatory,
                                            x_order,
                                            x_legacy_rule,
                                            x_legacy_name,
                                            x_read_only,
                                            mtm_conf2conf_hdr,
                                            mtm_conf2conf_dtl)
      values (v_mtm_objid,
              '',
              0,
              max_x_order,
              '',
              '',
              0,
              p_h_objid,
              p_d_objid);

    op_msg_out := 'Assigned attribute ' || v_mtm_objid || ' successfully';

    when others then
    op_msg_out := 'ins_att - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- UPDATE ASSIGNED ATTRIBUTE ---------------------------------------------------
--------------------------------------------------------------------------------
  procedure upd_assigned_att (ip_objid number,
                              ip_mandatory number,
                              ip_order number,
                              ip_legacy_rule varchar2,
                              ip_legacy_name varchar2,
                              ip_read_only number,
                              op_msg_out out varchar2)
  as
  begin

      update sa.table_x_mtm_case_hdr_dtl
      set    x_mandatory   = ip_mandatory,
             x_order       = ip_order,
             x_legacy_rule = ip_legacy_rule,
             x_legacy_name = ip_legacy_name,
             x_read_only   = ip_read_only
      where  objid = ip_objid;

    op_msg_out := 'upd_att - updated ' || ip_objid || ' successfully';
  exception when others then
    op_msg_out := 'upd_att - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- CREATE ATTRIBUTE ------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure ins_att(p_objid number,
                    p_prompt varchar2,
                    p_field_name varchar2,
                    p_data_type varchar2,
                    p_format varchar2,
                    p_min_value number,
                    p_max_value number,
                    op_msg_out out varchar2)
  as
  v_objid number;
  begin

    if p_objid is null then
      select sa.seq('x_case_conf_dtl')
      into v_objid
      from dual;
    else
      v_objid := p_objid;
    end if;

    insert into sa.table_x_case_conf_dtl (objid,
                                          x_prompt,
                                          x_field_name,
                                          x_data_type,
                                          x_format,
                                          x_min_value,
                                          x_max_value)
    values (v_objid,
            p_prompt,
            p_field_name,
            p_data_type,
            p_format,
            nvl(p_min_value,0),
            nvl(p_max_value,0));

    op_msg_out:= 'Created '|| p_prompt || ' successfully';

  exception when others then
      op_msg_out:= 'ins_att - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- UPDATE ATTRIBUTE ------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure upd_att(p_objid number,
                    p_prompt varchar2,
                    p_field_name varchar2,
                    p_data_type varchar2,
                    p_format varchar2,
                    p_min_value number,
                    p_max_value number,
                    op_msg_out out varchar2)
  as
  begin

    update sa.table_x_case_conf_dtl
    set    x_prompt     = p_prompt,
           x_field_name = p_field_name,
           x_data_type  = p_data_type,
           x_format     = p_format,
           x_min_value  = nvl(p_min_value,0),
           x_max_value  = nvl(p_max_value,0)
    where  objid = p_objid;

    op_msg_out:= 'Update '||p_prompt||' success';

  exception when others then
      op_msg_out:= 'ins_att - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- DELETE ATTRIBUTE ------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure del_att(p_objid number,
                    op_msg_out out varchar2)
  as
  begin

    delete sa.table_x_case_conf_dtl
    where  objid = p_objid;

    op_msg_out:= 'delete successful ';

  exception when others then
    op_msg_out:= 'del_att - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- ASSIGN WAREHOUSE INTEGRATION ------------------------------------------------
--------------------------------------------------------------------------------
  procedure assign_int(p_objid number,
                       p_status varchar2,
                       p_action varchar2,
                       p_active number,
                       p_h_id number,
                       op_msg_out out varchar2)
  as
  v_objid number;
  begin

    if p_objid is null then
      select sa.seq('x_case_conf_int')
      into v_objid
      from dual;
    else
      v_objid := p_objid;
    end if;

    if p_status = '-1' then
      op_msg_out:= 'Need to Enter a Status';
      return;
    end if;

    if p_action = '-1' then
      op_msg_out:= 'Need to Enter an Action';
      return;
    end if;

    insert into sa.table_x_case_conf_int (objid,
                                          x_status,
                                          x_action,
                                          x_active,
                                          conf_int2conf_hdr)
    values (v_objid,
            p_status,
            p_action,
            p_active,
            p_h_id);

    op_msg_out:= 'Assigned ' || p_status || ' success';

  exception when others then
    op_msg_out:= 'assign_int - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- UNASSIGN WAREHOUSE INTEGRATION ----------------------------------------------
--------------------------------------------------------------------------------
  procedure unassign_int(p_objid number,
                         op_msg_out out varchar2)
  as
  begin

    delete sa.table_x_case_conf_int
    where  objid = p_objid;

    op_msg_out:= 'Removed ' || p_objid || ' success';

  exception when others then
    op_msg_out:= 'unassign_int - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- CREATE CONFIGURATION HEADER -------------------------------------------------
--------------------------------------------------------------------------------
  procedure ins_conf_hdr (ip_objid number,
                          ip_display_title varchar2,
                          ip_case_type varchar2,
                          ip_title varchar2,
                          ip_service number,
                          ip_avail_lhs_menu number,
                          ip_block_reopen number,
                          ip_reopen_days_check number,
                          ip_warehouse number,
                          ip_exch_type varchar2,
                          ip_required_return number,
                          ip_weight varchar2,
                          ip_instruct_type number,
                          ip_instruct_code varchar2,
                          ip_q_objid number,
                          op_msg_out out varchar2)
  as
  v_h_objid number;
  v_d_objid number;
  v_out_msg varchar2(3000);
  begin

    if ip_objid is null then
      -- GET THE NEXT SEQUENCE
      select sa.seq('x_case_conf_hdr')
      into v_h_objid
      from dual;
    else
      v_h_objid := ip_objid;
    end if;

      -- CREATE THE HEADER
      insert into sa.table_x_case_conf_hdr x_display_title (objid,
                                                            x_display_title,
                                                            x_case_type,
                                                            s_x_case_type,
                                                            x_title,
                                                            s_x_title,
                                                            x_service,
                                                            x_avail_lhs_menu,
                                                            x_block_reopen,
                                                            x_reopen_days_check,
                                                            x_warehouse,
                                                            x_exch_type,
                                                            x_required_return,
                                                            x_weight,
                                                            x_instruct_type,
                                                            x_instruct_code)
      values (v_h_objid,
              ip_display_title,
              ip_case_type,
              upper(ip_case_type),
              ip_title,
              upper(ip_title),
              ip_service,
              ip_avail_lhs_menu,
              ip_block_reopen,
              ip_reopen_days_check,
              ip_warehouse,
              ip_exch_type,
              ip_required_return,
              ip_weight,
              ip_instruct_type,
              ip_instruct_code);

      -- CREATE DEFAULT QUEUE
      ins_disp(v_h_objid,
               -1,
               -1,
               ip_q_objid,
               v_out_msg);

    if instr(v_out_msg,'ORA') > 0 then
      op_msg_out := 'ins_conf_hdr - ' || v_out_msg;
      rollback;
      return;
    else
      op_msg_out := 'ins_conf_hdr - Created ' || ip_display_title;
    end if;

  exception when others then
    dbms_output.put_line('ins_conf_hdr - ' || sqlerrm);
  end;
--------------------------------------------------------------------------------
-- UPDATE CONFIGURATION HEADER -------------------------------------------------
--------------------------------------------------------------------------------
  procedure upd_conf_hdr (ip_objid number,
                          ip_display_title varchar2,
                          ip_case_type varchar2,
                          ip_title varchar2,
                          ip_service number,
                          ip_avail_lhs_menu number,
                          ip_block_reopen number,
                          ip_reopen_days_check number,
                          ip_warehouse number,
                          ip_exch_type varchar2,
                          ip_required_return number,
                          ip_weight varchar2,
                          ip_instruct_type number,
                          ip_instruct_code varchar2,
                          ip_default_queue number,
                          op_msg_out out varchar2)
  as
  v_d_objid number;
  v_out_msg varchar2(3000);
  begin
      update sa.table_x_case_conf_hdr
        set    x_display_title        = nvl(ip_display_title,x_display_title),
               x_case_type            = nvl(ip_case_type,x_case_type),
               x_title                = nvl(ip_title,x_title),
               x_service              = ip_service,
               x_avail_lhs_menu       = ip_avail_lhs_menu,
               x_block_reopen         = ip_block_reopen,
               x_reopen_days_check    = ip_reopen_days_check,
               x_warehouse            = ip_warehouse,
               x_exch_type            = ip_exch_type,
               x_required_return      = ip_required_return,
               x_weight               = ip_weight,
               x_instruct_type        = decode(ip_instruct_type,'-1',null,ip_instruct_type),
               x_instruct_code        = ip_instruct_code
        where objid = ip_objid;

        if ip_default_queue is not null then
            begin
            -- FIND THE DEFAULT QUEUE
            select objid
            into   v_d_objid
            from   sa.table_x_case_dispatch_conf
            where  dispatch2conf_hdr = ip_objid
            and    status2gbst_elm  = -1
            and    priority2gbst_elm = -1;

            -- IF IT DOESN'T EXIST CREATE IT
            upd_disp(v_d_objid,
                     ip_objid,
                     -1,
                     -1,
                     ip_default_queue,
                     v_out_msg);
            exception when others then
            -- CREATE DEFAULT
            ins_disp(ip_objid,
                     -1,
                     -1,
                     ip_default_queue,
                     v_out_msg);
            end;
        end if;

    if instr(v_out_msg,'ORA')>0 then
        op_msg_out := v_out_msg;
    else
        op_msg_out := 'upd_conf_hdr - update sucessful';
    end if;

  exception when others then
    op_msg_out := 'upd_conf_hdr - ' || sqlerrm;
  end;
--------------------------------------------------------------------------------
-- VERIFY SCRIPT_ID ------------------------------------------------------------
--------------------------------------------------------------------------------
  function script_exists (p_scpt_id varchar2) return boolean
  as
  p varchar2(30);
  stmt varchar2(3000);
  begin
    if p_scpt_id is not null then
        select count(*)
        into   p
        from   table_x_scripts
        where  x_script_type || '_' || x_script_id = p_scpt_id;

        if p = 0 then
          return false;
        else
          return true;
        end if;
    else
      return true;
    end if;
  end;
--------------------------------------------------------------------------------
-- END PACKAGE -----------------------------------------------------------------
--------------------------------------------------------------------------------
end apex_tktng_app_pkg;
/