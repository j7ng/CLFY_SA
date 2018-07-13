CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_INTERNAL" is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_INTERNAL_PKB.sql,v $
--$Revision: 1.35 $
--$Author: mmunoz $
--$Date: 2018/04/30 15:52:29 $
--$ $Log: ADFCRM_INTERNAL_PKB.sql,v $
--$ Revision 1.35  2018/04/30 15:52:29  mmunoz
--$ CR57806 TAS Reactivation with reserved line in Redemption flow
--$
--$ Revision 1.34  2018/02/14 16:16:25  mbyrapaneni
--$ SMMLD_TAS_02: SM pastdue phone to land in activation flow.
--$
--$ Revision 1.32  2018/02/02 15:25:49  syenduri
--$ REL946-Corrected match condition in merge query to insert record in adfcrm_activity_log
--$
--$ Revision 1.30  2018/01/08 19:44:52  syenduri
--$ CR55055 Add Logic to NewCCAddedFlag in TAS Summary Report
--$
--$ Revision 1.29  2017/11/30 23:07:24  pkapaganty
--$ CR51692 TAS Reactivations of ESNs status Past Due
--$
--$ Revision 1.28  2017/11/28 17:47:42  pkapaganty
--$ CR51692 - Enabled default tab to Redemption when ESN status is ACTIVE or PASTDUE and no reserved lines for TW and SM
--$
--$ Revision 1.27  2017/11/27 22:57:31  pkapaganty
--$ CR51692 - Enabled default tab to Redemption when ESN status is USED and no reserved lines
--$
--$ Revision 1.26  2017/11/24 22:59:22  syenduri
--$ Added 150 status with line reserved navigate to Activation flow
--$
--$ Revision 1.25  2017/11/09 22:38:28  nguada
--$ REL932
--$
--$ Revision 1.24  2017/11/07 20:24:42  nguada
--$
--$ CR53019
--$
--$ Revision 1.23  2017/11/03 18:26:27  nguada
--$ CR53019
--$
--$ Revision 1.22  2017/10/12 21:38:16  syenduri
--$ CR52737 - Added Source System as TAS in adfcrm_activity_log
--$
--$ Revision 1.21  2017/08/23 16:04:47  mmunoz
--$ CR50120 Record Solutions Configuration Table Updates
--$
--$ Revision 1.20  2017/08/09 16:40:13  mmunoz
--$ CR52932 Updated write_log to add flow description in check for unique logs every 5 mins
--$
--$ Revision 1.19  2015/11/10 23:00:05  mmunoz
--$ CR38663 function unreserved_lines_from_esn, added CarrierPending status
--$
--$ Revision 1.18  2015/11/10 19:59:29  mmunoz
--$ CR38663 New function unreserved_lines_from_esn
--$
--$ Revision 1.17  2015/10/09 14:45:08  mmunoz
--$ Apollo new function get_part_class
--$
--$ Revision 1.16  2015/03/12 13:00:15  mmunoz
--$ function task_flow_id  handling exception invalid_number
--$
--$ Revision 1.15  2015/02/13 21:42:43  hcampano
--$ TAS_2015_05 - Added function to determine if the esn is a home_center. This is temporary location. it should be moved to device util.
--$
--$ Revision 1.14  2015/02/13 20:16:23  nguada
--$ merge
--$
--$ Revision 1.12  2015/02/03 21:59:55  hcampano
--$ TAS_2015_05 - CR30702 - TAS Activity Log Improvements
--$
--$ Revision 1.11  2015/02/03 16:05:08  hcampano
--$ TAS_2015_05 - CR30702 - TAS Activity Log Improvements
--$
--$ Revision 1.10  2015/02/02 20:53:42  hcampano
--$ TAS_2015_05 - CR30702 - TAS Activity Log Improvements
--$
--$ Revision 1.9  2015/02/02 20:34:27  hcampano
--$ TAS_2015_05 - CR30702 - TAS Activity Log Improvements
--$
--$ Revision 1.8  2014/10/27 15:51:36  mmunoz
--$ Updated procedure address
--$
--$ Revision 1.7  2014/07/18 12:14:44  hcampano
--$ 7/2014 TAS release (TAS_2014_06) Tas Reporting Requirements. CR29370
--------------------------------------------------------------------------------------------
  function change_password (ip_login_name in varchar2,
                                   ip_password   in varchar2,
                                   ip_new_password_1 in varchar2,
                                   ip_new_password_2 in varchar2) return varchar2
  is
    cursor c1
    is
      select *
      from table_user
      where s_login_name = upper(ip_login_name)
      and web_password   = sa.encryptpassword(ip_password)
      and status         = 1; --Active

    r1 c1%rowtype;

    op_message varchar2(200);
    op_result boolean;

  begin
    open c1;
    fetch c1 into r1;
    if c1%notfound then
      close c1;
      return 'ERROR: User/Password Invalid or Inactive';
    else
      close c1;
    end if;

    if ip_new_password_1 is null then
      return 'ERROR: New Password is required';
    end if;

    if ip_new_password_2 is null then
      return 'ERROR: New Password Re-Entry is required';
    end if;

    if ip_new_password_1<>ip_new_password_2 then
      return 'ERROR: New Password entries do not match';
    end if;

    sa.apex_crm_pkg.password_verify_function(
      username => ip_login_name,
      password => ip_new_password_1,
      op_result => op_result,
      op_message => op_message
    );

    if op_result then
     update table_user
     set web_password = encryptpassword(ip_new_password_1),
         web_passwd_chg=sysdate,
         dev = 1,
         submitter_ind = 0
     where s_login_name = upper(ip_login_name);

     insert into table_x_password_hist (objid,dev,x_password_hist,
     x_password_chg,x_login_name,s_x_login_name) values (
     sa.seq('x_password_hist'),0,encryptpassword(ip_new_password_1),
     sysdate,(select login_name from table_user
     where s_login_name =upper(ip_login_name)),ip_login_name);
     commit;
     return 'OK: Password Updated';

    else
     return 'ERROR: '||op_message;
    end if;

  end change_password;
--------------------------------------------------------------------------------------------
  function func_ins_sol_model (ip_sol_id sa.adfcrm_solution.solution_id%type,
                               ip_mode   varchar2,
                               ip_login_name varchar2)   --Clean
  return number
  is
  ---------------------------------------------------------
  -- This function insert into SA.ADFCRM_SOLUTION_MODELS --
  -- part classes which have all parameter and values    --
  -- defined in a solution and return the number of      --
  -- record inserted                                     --
  ---------------------------------------------------------
    v_cnt_sq  number;
    v_result  number;
  begin
    if ip_sol_id is null then
       return 0;
    end if;
    if ip_mode = 'Clean' then
      delete from sa.adfcrm_solution_models
      where  solution_id = ip_sol_id;
    end if;
    -- Get the amount of parameters defined for the solution
    begin
      select count(distinct class_param_name) cnt_sq
      into   v_cnt_sq
      from sa.adfcrm_solution_qualification
      where solution_id = ip_sol_id;
    exception
      when others then
       return 0;
    end;
    begin
      merge into sa.adfcrm_solution_models asm
      using (select ip_sol_id solution_id
                  , pcpv.value2part_class
                  , count(distinct sq.class_param_name||sq.class_param_value) cnt_pc
             from sa.adfcrm_solution_qualification sq
             ,sa.table_x_part_class_params pcpn
             ,sa.table_x_part_class_values pcpv
             where sq.solution_id = ip_sol_id
             and pcpn.x_param_name = sq.class_param_name
             and pcpv.value2class_param = pcpn.objid
             and pcpv.value2part_class is not null
             and nvl(pcpv.x_param_value,'##') = nvl(sq.class_param_value,'##')
             group by pcpv.value2part_class
             ) pc_match
      on   (   asm.solution_id = pc_match.solution_id
           and asm.part_class_id = pc_match.value2part_class )
      when not matched then
            insert (asm.solution_id, asm.part_class_id,changed_by)
            values (pc_match.solution_id, pc_match.value2part_class,ip_login_name)
            where (pc_match.cnt_pc = v_cnt_sq)  --verify if part class meets all parameters defined
      ;
    v_result := sql%rowcount;
    commit;
    if ip_mode = 'Clean' then
        update sa.adfcrm_solution_models_hist
        set changed_by = ip_login_name
        where change_type = 'DELETE'
        and changed_date >= sysdate-5/(24*60)
        and solution_id = ip_sol_id;
        commit;
    end if;
    return v_result;
    exception
      when others then
       return 0;
    end;
  end func_ins_sol_model;
--------------------------------------------------------------------------------------------
  function task_flow_id(p_task_id in varchar2) return varchar2
  as
    cursor c1 is
    select task_flow_id
    from sa.adfcrm_task_flows
    where task_id = nvl(p_task_id,0);

    r1 c1%rowtype;
    result varchar2(200);
  begin
    open c1;
    fetch c1 into r1;
    if c1%found then
      result:=r1.task_flow_id;
    else
      result:=null;
    end if;
    close c1;
    return result;
  exception
  when invalid_number then return '';
  end task_flow_id;

--------------------------------------------------------------------------------------------
  function task_flow_id2(p_task_id in varchar2,p_esn varchar2) return varchar2
  as
    cursor c1 (c_task_id in varchar2)is
    select task_flow_id
    from sa.adfcrm_task_flows
    where task_id = nvl(c_task_id,0);
    r1 c1%rowtype;

  --109	Redemption
  --107	Activation

    -- total wireless(group) needs to go to redemption for reactivation

    cursor c2 is
    select table_bus_org.org_id,pi.x_part_inst_status,
    (select count('1') from sa.table_part_inst l
     where l.part_to_esn2part_inst = pi.objid
     and l.x_domain = 'LINES'
     and l.x_part_inst_status in ('37','38','39')) reserved_lines
     from sa.table_part_inst pi,sa.table_mod_level,sa.table_part_num,sa.table_bus_org
    where part_serial_no = nvl(p_esn,'N/A')
    and x_domain = 'PHONES'
    and X_PART_INST2CONTACT is not null
    and pi.n_part_inst2part_mod=table_mod_level.objid
    and table_mod_level.part_info2part_num =table_part_num.objid
    and table_part_num.part_num2bus_org = table_bus_org.objid;

    r2 c2%rowtype;

    result varchar2(200);
    v_reserved_line number:=0;
    v_task_id number;
    v_sub_bus_org varchar2(100);
    o_dummy varchar2(4000);
    v_active_lines number := 0;
  begin
    open c1(p_task_id);
    fetch c1 into r1;
    if c1%found then
      result:=r1.task_flow_id;
    end if;
    close c1;
--DBMS_OUTPUT.PUT_LINE('result = ' || result);
  --109	Redemption
  --107	Activation
    if result is null or p_task_id in ('109','107')  --CR54686 if task id not found or is 109 / CR57806
    then
      open c2;
      fetch c2 into r2;
      if c2%found then
            --CR57806 TAS Reactivation with reserved line in Redemption flow
            if r2.org_id = 'SIMPLE_MOBILE' then
               sa.phone_pkg.get_sub_brand(
                    I_ESN => p_esn,
                    o_sub_brand => v_sub_bus_org,
                    O_ERRNUM => o_dummy,
                    o_errstr => o_dummy
               );
            end if;

            if r2.org_id in ('TOTAL_WIRELESS') or nvl(v_sub_bus_org,'NOONE') = 'GO_SMART' then
               --Checking active lines, deactivation (PASTDUE) for GO_SMART leaves the line active 4/27/2018
               select count('1')
               into v_active_lines
               from sa.table_part_inst l,
                    sa.table_part_inst pi
               where pi.part_serial_no = nvl(p_esn,'N/A')
               and pi.x_domain = 'PHONES'
               and l.part_to_esn2part_inst = pi.objid
               and l.x_domain = 'LINES'
               and l.x_part_inst_status = '13';

               if r2.reserved_lines > 0 or v_active_lines > 0 then
                 if r2.x_part_inst_status in ('52','51','54') then
                    v_task_id:=109;
                 else
                    v_task_id := 107;
                 end if;
               else
                 if r2.x_part_inst_status in ('52') then
                    v_task_id := 109;
                 else
                    if r2.reserved_lines = 0
                       and v_active_lines = 0
                       and r2.x_part_inst_status in ('50','51','54')
                    then --No reserved lines and ESN status is not ACTIVE, navigate to Activation flow to activate
                        v_task_id := 107;
                    else
                        v_task_id := p_task_id;
                    end if;
                 end if;
               end if;
            else
              if r2.x_part_inst_status = '52' then
                  v_task_id:=109;
              else
--DBMS_OUTPUT.PUT_LINE('p_task_id = ' || p_task_id);
                 if (r2.x_part_inst_status in ('51','54','150') and r2.reserved_lines>0) or
                    (p_task_id ='109' and r2.x_part_inst_status != '52')  --CR54686
                 then
                    v_task_id:=107;
                 end if;
              end if;
            end if;

            open c1(v_task_id);
            fetch c1 into r1;
            if c1%found then
                result:=r1.task_flow_id;
                close c1;
            else
                close c1;
            end if;
      else
         result:= null;
      end if;
      close c2;
    end if;
    return result;
  exception
  when invalid_number then return '';
  end task_flow_id2;

--------------------------------------------------------------------------------------------
  function validate_user (ip_login_name in varchar2,
                                 ip_password   in varchar2) return number
  is
    cursor c1
    is
      select *
      from table_user
      where s_login_name = upper(ip_login_name)
      ;

    r1 c1%rowtype;
    procedure update_submitter_ind (
              p_s_login_name in sa.table_user.s_login_name%type,
              p_message      in varchar2
    ) is
    begin
    ------------------------------------------------------------------------------
    --  SUBMITTER_IND  counter for unsuccessful login attempts
    --  DEV  1:user active  0:user revoked
    ------------------------------------------------------------------------------
      update sa.table_user
      set    submitter_ind = submitter_ind + 1
            ,dev = decode(submitter_ind + 1,3,0,dev)
      where  s_login_name = p_s_login_name;

--      insert into sa.adfcrm_activity_log
--      (objid, agent, log_date, flow_name, flow_description, status, reason)
--       values
--      (sa.seq_adfcrm_activity_log.nextval, p_s_login_name, sysdate, 'TAS Login','TAS Login','Failed',p_message);
      commit;
    end;

  begin
    open c1;
    fetch c1 into r1;
    if c1%notfound then
      close c1;
      return 1; --User/Password Invalid or Inactive
    else
      close c1;
    end if;

    if r1.status <> 1
    then
       update_submitter_ind(r1.s_login_name,'User Inactive');
       return 3; --User Inactive
    end if;

    if r1.dev = 0
    then
--       insert into sa.adfcrm_activity_log
--       (objid, agent, log_date, flow_name, flow_description, status, reason)
--       values
--       (sa.seq_adfcrm_activity_log.nextval, r1.s_login_name, sysdate, 'TAS Login','TAS Login','Failed','User has been revoked. Please contact system support.');
       commit;
       return 4; --("User has been revoked. Please contact system support.");
    end if;

    if r1.web_password <> sa.encryptpassword(ip_password)
    then

       if r1.submitter_ind + 1 >= 3
       then
           update_submitter_ind(r1.s_login_name,'Incorrect Password. User has been revoked due to exceeding of maximum unsuccessful login attempts. '||
                                                'Please contact system support.');
           return 5;  --("Incorrect Password. User has been revoked due to exceeding of maximum unsuccessful login attempts. " +
                     --             "Please contact system support.");
       else
           update_submitter_ind(r1.s_login_name,'User/Password Invalid');
           return 1; --User/Password Invalid or Inactive
       end if;
    end if;

    if r1.web_passwd_chg < sysdate - 60 then
       update_submitter_ind(r1.s_login_name,'Password Expired');
       return 2; --Password Expired, use WEBCSR to change
    end if;

      update sa.table_user
      set web_last_login = sysdate
          ,dev = 1
          ,submitter_ind = 0
      where objid = r1.objid;

--       insert into sa.adfcrm_activity_log
--       (objid, agent, log_date, flow_name, flow_description, status, reason)
--       values
--       (sa.seq_adfcrm_activity_log.nextval, r1.s_login_name, sysdate, 'TAS Login','TAS Login','Success','User and Password Validated');

      commit;
      return 0; --User and Password Validated
  end validate_user;
--------------------------------------------------------------------------------------------
  procedure address (p_add_1 in varchar2,
                            p_add_2 in varchar2,
                            p_city in varchar2,
                            p_st in varchar2,
                            p_zip in varchar2,
                            p_country in varchar2,
                            p_address_objid in out number,  -- null--> Create / not null --> Update Address
                            p_err_code out varchar2,
                            p_err_msg  out varchar2) IS
  v_address_type VARCHAR2(100);
  v_contact_objid VARCHAR2(100);
 BEGIN
  v_address_type := 'BILLING';
  v_contact_objid := null;
  sa.ADFCRM_TRANSACTIONS.address
                           (p_add_1,
                           p_add_2,
                           p_city,
                           p_st,
                           p_zip,
                           p_country,
                           p_address_objid,
                           v_address_type,
                           v_contact_objid,
                           p_err_code,
                           p_err_msg);
 END;
--------------------------------------------------------------------------------------------
FUNCTION ADFCRM_TASK_FLOW_ID(
      P_TASK_ID IN VARCHAR2)
    RETURN VARCHAR2
  AS
  cursor c1 is
  select task_flow_id
  from sa.adfcrm_task_flows
  where task_id = nvl(P_TASK_ID,0);
  r1 c1%rowtype;
  result varchar2(200);
  Begin
      open c1;
      fetch c1 into r1;
      if c1%found then
        result:=r1.task_flow_id;
      else
        result:=null;
      end if;
      close c1;
      Return Result;
  Exception
     when others then
	    return null;

End ADFCRM_TASK_FLOW_ID;
--------------------------------------------------------------------------------------------
FUNCTION refresh_solution_models(ip_login_name varchar2)
  RETURN NUMBER
AS
  v_mode  VARCHAR2(10):='Keep';
  v_count NUMBER      :=0;
  CURSOR sol_cur
  IS
    SELECT * FROM sa.Adfcrm_Solution;
  sol_rec sol_cur%rowtype;
BEGIN
  FOR sol_rec IN sol_cur
  LOOP
    v_count:= v_count + func_ins_sol_model(sol_rec.solution_id,v_mode,ip_login_name);
  END LOOP;
  RETURN v_count;
END refresh_solution_models;
--------------------------------------------------------------------------------------------
FUNCTION add_new_models_to_solutions (ip_param_list varchar2, ip_login_name varchar2)  --comma separeted values
  RETURN NUMBER
AS
  v_count NUMBER      :=0;
BEGIN
  FOR sol_rec IN (SELECT * FROM sa.Adfcrm_Solution)
  LOOP
    for pc_rec in (select pc.name part_class_name
                   from  table_part_class pc,
                         (with t as (select ip_param_list part_class  from dual)
								   select replace(regexp_substr(part_class,'[^,]+',1,lvl),'null','') part_class_name
								   from  (select part_class, level lvl
										  from   t
										  connect by level <= length(part_class) - length(replace(part_class,',')) + 1)
                         ) p
                   where pc.name = trim(p.part_class_name)
	              )
    loop
        v_count:= v_count + func_ins_model_to_sol(sol_rec.solution_id,pc_rec.part_class_name,ip_login_name);
	end loop;
  END LOOP;
  RETURN v_count;
END add_new_models_to_solutions;
--------------------------------------------------------------------------------------------
  function func_ins_model_to_sol (ip_sol_id sa.adfcrm_solution.solution_id%type,
                                  part_class_name   varchar2,
                                  ip_login_name varchar2)
  return number
  is
  ---------------------------------------------------------
  -- This function insert into SA.ADFCRM_SOLUTION_MODELS --
  -- new part class that meets the solution qualification--
  -- return the number of record inserted                --
  ---------------------------------------------------------
    v_cnt_sq  number;
    v_result  number;
  begin
    if ip_sol_id is null then
       return 0;
    end if;
    -- Get the amount of parameters defined for the solution
    begin
      select count(distinct class_param_name) cnt_sq
      into   v_cnt_sq
      from sa.adfcrm_solution_qualification
      where solution_id = ip_sol_id;
    exception
      when others then
       return 0;
    end;
    begin
      merge into sa.adfcrm_solution_models asm
      using (select ip_sol_id solution_id
                  , pcpv.value2part_class  --part_class_id
                  , count(distinct sq.class_param_name||sq.class_param_value) cnt_pc
             from sa.adfcrm_solution_qualification sq
             ,sa.table_x_part_class_params pcpn
             ,sa.table_x_part_class_values pcpv
             where sq.solution_id = ip_sol_id
             and pcpn.x_param_name = sq.class_param_name
             and pcpv.value2class_param = pcpn.objid
             and pcpv.value2part_class = (select objid from sa.table_part_class where name = part_class_name)
             and nvl(pcpv.x_param_value,'##') = nvl(sq.class_param_value,'##')
             group by pcpv.value2part_class
             ) pc_match
      on   (   asm.solution_id = pc_match.solution_id
           and asm.part_class_id = pc_match.value2part_class )
      when not matched then
            insert (asm.solution_id, asm.part_class_id,changed_by)
            values (pc_match.solution_id, pc_match.value2part_class,ip_login_name)
            where (pc_match.cnt_pc = v_cnt_sq)  --verify if part class meets all parameters defined
      ;
    v_result := sql%rowcount;
    commit;
    return v_result;
    exception
      when others then
       return 0;
    end;
  end func_ins_model_to_sol;
--------------------------------------------------------------------------------------------
  procedure write_log(ip_call_id sa.adfcrm_activity_log.call_id%type,
                             ip_esn sa.adfcrm_activity_log.esn%type,
                             ip_cust_id sa.adfcrm_activity_log.cust_id%type,
                             ip_smp sa.adfcrm_activity_log.smp%type,
                             ip_agent sa.adfcrm_activity_log.agent%type,
                             ip_flow_name sa.adfcrm_activity_log.flow_name%type,
                             ip_flow_description sa.adfcrm_activity_log.flow_description%type,
                             ip_status sa.adfcrm_activity_log.status%type,
                             ip_permission_name sa.adfcrm_activity_log.permission_name%type,
                             ip_reason sa.adfcrm_activity_log.reason%type)
  as
  begin
     if instr(ip_flow_name,'TAS Login') > 0 then
       return;
     end if;
     -- IF CALL_ID WAS IN SESSION, BUT, USER HIT NEW CALL EVEN THOUGH SAME ESN, LOG NEW ENTRY

     -- WE WILL NEED A NEW INDEX
     merge into sa.adfcrm_activity_log
     using (select 1 from dual)
     on   (agent = ip_agent
     and   flow_name = ip_flow_name
     and   nvl(flow_description,'default') = nvl(ip_flow_description,'default')
     and   status = ip_status
     and   decode(ip_esn,null,'NA',esn) = nvl(ip_esn,'NA')
     and   decode(ip_call_id,null,'NA',call_id) = nvl(ip_call_id,'NA')
     and   decode(ip_cust_id,null,'NA',cust_id) = nvl(ip_cust_id,'NA')
     and   decode(ip_reason,null,'NA',reason) = nvl(ip_reason,'NA')
     and   log_date between sysdate-5/(24*60) and sysdate
     )
     when not matched then
     insert (objid,esn,smp,agent,log_date,flow_name,flow_description,status,permission_name,call_id,reason, cust_id, source_system)
     values (sa.seq_adfcrm_activity_log.nextval,ip_esn,ip_smp,ip_agent,sysdate,ip_flow_name,ip_flow_description,ip_status,ip_permission_name,ip_call_id,ip_reason,ip_cust_id,'TAS');


  end write_log;
--------------------------------------------------------------------------------------------
-- OVERLOADED NEW
--------------------------------------------------------------------------------------------
  procedure write_log(ip_call_id sa.adfcrm_activity_log.call_id%type,
                             ip_esn sa.adfcrm_activity_log.esn%type,
                             ip_cust_id sa.adfcrm_activity_log.cust_id%type,
                             ip_smp sa.adfcrm_activity_log.smp%type,
                             ip_agent sa.adfcrm_activity_log.agent%type,
                             ip_flow_name sa.adfcrm_activity_log.flow_name%type,
                             ip_flow_description sa.adfcrm_activity_log.flow_description%type,
                             ip_status sa.adfcrm_activity_log.status%type,
                             ip_permission_name sa.adfcrm_activity_log.permission_name%type,
                             ip_reason sa.adfcrm_activity_log.reason%type,
                             ip_ani varchar2)
  as
  begin
     if instr(ip_flow_name,'TAS Login') > 0 then
       return;
     end if;
     -- IF CALL_ID WAS IN SESSION, BUT, USER HIT NEW CALL EVEN THOUGH SAME ESN, LOG NEW ENTRY

     -- WE WILL NEED A NEW INDEX
     merge into sa.adfcrm_activity_log
     using (select 1 from dual)
     on   (agent = ip_agent
     and   flow_name = ip_flow_name
     and   nvl(flow_description,'default') = nvl(ip_flow_description,'default')
     and   status = ip_status
     and   decode(ip_esn,null,'NA',esn) = nvl(ip_esn,'NA')
     and   decode(ip_call_id,null,'NA',call_id) = nvl(ip_call_id,'NA')
     and   decode(ip_cust_id,null,'NA',cust_id) = nvl(ip_cust_id,'NA')
     and   decode(ip_reason,null,'NA',reason) = nvl(ip_reason,'NA')
     and   decode(ip_ani,null,'NA',ani) = nvl(ip_ani,'NA')
     and   log_date between sysdate-5/(24*60) and sysdate
     )
     when not matched then
     insert (objid,esn,smp,agent,log_date,flow_name,flow_description,status,permission_name,call_id,reason, cust_id,ani,source_system)
     values (sa.seq_adfcrm_activity_log.nextval,ip_esn,ip_smp,ip_agent,sysdate,ip_flow_name,ip_flow_description,ip_status,ip_permission_name,ip_call_id,ip_reason,ip_cust_id,ip_ani,'TAS');


  end write_log;
 --------------------------------------------------------------------------------------------
-- OVERLOADED for NEW_CC_ADDED_FLAG
--------------------------------------------------------------------------------------------
  procedure write_log(ip_call_id sa.adfcrm_activity_log.call_id%type,
                             ip_esn sa.adfcrm_activity_log.esn%type,
                             ip_cust_id sa.adfcrm_activity_log.cust_id%type,
                             ip_smp sa.adfcrm_activity_log.smp%type,
                             ip_agent sa.adfcrm_activity_log.agent%type,
                             ip_flow_name sa.adfcrm_activity_log.flow_name%type,
                             ip_flow_description sa.adfcrm_activity_log.flow_description%type,
                             ip_status sa.adfcrm_activity_log.status%type,
                             ip_permission_name sa.adfcrm_activity_log.permission_name%type,
                             ip_reason sa.adfcrm_activity_log.reason%type,
                             ip_ani varchar2,
                             ip_new_cc_added varchar2
                             )
  as
  begin
     if instr(ip_flow_name,'TAS Login') > 0 then
       return;
     end if;
     -- IF CALL_ID WAS IN SESSION, BUT, USER HIT NEW CALL EVEN THOUGH SAME ESN, LOG NEW ENTRY

     -- WE WILL NEED A NEW INDEX
     merge into sa.adfcrm_activity_log
     using (select 1 from dual)
     on   (agent = ip_agent
     and   flow_name = ip_flow_name
     and   nvl(flow_description,'default') = nvl(ip_flow_description,'default')
     and   status = ip_status
     and   decode(ip_esn,null,'NA',esn) = nvl(ip_esn,'NA')
     and   decode(ip_call_id,null,'NA',call_id) = nvl(ip_call_id,'NA')
     and   decode(ip_cust_id,null,'NA',cust_id) = nvl(ip_cust_id,'NA')
     and   decode(ip_reason,null,'NA',reason) = nvl(ip_reason,'NA')
     and   decode(ip_ani,null,'NA',ani) = nvl(ip_ani,'NA')
     and   log_date between sysdate-5/(24*60) and sysdate
     )
     when not matched then
     insert (objid,esn,smp,agent,log_date,flow_name,flow_description,status,permission_name,call_id,reason, cust_id,ani,source_system, new_cc_added_flag)
     values (sa.seq_adfcrm_activity_log.nextval,ip_esn,ip_smp,ip_agent,sysdate,ip_flow_name,ip_flow_description,ip_status,ip_permission_name,ip_call_id,ip_reason,ip_cust_id,ip_ani,'TAS',ip_new_cc_added );


  end write_log;
--------------------------------------------------------------------------------------------
  function is_home_center(p_esn varchar2)
  return number
  is
    n_cnt number := 0;
  begin
    -- return 0 if ESN is home_center device
    -- return 1 if ESN is not home_center device
    -- return 2 if other errors
    select count(*)
      into n_cnt
      from table_part_class          pc
          ,table_part_inst           pi
          ,table_mod_level           ml
          ,table_part_num            pn
          ,pc_params_view            pv
     where pi.n_part_inst2part_mod = ml.objid
       and ml.part_info2part_num = pn.objid
       and pn.part_num2part_class = pc.objid
       and pc.name = pv.part_class
       and param_name = 'MODEL_TYPE'
       and param_value = 'HOME_CENTER'
       and pi.part_serial_no = p_esn;

    if n_cnt > 0 then
      return 0;
    else
      return 1;
    end if;
  exception
    when others then
      return 2;
  end is_home_center;
--------------------------------------------------------------------------------------------
  --Apollo new function get_part_class
  function get_part_class(p_part_number varchar2)
  return varchar2
  is
    v_part_class_name sa.table_part_class.name%type;
  begin
    begin
        select min(pc.name)
        into v_part_class_name
        from sa.table_part_num pn,
            sa.table_part_class pc
        where pn.part_number = p_part_number
        and pc.objid = pn.part_num2part_class;
    exception
        when others then
            v_part_class_name := null;
    end;
    return v_part_class_name;
  end;

  --CR38663
  function unreserved_lines_from_esn(ip_esn varchar2, ip_org_id varchar2)
  return varchar
  is
    v_result varchar2(30);
  begin
    v_result := '0';
    If ip_org_id != 'TOTAL_WIRELESS'
    then
    for rec in (
               select pi.part_serial_no, al.x_min active_line, nal.part_serial_no no_active_line, nal.objid nal_objid
               from table_part_inst pi,
                    table_site_part al,
                    table_part_inst nal
               where pi.part_serial_no = ip_esn
               and pi.x_domain = 'PHONES'
               and al.x_service_id =  pi.part_serial_no
               and al.part_status in ('CarrierPending','Active')
               and nal.part_to_esn2part_inst =  pi.objid
               and nal.part_serial_no <> al.x_min
               and nal.x_domain = 'LINES'
               and nal.x_part_inst_status <> '13'
               )
    loop
        begin
            update table_part_inst
            set part_to_esn2part_inst = null
            where objid = rec.nal_objid;
        exception
            when others then null;
        end;
    end loop;
    end if;
    return v_result;
  end unreserved_lines_from_esn;

--************************************************************************************************************
PROCEDURE set_User_Deleted_Rows_Hist
        (ip_table_name in varchar2,
        ip_solution_id  in varchar2,
        ip_class_param_name in varchar2,
        ip_class_param_value in varchar2,
        ip_ss_id in varchar2,
        ip_token in varchar2,
        ip_case_conf_hdr_id in varchar2,
        ip_task_id in varchar2,
        ip_part_class_id in varchar2,
        ip_issue_id in varchar2,
        ip_file_id in varchar2,
        ip_tfs_id in varchar2,
        ip_login_name in varchar2) is
PRAGMA AUTONOMOUS_TRANSACTION;
v_table_name varchar2(30) := upper(ip_table_name);
BEGIN

if v_table_name='ADFCRM_SOLUTION_HIST' and ip_solution_id is not null then
    update sa.adfcrm_solution_hist
    set changed_by = ip_login_name
    where change_type = 'DELETE'
    and changed_date >= sysdate-5/(24*60)
    and solution_id = ip_solution_id
    ;
elsif v_table_name='ADFCRM_SOL_QUALIFICATION_HIST' and ip_solution_id is not null and ip_class_param_name is not null and ip_class_param_value is not null then
    update sa.ADFCRM_SOL_QUALIFICATION_HIST
    set changed_by = ip_login_name
    where change_type = 'DELETE'
    and changed_date >= sysdate-5/(24*60)
    and solution_id = ip_solution_id
    and class_param_name = ip_class_param_name
    and class_param_value = ip_class_param_value
    ;

elsif v_table_name='ADFCRM_SOLUTION_SCRIPTS_HIST' and ip_ss_id is not null then
    update sa.ADFCRM_SOLUTION_SCRIPTS_HIST
    set changed_by = ip_login_name
    where change_type = 'DELETE'
    and changed_date >= sysdate-5/(24*60)
    and ss_id = ip_ss_id
    ;

elsif v_table_name='ADFCRM_SOL_SCRIPT_TOKENS_HIST' and ip_token is not null then
    update sa.ADFCRM_SOL_SCRIPT_TOKENS_HIST
    set changed_by = ip_login_name
    where change_type = 'DELETE'
    and changed_date >= sysdate-5/(24*60)
    and token = ip_token
    ;

elsif v_table_name='ADFCRM_MTM_SOLTASK_FLOWS_HIST' and ip_solution_id is not null and ip_case_conf_hdr_id is not null and ip_task_id is not null then
    update sa.ADFCRM_MTM_SOLTASK_FLOWS_HIST
    set changed_by = ip_login_name
    where change_type = 'DELETE'
    and changed_date >= sysdate-5/(24*60)
    and solution_id = ip_solution_id
    and case_conf_hdr_id = ip_case_conf_hdr_id
    and task_id = ip_task_id
    ;

elsif v_table_name='ADFCRM_SOLUTION_MODELS_HIST' and ip_solution_id is not null and ip_part_class_id is not null then
    update sa.ADFCRM_SOLUTION_MODELS_HIST
    set changed_by = ip_login_name
    where change_type = 'DELETE'
    and changed_date >= sysdate-5/(24*60)
    and solution_id = ip_solution_id
    and part_class_id = ip_part_class_id
    ;

elsif v_table_name='ADFCRM_SOLUTION_ISSUES_HIST' and ip_solution_id is not null and ip_issue_id is not null then
    update sa.ADFCRM_SOLUTION_ISSUES_HIST
    set changed_by = ip_login_name
    where change_type = 'DELETE'
    and changed_date >= sysdate-5/(24*60)
    and solution_id = ip_solution_id
    and issue_id = ip_issue_id
    ;

elsif v_table_name='ADFCRM_SOLUTION_FILES_HIST' and ip_file_id is not null then
    update sa.ADFCRM_SOLUTION_FILES_HIST
    set changed_by = ip_login_name
    where change_type = 'DELETE'
    and changed_date >= sysdate-5/(24*60)
    and file_id = ip_file_id
    ;

elsif v_table_name='ADFCRM_TASK_FLOWS_HIST' and ip_task_id is not null then
    update sa.ADFCRM_TASK_FLOWS_HIST
    set changed_by = ip_login_name
    where change_type = 'DELETE'
    and changed_date >= sysdate-5/(24*60)
    and task_id = ip_task_id
    ;

elsif v_table_name='ADFCRM_TASK_FLOW_SCRIPTS_HIST' and ip_tfs_id is not null then
    update sa.ADFCRM_TASK_FLOW_SCRIPTS_HIST
    set changed_by = ip_login_name
    where change_type = 'DELETE'
    and changed_date >= sysdate-5/(24*60)
    and tfs_id = ip_tfs_id
    ;
else null;
end if;
commit;
END set_User_Deleted_Rows_Hist;


  end adfcrm_internal;
/