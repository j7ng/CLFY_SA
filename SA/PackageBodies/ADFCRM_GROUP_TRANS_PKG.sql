CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_GROUP_TRANS_PKG"
is
  function insert_group_temp(ipv_group_name varchar2,
                             ipv_group_id varchar2,
                             ipv_transaction_type varchar2,
                             ipv_web_user_objid varchar2,
                             ipv_contact_objid varchar2,
                             ipv_esn varchar2,
                             ipv_sim varchar2,
                             ipv_pin varchar2,
                             ipv_zipcode varchar2,
                             ipv_service_plan_id varchar2,
                             ipv_priority varchar2,
                             ipv_brand_name varchar2,
                             ipv_insert_date varchar2,
                             ipv_status varchar2,
                             ipv_update_date varchar2,
                             ipv_agent_name varchar2,
                             ipv_port_current_esn varchar2,
                             ipv_port_type varchar2,
                             ipv_port_service_provider varchar2,
                             ipv_port_current_brand varchar2,
                             ipv_port_account_number varchar2,
                             ipv_port_password_pin varchar2,
                             ipv_port_first_name varchar2,
                             ipv_port_last_name varchar2,
                             ipv_port_min varchar2,
                             ipv_port_last_4_ssn varchar2,
                             ipv_port_address varchar2,
                             ipv_port_city varchar2,
                             ipv_port_state varchar2,
                             ipv_port_zipcode varchar2,
                             ipv_port_country varchar2,
                             ipv_port_phone varchar2,
                             ipv_port_email varchar2,
                             ipv_case_id varchar2,
                             ipv_case_objid varchar2,
                             ipv_byop_lte_req_exchg_pn varchar2)
  return varchar2
  as
  begin

    if ipv_esn is not null and ipv_group_id is not null then

      delete from adfcrm_group_transaction_temp
      where esn = ipv_esn
      and group_id = ipv_group_id;

      insert into adfcrm_group_transaction_temp
        (objid,
         group_name,
         group_id,
         transaction_type,
         web_user_objid,
         contact_objid,
         esn,
         sim,
         pin,
         zipcode,
         service_plan_id,
         priority,
         brand_name,
         insert_date,
         status,
         update_date,
         agent_name,
         port_current_esn,
         port_type,
         port_service_provider,
         port_current_brand,
         port_account_number,
         port_password_pin,
         port_first_name,
         port_last_name,
         port_min,
         port_last_4_ssn,
         port_address,
         port_city,
         port_state,
         port_zipcode,
         port_country,
         port_phone,
         port_email,
         case_id,
         case_objid,
         exchange_partnumber)
      values
        (sa.seq_adfcrm_group_trans_temp.nextval,
         ipv_group_name,
         ipv_group_id,
         ipv_transaction_type,
         ipv_web_user_objid,
         ipv_contact_objid,
         ipv_esn,
         ipv_sim,
         ipv_pin,
         ipv_zipcode,
         ipv_service_plan_id,
         ipv_priority,
         ipv_brand_name,
         sysdate, --ipv_insert_date,
         ipv_status,
         sysdate, --ipv_update_date,
         ipv_agent_name,
         ipv_port_current_esn,
         ipv_port_type,
         ipv_port_service_provider,
         ipv_port_current_brand,
         ipv_port_account_number,
         ipv_port_password_pin,
         ipv_port_first_name,
         ipv_port_last_name,
         ipv_port_min,
         ipv_port_last_4_ssn,
         ipv_port_address,
         ipv_port_city,
         ipv_port_state,
         ipv_port_zipcode,
         ipv_port_country,
         ipv_port_phone,
         ipv_port_email,
         ipv_case_id,
         ipv_case_objid,
         ipv_byop_lte_req_exchg_pn);


      IF SQL%ROWCOUNT > 0 THEN
        commit;
        return 'SUCCESS';
      else
        return 'NOTHING INSERTED';
      end if;

    else
        return 'NOTHING INSERTED';
    end if;

  exception
    when others then
      return 'ERROR: '||sqlerrm;
  end insert_group_temp;

  function change_group_status(ipv_objid varchar2, ipv_status varchar2)
  return varchar2
  as
  begin
    update adfcrm_group_transaction_temp
    set    status = ipv_status
    where  objid = ipv_objid;

    commit;
    return 'SUCCESS';
  exception
    when others then
      return 'FAILED';
  end change_group_status;

  function get_group_id(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2
  as
    v_group_id varchar2(30) := '-1';
  begin
    if ip_search_type is null then
      v_group_id := 'SEARCH_TYPE_IS_EMPTY';
    end if;

    if ip_search_value is null then
      v_group_id := 'SEARCH_VALUE_IS_EMPTY';
    end if;

    -- IF THE ESN IS ENTERED
    if ip_search_type = 'ESN' and ip_search_value is not null  then
      begin
        select account_group_id
        into   v_group_id
        from   x_account_group_member m
        where  1=1
        and    m.esn = ip_search_value
        and    m.status != 'EXPIRED';
      exception
        when others then
          null;
      end;
    end if;
    return v_group_id;
  end get_group_id;

  function get_group_nn(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2
  as
    v_group_nn varchar2(30) := null;
    group_id varchar2(30);
  begin
    if ip_search_type is null then
      v_group_nn := 'SEARCH_TYPE_IS_EMPTY';
    end if;

    if ip_search_value is null then
      v_group_nn := 'SEARCH_VALUE_IS_EMPTY';
    end if;

    if ip_search_type = 'ESN' then
      group_id := sa.adfcrm_group_trans_pkg.get_group_id(ip_search_type => ip_search_type, ip_search_value =>ip_search_value);
    end if;

    if ip_search_type = 'GROUP_ID'  then
      group_id := ip_search_value;
    end if;


    if group_id = '-1' then
      return null;
    elsif ip_search_type in ('ESN','GROUP_ID') then
      begin
        select a.account_group_name
        into   v_group_nn
        from  x_account_group a
        where 1=1
        and  a.objid = group_id;
      exception
        when others then
          null;
      end;
    else
      v_group_nn := 'MUST_BE_ESN_OR_GROUP_ID';
    end if;

    return v_group_nn;
  end get_group_nn;

  function get_service_plan(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2
  as
    v_service_plan varchar2(30) := null;
    group_id varchar2(30);
  begin
    -- THIS WILL WORK FOR EITHER A GROUP OR A REGULAR ESN
    if ip_search_type is null then
      v_service_plan := 'SEARCH_TYPE_IS_EMPTY';
    end if;

    if ip_search_value is null then
      v_service_plan := 'SEARCH_VALUE_IS_EMPTY';
    end if;

    if ip_search_type = 'ESN' then
      group_id := sa.adfcrm_group_trans_pkg.get_group_id(ip_search_type => ip_search_type, ip_search_value =>ip_search_value);
    end if;

    if ip_search_type = 'GROUP_ID'  then
      group_id := ip_search_value;
    end if;

    if group_id = '-1' then
        return null;
    elsif ip_search_type in ('ESN','GROUP_ID') then
      begin
        select a.service_plan_id
        into   v_service_plan
        from  x_account_group a
        where 1=1
        and  a.objid = group_id;
      exception
        when others then
          null;
      end;
    else
      v_service_plan := 'MUST_BE_ESN_OR_GROUP_ID';
    end if;

    return v_service_plan;
  end get_service_plan;

  function get_group_status(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2
  as
    v_group_status varchar2(30) := 'NOT_FOUND';
    group_id varchar2(30);
  begin
    if ip_search_type is null then
      v_group_status := 'SEARCH_TYPE_IS_EMPTY';
    end if;

    if ip_search_value is null then
      v_group_status := 'SEARCH_VALUE_IS_EMPTY';
    end if;

    if ip_search_type = 'ESN' then
      group_id := sa.adfcrm_group_trans_pkg.get_group_id(ip_search_type => ip_search_type, ip_search_value =>ip_search_value);
    end if;

    if ip_search_type = 'GROUP_ID'  then
      group_id := ip_search_value;
    end if;

    if group_id = '-1' then
      return null;
    elsif ip_search_type in ('ESN','GROUP_ID') then
      begin
        select a.status
        into   v_group_status
        from  x_account_group a
        where 1=1
        and  a.objid = group_id;
      exception
        when others then
          null;
      end;
    else
      v_group_status := 'MUST_BE_ESN_OR_GROUP_ID';
    end if;

    return v_group_status;
  end get_group_status;

  function get_total_devices(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2
  as
    v_total_devices varchar2(30) := 'NOT_FOUND';
    dc varchar2(30);
  begin
    if ip_search_type is null then
      v_total_devices := 'SEARCH_TYPE_IS_EMPTY';
    end if;

    if ip_search_value is null then
      v_total_devices := 'SEARCH_VALUE_IS_EMPTY';
    end if;

    if ip_search_type = 'ESN' then
      dc := sa.adfcrm_group_trans_pkg.get_group_id(ip_search_type => ip_search_type, ip_search_value =>ip_search_value);
    end if;

    if ip_search_type = 'GROUP_ID'  then
      dc := ip_search_value;
    end if;

    if dc = '-1' then
      return null;
    elsif ip_search_type in ('ESN','GROUP_ID') then
      select count(*)
      into   v_total_devices
      from   x_account_group_member m,
             x_account_group a
      where 1=1
      and  a.objid = m.account_group_id
      and  a.objid = dc;
    else
      v_total_devices := 'MUST_BE_ESN_OR_GROUP_ID';
    end if;

    return v_total_devices;
  exception
    when others then
      return 'GROUP_ID_MUST_BE_A_NUMBER';
  end get_total_devices;

  function get_master_esn(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2
  as
    v_master_esn varchar2(30) := null;
    group_id varchar2(30);
  begin
    if ip_search_type is null then
      v_master_esn := 'SEARCH_TYPE_IS_EMPTY';
    end if;

    if ip_search_value is null then
      v_master_esn := 'SEARCH_VALUE_IS_EMPTY';
    end if;

    if ip_search_type = 'ESN' then
      group_id := sa.adfcrm_group_trans_pkg.get_group_id(ip_search_type => ip_search_type, ip_search_value =>ip_search_value);
    end if;

    if ip_search_type = 'GROUP_ID'  then
      group_id := ip_search_value;
    end if;

    begin
      select esn
      into   v_master_esn
      from   x_account_group_member m
      where  1=1
      and    m.account_group_id = group_id
      and    m.master_flag = 'Y'
      and    m.status != 'EXPIRED';
    exception
      when others then
        if ip_search_type = 'ESN' then
          return ip_search_value;
        else
          return null;
        end if;
    end;

    return v_master_esn;
  end get_master_esn;

  function get_projected_end_date(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2
  as
    group_id varchar2(30);
    master_esn varchar2(30);
    v_projected_end_date date;
  begin
    if ip_search_value is null then
      return 'SEARCH_VALUE_IS_EMPTY';
    end if;

    if ip_search_type = 'ESN' then
      group_id := sa.adfcrm_group_trans_pkg.get_group_id(ip_search_type => ip_search_type, ip_search_value =>ip_search_value);
    end if;

    if ip_search_type = 'GROUP_ID' then
      group_id := ip_search_value;
    end if;

    -- IF IT BELONGS TO A GROUP GET THE MASTER ESN INFO
    if instr(group_id,'-1') > 0 and ip_search_type != 'GROUP_ID' then
      master_esn := ip_search_value;
    else
      master_esn := sa.adfcrm_group_trans_pkg.get_master_esn(ip_search_type =>'GROUP_ID', ip_search_value => group_id);
    end if;

--          if ip_search_type = 'ESN' then
--            dbms_output.put_line('source =================> ' ||ip_search_value);
--          else
--            dbms_output.put_line('source =================> ' ||group_id);
--          end if;
--            dbms_output.put_line('master_esn =============> '||master_esn||chr(10));

    select pi.warr_end_date+nvl((select sum (pnc.x_redeem_days)
                             from table_part_num pnc,table_mod_level mlc,table_part_inst pic
                             where pic.part_to_esn2part_inst =pi.objid
                             and pic.n_part_inst2part_mod = mlc.objid
                             and pnc.domain ='REDEMPTION CARDS'
                             and pic.x_part_inst_status = '400'
                             and mlc.part_info2part_num = pnc.objid),0) projected_end_date
    into v_projected_end_date
    from table_part_inst pi
    where pi.part_serial_no = master_esn;

    return v_projected_end_date;
  end get_projected_end_date;

  function get_cards_in_queue(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2
  as
    group_id varchar2(30);
    master_esn varchar2(30);
    v_cards_in_queue varchar2(30) := 'NOT_FOUND';
  begin
    if ip_search_value is null then
      v_cards_in_queue := 'SEARCH_VALUE_IS_EMPTY';
    end if;

    if ip_search_type = 'ESN' then
      group_id := sa.adfcrm_group_trans_pkg.get_group_id(ip_search_type => ip_search_type, ip_search_value =>ip_search_value);
    end if;

    if ip_search_type = 'GROUP_ID' then
      group_id := ip_search_value;
    end if;

    -- IF IT BELONGS TO A GROUP GET THE MASTER ESN INFO
    if instr(group_id,'-1') > 0 and ip_search_type != 'GROUP_ID' then
      master_esn := ip_search_value;
    else
      master_esn := sa.adfcrm_group_trans_pkg.get_master_esn(ip_search_type =>'GROUP_ID', ip_search_value => group_id);
    end if;

    select count(1)
    into v_cards_in_queue
    from table_part_inst
    where x_part_inst_status = '400'
    and x_domain = 'REDEMPTION CARDS'
    and part_to_esn2part_inst in (select objid
                                  from table_part_inst pi
                                  where pi.part_serial_no = master_esn);


    return v_cards_in_queue;
  end get_cards_in_queue;

  function get_expire_date(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2
  as
    group_id varchar2(30);
    master_esn varchar2(30);
    v_expire_dt date;
  begin

    if ip_search_type = 'ESN' then
      group_id := sa.adfcrm_group_trans_pkg.get_group_id(ip_search_type => ip_search_type, ip_search_value =>ip_search_value);
    end if;

    if ip_search_type = 'GROUP_ID' then
      group_id := ip_search_value;
    end if;

    -- IF IT BELONGS TO A GROUP GET THE MASTER ESN INFO
    if instr(group_id,'-1') > 0 and ip_search_type != 'GROUP_ID' then
      master_esn := ip_search_value;
    else
      master_esn := sa.adfcrm_group_trans_pkg.get_master_esn(ip_search_type =>'GROUP_ID', ip_search_value => group_id);
    end if;

    select x_expire_dt
    into   v_expire_dt
    from   table_site_part s,
           table_part_inst p
    where  s.objid = p.x_part_inst2site_part
    and    p.part_serial_no = master_esn;


    return v_expire_dt;
  exception
    when others then
      return null;
  end get_expire_date;

  procedure get_program_info(p_esn varchar2,
                             p_service_plan_objid out varchar2,
                             p_service_type out varchar2,
                             p_program_type out varchar2,
                             p_next_charge_date out date,
                             p_program_units out number,
                             p_program_days out number,
                             p_rate_plan out varchar2,
                             p_x_prg_script_id out varchar2,
                             p_x_prg_desc_script_id out varchar2,
                             p_error_num out number)
  is
    group_id varchar2(30);
    master_esn varchar2(30);
  begin
    ----------------------------------------------------------------------------
    -- THIS IS REGARDING THE FOLLOWING VALUES WHICH COME FROM PROGRAM ENROLLMENTS
    -- AT THE MOMENT ENROLLMENTS GET MARRIED TO THE MASTER ESN'S IF IT'S IN A GROUP
    -- IF NO MATER ESN IS FOUND, THEN USE THE ESN PROVIDED.
    -- PROGRAM ENROLLMENT RELATED TABLES (x_program_parameters,x_program_enrolled,x_program_parameters)
    -- RELATED TABLES: P_PROGRAM_TYPE,P_NEXT_CHARGE_DATE,P_PROGRAM_UNITS,P_PROGRAM_DAYS
    ----------------------------------------------------------------------------
    master_esn := adfcrm_group_trans_pkg.get_master_esn(ip_search_type =>'ESN', ip_search_value =>p_esn);

    if master_esn is null then
      master_esn := p_esn;
    end if;

    phone_pkg.get_program_info (p_esn => master_esn,
                                p_service_plan_objid => p_service_plan_objid,
                                p_service_type => p_service_type,
                                p_program_type => p_program_type,
                                p_next_charge_date => p_next_charge_date,
                                p_program_units => p_program_units,
                                p_program_days => p_program_days,
                                p_rate_plan => p_rate_plan,
                                p_x_prg_script_id => p_x_prg_script_id,
                                p_x_prg_desc_script_id => p_x_prg_desc_script_id,
                                p_error_num => p_error_num);

  end get_program_info;

  function pre_act_member_removal (p_esn varchar2, p_group_id varchar2) return varchar2 as

  begin

    delete from sa.x_account_group_member
    where esn = p_esn
    and account_group_id = p_group_id
    and status = 'PENDING_ENROLLMENT';

    commit;

    return 'SUCCESS';

    exception when others then
      return 'ERROR: '||sqlerrm;

  end;

  procedure get_group_info(ip_esn in varchar2,
                           op_account_group_id out varchar2,
                           op_account_group_name out varchar2,
                           op_status out varchar2,
                           op_count out varchar2)
  as
  begin

    select m.account_group_id,a.account_group_name, a.status, count(m.esn) cnt
    into   op_account_group_id, op_account_group_name, op_status,op_count
    from   x_account_group_member m,
           x_account_group a
    where 1=1
    and  m.status != 'EXPIRED'
    and  a.objid = m.account_group_id
    and  a.objid = sa.adfcrm_group_trans_pkg.get_group_id(ip_search_type => 'ESN', ip_search_value => ip_esn)
    group by m.account_group_id, a.account_group_name, a.status;
  exception
    when others then
      op_account_group_id := '-1';
  end get_group_info;

  function pre_act_archiving (p_group_id varchar2) return varchar2 as

  begin

     if p_group_id is not null then
       update adfcrm_group_transaction_temp
       set status = 'ARCHIVED'
       where group_id = p_group_id
       and status = 'SUBMITTED';

       commit;

     end if;
     return 'SUCCESS';

     exception
        when others then null;
           return 'FAILED';
  end;

  FUNCTION delete_member_from_grp_if_req(
    ip_esn IN VARCHAR2)
  RETURN VARCHAR2
AS

  CURSOR curESNInfo
  IS
    SELECT table_bus_org.org_id,
      pi.x_part_inst_status esnStatus,
      (SELECT COUNT('1')
      FROM sa.table_part_inst l
      WHERE l.part_to_esn2part_inst = pi.objid
      AND l.x_domain                = 'LINES'
      AND l.x_part_inst_status     IN ('37','38','39')
      ) reserved_lines,
    sa.CUSTOMER_INFO.get_service_forecast_due_date (ip_esn) esnDueDate,
    pi.X_DOMAIN
  FROM sa.table_part_inst pi,
    sa.table_mod_level,
    sa.table_part_num,
    sa.table_bus_org
  WHERE part_serial_no                   = NVL(ip_esn,'N/A')
  AND x_domain                           = 'PHONES'
  AND X_PART_INST2CONTACT               IS NOT NULL
  AND pi.n_part_inst2part_mod            =table_mod_level.objid
  AND table_mod_level.part_info2part_num =table_part_num.objid
  AND table_part_num.part_num2bus_org    = table_bus_org.objid;

  recESNInfo curESNInfo%rowtype;

  CURSOR curESNGroupInfo
  IS
    SELECT m.ACCOUNT_GROUP_ID groupId,
      m.STATUS memberStatus,
      m.MASTER_FLAG IsMaster,
      m.ESN,
      m.OBJID groupMemberId
    FROM x_account_group_member m
    WHERE esn=ip_esn;

  recESNGroupInfo curESNGroupInfo%rowtype;

  isLinePASTDUE     BOOLEAN;
  isNoReservedLines BOOLEAN;
  isDueDateInPast   BOOLEAN;
  isGroupMember     BOOLEAN;
  groupId           VARCHAR2(20);
  groupMemberId     VARCHAR2(20);
  op_err_code       NUMBER;
  op_err_msg        VARCHAR2(100);
  op_lease_flag varchar2(10);
  temp_esn varchar2(100)  := ip_esn;

BEGIN
  isLinePASTDUE     := false;
  isNoReservedLines := false;
  isDueDateInPast   := false;
  isGroupMember     := false;

  OPEN curESNInfo;
  FETCH curESNInfo INTO recESNInfo;
  IF curESNInfo%found THEN
    IF recESNInfo.esnStatus IN ('51','54') THEN
      isLinePASTDUE := true;
    END IF;
    IF recESNInfo.reserved_lines =0 THEN
      isNoReservedLines         := true;
    END IF;
    IF recESNInfo.esnDueDate < sysdate THEN
      isDueDateInPast       := true;
    END IF;
  END IF;
  CLOSE curESNInfo;

  OPEN curESNGroupInfo;
  FETCH curESNGroupInfo INTO recESNGroupInfo;
  IF curESNGroupInfo%found THEN
    IF recESNGroupInfo.IsMaster = 'N' THEN
      isGroupMember            := true;
      groupMemberId            := recESNGroupInfo.groupMemberId;
      groupId                  := recESNGroupInfo.groupId;
    END IF;
  END IF;
  close curESNGroupInfo;

  IF(isLinePASTDUE AND isNoReservedLines AND isDueDateInPast AND isGroupMember) THEN
    sa.customer_lease_scoring_pkg.get_esn_leased_flag ( ip_esn, op_lease_flag);
    IF(op_lease_flag IS NULL OR op_lease_flag != 'Y') THEN
      --remove the esn from the group to inactive group
      sa.BRAND_X_PKG.DELETE_MEMBER(groupId,temp_esn, groupMemberId,op_err_code, op_err_msg);
	  commit;
    END IF;
  END IF;
  return op_err_msg;
END delete_member_from_grp_if_req;

end adfcrm_group_trans_pkg;
/