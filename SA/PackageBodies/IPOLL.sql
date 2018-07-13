CREATE OR REPLACE PACKAGE BODY sa."IPOLL" as
/***************************************************************************************
    Name         :  SA.ipoll
    Purpose      :
    Author       : Unknown
    Date         : Unknown
    Revisions    :
    Version     Date      Who         Purpose
    -------------------------------------------------------------------------------------
     1.0      10/12/05    GPintado    CR4579 - Added Technology param to sp_get_orderType
/****************************************************************************************/
  ----------------------------------------------------------------------------------
 /* NEW PVCS STRUCTURE /NEW_PLSQL?CODE                                                              */
 /*1.0       04/08/08  VAdapa      Initial Version (Production copy as of 04/08/08)
 /*1.1       04/08/08  VAdapa      Changes are made as per Nitin(Oracle DBA) for CR7159
 /*1.2       11/15/10  VAdapa      Changes are made  for CR14630
 /*1.3      11/15/10  VAdapa      Changes are made  for CR14630
 /*1.4       4/27/16 Hnaini      Changes are made  for CR42413--

 ------------------------------*/--

 cursor site_part_curs(c_objid in number)
  is
    select state_value
      from table_site_part
     where objid = c_objid;


procedure sp_poll_action_items is
  cursor c1 is
  -- CR42413 added by Harsha Naini to improve Performance of the select statement
  -- We dona??t have blackouts any more we should look at removing all these ipoll jobs
-- We should remove or edit the following:
-- sp_poll_action_items
-- sp_poll_blackout(we dona??t do black out anymore)
-- sp_poll_intergate
-- sp_poll_monitor(dona??t try and create an action item because the site_part doesna??t exist)

  select
           ct.x_min,
           gt.title order_type,
           ct.x_call_trans2carrier carrier_objid,
           t.objid task_objid,
           ct.call_trans2site_part
      from
           table_task t,
           table_gbst_elm gb,
           table_gbst_elm gt ,
           table_x_call_trans ct
     where 1=1
       and t.start_date > sysdate -2
       and t.start_date < sysdate - 1/24
       and t.task_currq2queue is null
       and gb.objid = t.task_sts2gbst_elm
       and gb.title             = 'Created'
       and gt.objid = t.type_task2gbst_elm
       and gt.title            in ('Activation','ESN Change','Deactivation','Suspend')
       and ct.objid             = t.X_TASK2X_CALL_TRANS;

    --select ct.x_min,
 -- select /*+ index(t IND_TASK_STATUS2GBST) */ ct.x_min, --Changes are made as per Nitin(Oracle DBA) for CR7159
           -- gt.title order_type,
           -- ct.x_call_trans2carrier carrier_objid,
           -- t.objid task_objid,
           -- ct.call_trans2site_part
      -- from
           -- table_x_call_trans ct,
           -- table_gbst_elm gt ,
           -- table_task t,
           -- table_gbst_elm gb
     -- where t.task_currq2queue is null
       -- and t.task_sts2gbst_elm  = gb.objid
       -- and t.type_task2gbst_elm = gt.objid
       -- and ct.objid             = t.X_TASK2X_CALL_TRANS
       -- and gb.title             = 'Created'
       -- and gt.title            in ('Activation','ESN Change','Deactivation','Suspend');
      --and rownum < 2;
  cursor c6(c_call_trans2carrier in number) is
    select p.x_parent_name
      from
           table_x_parent p,
           table_x_carrier_group cg,
           table_x_carrier c
     where p.objid = cg.x_carrier_group2x_parent
       and p.x_parent_name != 'CINGULAR'
       and cg.objid = c.carrier2carrier_group
       and c.objid = c_call_trans2carrier;
  c6_rec c6%rowtype;
--
  l_order_type_objid number;
  l_destination_queue number;
  cnt number:= 0;
  site_part_rec site_part_curs%rowtype;
begin
  for c1_rec in c1 loop
--
--   this code is to check for cingular if this process is not run for a long time
--
--    open c6(c1_rec.carrier_objid);
--      fetch c6 into c6_rec;
--      if c6%found then

       --CR4579: Added to get state value from site_part
       open site_part_curs(c1_rec.call_trans2site_part);
    	 fetch site_part_curs into site_part_rec;
    	 close site_part_curs;


        igate.sp_get_ordertype(c1_rec.x_min,
                               c1_rec.order_type,
                               c1_rec.carrier_objid,
                               site_part_rec.state_value, --CR4579: Added Technology
                               l_order_type_objid);
        if igate.f_check_blackout(c1_rec.task_objid,l_order_type_objid) = 0 then
          igate.sp_Determine_Trans_Method(c1_rec.task_objid,
                                          c1_rec.order_type,
                                          null,
                                          l_destination_queue);
--        end if;
      end if;
--    close c6;
    cnt := cnt + 1;
    dbms_output.put_line('c1_rec.task_objid:'||c1_rec.task_objid);
  end loop;
  dbms_output.put_line('cnt:'||cnt);
end sp_poll_action_items;
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------
--cwl 10/7/10 added for elliot to close extra tasks for same call_trans
-------------------------------------------------------------------------------------
-----CR14630
procedure close_extra_task(p_task_id in varchar2) is
cursor c1 is
        select distinct
        tc.objid condition_objid,
        tt.objid task_objid
        from
        table_condition tc,
        table_task tt
        where 1=1
        and tt.task_id = p_task_id
        and tc.objid = tt.task_state2condition;
begin
for rec_card in c1 loop
    update sa.table_condition
    set condition = '8192',
        title = 'Closed Action Item',
        s_title = 'CLOSED ACTION ITEM'
    where objid = rec_card.condition_objid;
    update table_task
    set comp_date = sysdate,
        task_sts2gbst_elm = '268436615',
        task_wip2wipbin = null,
        task_currq2queue = null,
        x_queued_flag = '0',
        x_ota_type = null
    where objid = rec_card.task_objid;
    commit;
end loop;
end;
------CR14630

procedure sp_poll_intergate
is
  cursor intergate_queue_curs
  is
    select t.*,
           rank() over(partition by t.X_TASK2X_CALL_TRANS order by t.objid) rnk,  ----CR14630
           rownum row_num
      from table_task t,
           TABLE_queue q
     where t.task_currq2queue = q.objid
       and q.title = 'Intergate';
--
--    select t.*
--      from table_task t,
--           TABLE_queue q
--     where t.task_currq2queue = q.objid
--       and q.title = 'Intergate'
--       and not exists (select 1
--                        from gw1.ig_transaction it
--                       where it.ACTION_ITEM_ID = t.task_id)
--      and rownum < 1001;
---------------------------------------------------------
  cursor gbst_elm_curs(c_objid in number)
  is
    select *
      from table_gbst_elm
     where objid = c_objid;
  priority_rec gbst_elm_curs%rowtype;
  type_rec gbst_elm_curs%rowtype;
------------------------------
  cursor call_trans_curs(c_objid in number)
  is
    select *
      from table_x_call_trans
     where objid = c_objid;
  call_trans_rec call_trans_curs%rowtype;
---------------------------------------------------------
  cursor task_curs(c_min in varchar2)
  is
    select t.objid
      from table_condition    c,
           table_gbst_elm     p,
           table_gbst_elm     gt,
           table_task         t,
           table_x_call_trans ct,
           table_site_part    sp
     where c.title               != 'Close Action Item'
       and c.objid                = t.task_state2condition
       and p.title                = 'High - Upgrade'
       and p.objid                = t.task_priority2gbst_elm
       and gt.title               = 'Suspend'
       and gt.objid               = t.type_task2gbst_elm
       and t.x_task2x_call_trans  = ct.objid
       and ct.x_min               = sp.x_min
       and ct.x_service_id        = sp.x_service_id
       and sp.part_status||''     = 'Inactive'
       and sp.x_min               = c_min;
  task_rec task_curs%rowtype;

---------------------------------------------------------

  task_found boolean := false;
  cnt number := 0;
  str_method varchar2(30);
  l_order_type_objid number;
  l_destination_queue number;
  site_part_rec site_part_curs%rowtype;

begin
  for intergate_queue_rec in intergate_queue_curs loop
    if intergate_queue_rec.rnk =1 and intergate_queue_rec.row_num>1000 then
      exit;
    end if;
    if intergate_queue_rec.rnk = 1 then
      open gbst_elm_curs(intergate_queue_rec.task_priority2gbst_elm);
        fetch gbst_elm_curs into priority_rec;
      close gbst_elm_curs;

      open gbst_elm_curs(intergate_queue_rec.type_task2gbst_elm);
        fetch gbst_elm_curs into type_rec;
      close gbst_elm_curs;

      open call_trans_curs(intergate_queue_rec.X_TASK2X_CALL_TRANS);
        fetch call_trans_curs into call_trans_rec;
      close call_trans_curs;

      if intergate_queue_rec.x_queued_flag=1 then
        str_method := intergate_queue_rec.x_current_method;
      else
        str_method := null;
      end if;

      dbms_output.put_line(priority_rec.title||':'||type_rec.title);
      if priority_rec.title = 'High - Upgrade' and
         type_rec.title in ('Activation','ESN Change') then
        open task_curs(call_trans_rec.x_min);
          fetch task_curs into task_rec;
          if task_curs%found then
            task_found := true;
          end if;
        close task_curs;
      end if;
      if task_found = false then

      	--CR4579: Added to get state value from site_part
      	open site_part_curs(call_trans_rec.call_trans2site_part);
      	fetch site_part_curs into site_part_rec;
      	close site_part_curs;

        igate.sp_get_ordertype(call_trans_rec.x_min,
                               type_rec.title,
                               call_trans_rec.x_call_trans2carrier,
                               site_part_rec.state_value, --CR4579: Added Technology
                               l_order_type_objid);
        igate.sp_Determine_Trans_Method(intergate_queue_rec.objid,
                                        type_rec.title,
                                        null,
                                        l_destination_queue);
      else
        task_found := false;
      end if;
    else
      --cwl 10/7/10 added for elliot to close extra tasks for same call_trans
      close_extra_task(intergate_queue_rec.task_id);  ----CR14630
    end if;
  end loop;
end sp_poll_intergate;

--
-- removed the default value of 10 from p_cnt because 9i
-- does not allow a default in the body of it doesn't exist in the spec
-- jdarrah 1-5-06
procedure sp_poll_blackout(p_cnt in number) is
  cursor c1 is
    select q.title,
           t.objid task_objid,
           g.title order_type,
           g.objid order_type_objid,
           ct.x_min,
           ct.x_call_trans2carrier carrier_objid,
           ct.call_trans2site_part
      from table_gbst_elm g,
           table_x_call_trans ct,
           table_task t,
           table_queue q
     where g.objid = t.type_task2gbst_elm
       and ct.objid = t.X_TASK2X_CALL_TRANS
       and t.task_currq2queue = q.objid
       and q.title = 'BlackOut';
  l_order_type_objid number;
  l_destination_queue number;
  cnt number:= 0;
  site_part_rec site_part_curs%rowtype;
begin
  for c1_rec in c1 loop

  	  --CR4579: Added to get state value from site_part
  	 	open site_part_curs(c1_rec.call_trans2site_part);
    	fetch site_part_curs into site_part_rec;
    	close site_part_curs;

    igate.sp_get_ordertype(c1_rec.x_min,
                           c1_rec.order_type,
                           c1_rec.carrier_objid,
                           site_part_rec.state_value, --CR4579: Added Technology
                           l_order_type_objid);
    if igate.f_check_blackout(c1_rec.task_objid,l_order_type_objid) = 0 then
      cnt := cnt + 1;
      if cnt>p_cnt then
        exit;
      end if;
      igate.sp_Determine_Trans_Method(c1_rec.task_objid,
                                      c1_rec.order_type,
                                      null,
                                      l_destination_queue);
    end if;
  end loop;
  dbms_output.put_line('cnt:'||cnt);
end sp_poll_blackout;
--

procedure sp_poll_monitor is
  cursor c_user is
    select * from table_user
     where login_name = 'appsrv';
  c_user_rec c_user%rowtype;
  cursor c_monitor is
   select a.rowid , a.* from x_monitor a
    where a.x_line_worked is null and rownum < 1001;
  cursor  c_carrier(c_min in varchar2) is
    select c.*
      from table_x_carrier c,
           table_part_inst pi
     where c.objid =pi.part_inst2carrier_mkt
       and part_serial_no = c_min;
  c_carrier_rec c_carrier%rowtype;
  cursor c_site_part(c_esn in varchar2,
                     c_min in varchar2) is
    select * from table_site_part
      where serial_no = c_esn
        and x_min = c_min
       and x_deact_reason in ('PASTDUE','OVERDUE EXCHANGE','REFURBISHED','UNREPAIRABLE')
     order by service_end_dt desc;
  c_site_part_rec c_site_part%rowtype;
  cursor c_dealer(c_esn in varchar2) is
    select s.*
      from table_site s,
           table_inv_bin ib,
           table_part_inst pi
    where s.site_id = ib.bin_name
      and ib.objid = pi.part_inst2inv_bin
      and pi.part_serial_no = c_esn;
  c_dealer_rec c_dealer%rowtype;
--
  cursor c_contact(c_objid in number) is
    select c.*
      from table_contact c,
           table_contact_role cr,
           table_site s
    where c.objid = cr.contact_role2contact
      and cr.contact_role2site = c_objid;
  c_contact_rec c_contact%rowtype;
--
  cursor c_task(c_objid in number) is
    select *
      from table_task
     where objid = c_objid;
  c_task_rec c_task%rowtype;
--
  l_call_trans_objid number;
  l_task_objid number;
  l_action_type varchar2(100);
  l_order_type_objid number;
  l_trans_method number;
  blackout_code number;
  l_status_code number;
  l_dummy_out number;
  cnt number:= 0;
begin
dbms_output.put_line('sp_poll_monitor 1');
  open c_user;
    fetch c_user into c_user_rec;
  close c_user;
dbms_output.put_line('sp_poll_monitor 2');
  for monitor_rec in c_monitor loop
    if substr(monitor_rec.x_action,1,1) = 'X' then
dbms_output.put_line('sp_poll_monitor if');
      open c_carrier(monitor_rec.x_phone);
        fetch c_carrier into c_carrier_rec;
      close c_carrier;
      --04/10/03 select seq_x_call_trans.nextval into l_call_trans_objid from dual;
      select seq('x_call_trans') into l_call_trans_objid from dual;
      insert into table_x_call_trans
      (objid,
       x_min,
       x_transact_date,
       x_sourcesystem,
       x_action_type,
       x_result,
       x_reason,
       x_call_trans2user,
       x_call_trans2carrier,
       x_iccid) --CR3153
      values
      (l_call_trans_objid,
       monitor_rec.x_phone,
       sysdate,
       'Clarify',
       '99',
       'Completed',
       'Release Line',
       c_user_rec.objid,
       c_carrier_rec.objid,
       c_site_part_rec.x_iccid); --CR3153
--
      select decode(substr(monitor_rec.x_action,1,1),'S','Suspend','D','Deactivation','X','Return')
        into l_action_type
       from dual;
dbms_output.put_line('sp_poll_monitor 1');
      igate.sp_Create_Action_Item (0,
                             l_call_trans_objid,
                             l_action_type,
                             1,
                             0,
                             l_status_code,
                             l_task_objid);
dbms_output.put_line('sp_poll_monitor 2');
--
--Delete the x_monitor row of the processed record.
      begin delete from x_monitor
             where x_esn is null
               and x_phone = monitor_rec.x_phone;
        commit;
      end;
    elsif monitor_rec.x_esn is null then
      update x_monitor
         set x_line_worked = 'F'
       where rowid = monitor_rec.rowid;
      commit;
    else
dbms_output.put_line('sp_poll_monitor else');
      open c_site_part(monitor_rec.x_esn,monitor_rec.x_phone);
        fetch c_site_part into c_site_part_rec;
      close c_site_part;
      open c_carrier(monitor_rec.x_phone);
        fetch c_carrier into c_carrier_rec;
      close c_carrier;
      open c_dealer(monitor_rec.x_esn);
        fetch c_dealer into c_dealer_rec;
      close c_dealer;
      open c_contact(c_site_part_rec.site_part2site);
        fetch c_contact into c_contact_rec;
      close c_contact;
dbms_output.put_line('sp_poll_monitor else 2');
      -- 04/10/03 select seq_x_call_trans.nextval into l_call_trans_objid from dual;
      select seq('x_call_trans') into l_call_trans_objid from dual;
      insert into table_x_call_trans
      (objid,
       x_service_id,
       x_min,
       x_transact_date,
       x_sourcesystem,
       x_action_type,
       x_result,
       x_reason,
       x_call_trans2user,
       call_trans2site_part,
       x_call_trans2carrier,
       x_call_trans2dealer,
       x_iccid ) --CR3153
      values
      (l_call_trans_objid,
       monitor_rec.x_esn,
       monitor_rec.x_phone,
       sysdate,
       'Clarify',
       '99',
       'Completed',
       monitor_rec.x_reason_code,
       c_user_rec.objid,
       c_site_part_rec.objid,
       c_carrier_rec.objid,
       c_dealer_rec.objid,
       c_site_part_rec.x_iccid); --CR3153
dbms_output.put_line('sp_poll_monitor else 3');
      select decode(substr(monitor_rec.x_action,1,1),'S','Suspend','D','Deactivation','X','Return')
        into l_action_type
       from dual;
dbms_output.put_line('sp_poll_monitor else 4');
      igate.sp_Create_Action_Item (c_contact_rec.objid,
                             l_call_trans_objid,
                             l_action_type,
                             1,
                             0,
                             l_status_code,
                             l_task_objid);
dbms_output.put_line('sp_poll_monitor else 5');
      open c_task(l_task_objid);
        fetch c_task into c_task_rec;
      close c_task;
dbms_output.put_line('sp_poll_monitor else 6');
--
      igate.sp_get_ordertype(monitor_rec.x_phone,
                             'Activation',
                             c_carrier_rec.objid,
                             c_site_part_rec.state_value, --CR4579: Added Technology
                             l_order_type_objid);
dbms_output.put_line('sp_poll_monitor else 7');
      blackout_code := igate.f_check_blackout(l_task_objid,l_order_type_objid);
dbms_output.put_line('sp_poll_monitor else 8');
      if blackout_code = 0 then
        igate.sp_Determine_Trans_Method(l_task_objid,l_action_type,null,l_trans_method);
      elsif blackout_code = 1 then
        igate.sp_Dispatch_Task(l_Task_Objid, 'BlackOut',l_dummy_out);
      elsif blackout_code in (5,6) then
        igate.sp_Dispatch_Task(l_Task_Objid, 'Line Management Re-work',l_dummy_out);
      end if;
      begin
        delete from x_monitor
         where x_esn = monitor_rec.x_esn
           and x_phone = monitor_rec.x_phone;
        commit;
      end;
--
    end if;
  end loop;
end sp_poll_monitor;
end ipoll;
/