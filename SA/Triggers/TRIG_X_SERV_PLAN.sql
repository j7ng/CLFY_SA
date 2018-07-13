CREATE OR REPLACE TRIGGER sa."TRIG_X_SERV_PLAN"
after update ON sa.X_SERVICE_PLAN_SITE_PART
FOR EACH ROW
DISABLE declare
  PRAGMA AUTONOMOUS_TRANSACTION;
  cursor bus_org_curs is
    select bo.org_id
      from table_bus_org bo,
           table_part_num pn,
           table_mod_level ml,
           table_site_part sp
     where 1=1
       and bo.org_id = 'NET10'
       and bo.objid = pn.part_num2bus_org
       and pn.objid = ml.part_info2part_num
       and ml.objid = sp.site_part2part_info
       and sp.objid = :new.TABLE_SITE_PART_ID;
  bus_org_rec bus_org_curs%rowtype;
  cursor call_trans_curs is
    select ct.* ,
           (select pi.x_part_inst2contact
              from table_part_inst pi
             where pi.part_serial_no = ct.x_service_id) contact_objid,
           (select pn.x_technology
              from table_part_num pn,
                   table_mod_level ml,
                   table_part_inst pi
            where pi.part_serial_no = ct.x_service_id
             and ml.objid = pi.n_part_inst2part_mod
              and pn.objid = ml.part_info2part_num) x_technology
      from table_x_call_trans ct
     where ct.call_trans2site_part = :new.TABLE_SITE_PART_ID
       order by x_transact_date desc;
  call_trans_rec call_trans_curs%rowtype;
  cursor plan_type_curs(c_service_plan_id in number) is
    SELECT case when spfvdef2.value_name in ('MONTHLY PLANS') then
                  'MONTHLY PLANS'
                else
                  'NOT NONTHLY'
                end  plan_type
      FROM X_SERVICE_PLAN_FEATURE spf,
           X_SERVICEPLANFEATUREVALUE_DEF spfvdef,
           X_SERVICEPLANFEATURE_VALUE spfv,
           X_SERVICEPLANFEATUREVALUE_DEF spfvdef2
     WHERE 1 = 1
       AND spf.sp_feature2service_plan = c_SERVICE_PLAN_ID
       AND spfvdef.objid               = spf.sp_feature2rest_value_def
       AND spfvdef.value_name          = 'PLAN TYPE'
       AND spfv.spf_value2spf          = spf.objid
       AND spfvdef2.objid              = spfv.value_ref;
  old_plan_type_rec plan_type_curs%rowtype;
  new_plan_type_rec plan_type_curs%rowtype;
  l_status_code varchar2(300);
  l_task_objid number;
  l_dest_queue number;
  l_dummy_out number;
l_job number;
BEGIN
  open bus_org_curs;
    fetch bus_org_curs into bus_org_rec;
    if bus_org_curs%found and :new.X_SERVICE_PLAN_ID != :old.X_SERVICE_PLAN_ID then
      open call_trans_curs;
        fetch call_trans_curs into call_trans_rec;
        if call_trans_curs%found and call_trans_rec.x_action_type = '6' then
          open plan_type_curs(:old.X_SERVICE_PLAN_ID);
            fetch plan_type_curs into old_plan_type_rec;
            if plan_type_curs%notfound then
              old_plan_type_rec.plan_type := 'NOT MONTHLY';
            end if;
          close plan_type_curs;
          open plan_type_curs(:new.X_SERVICE_PLAN_ID);
            fetch plan_type_curs into new_plan_type_rec;
            if plan_type_curs%notfound then
              new_plan_type_rec.plan_type := 'NOT MONTHLY';
            end if;
          close plan_type_curs;
          if new_plan_type_rec.plan_type != 'NOT MONTHLY' or old_plan_type_rec.plan_type != 'NOT MONTHLY' then
            igate.sp_Create_Action_Item (call_trans_rec.contact_objid,
                                         call_trans_rec.objid,
                                         'Rate Plan Change',
                                         1,
                                         0,
                                         l_status_code,
                                         l_task_objid);
            if l_task_objid is not null then
              dbms_job.submit
    ( job => l_job
    , what => 'sa.net10_r_trans('||l_task_objid||');'
    , next_date => sysdate+1/24/60 -- One minute later
    );
        --      igate.sp_Determine_Trans_Method(l_task_objid,'Rate Plan Change',null,l_dest_queue);
            end if;
commit;
          end if;
        end if;
      close call_trans_curs;
    end if;
  close bus_org_curs;
END;
/