CREATE OR REPLACE PROCEDURE sa.SP_IMPORT_PRC
(
  ip_backup_id in number,
  op_result out VARCHAR2
) AS
   bk_id number;
   cursor c1 is
   select * from crm.bk_mtm_partclass2sp_value_def@apexprd
   where backup_id = bk_id;
   cursor c2 is
   select * from crm.bk_mtm_sp_carrierfeatures@apexprd
   where backup_id = bk_id;
   cursor c3 is
   select * from crm.bk_mtm_sp_x_program_param@apexprd
   where backup_id = bk_id;
   cursor c4 is
   select * from crm.bk_serviceplanfeaturevalue_def@apexprd
   where backup_id = bk_id;
   cursor c5 is
   select * from crm.bk_serviceplanfeature_value@apexprd
   where backup_id = bk_id;
   cursor c6 is
   select * from crm.bk_service_plan@apexprd
   where backup_id = bk_id;
   cursor c7 is
   select * from crm.bk_service_plan_feature@apexprd
   where backup_id = bk_id;
  function is_valid
  return number
  as
    valid_1 number;
    valid_2 number;
    valid_3 number;
    valid_4 number;
    valid_5 number;
    valid_6 number;
    valid_7 number;
  begin
    select count(*)
    into   valid_1
    from   crm.bk_mtm_partclass2sp_value_def@apexprd;
    select count(*)
    into   valid_2
    from   crm.bk_mtm_sp_carrierfeatures@apexprd;
    select count(*)
    into   valid_3
    from   crm.bk_mtm_sp_x_program_param@apexprd;
    select count(*)
    into   valid_4
    from   crm.bk_serviceplanfeaturevalue_def@apexprd;
    select count(*)
    into   valid_5
    from   crm.bk_serviceplanfeature_value@apexprd;
    select count(*)
    into   valid_6
    from   crm.bk_service_plan@apexprd;
    select count(*)
    into   valid_7
    from   crm.bk_service_plan_feature@apexprd;
    if valid_1 = 0 or
       valid_2 = 0 or
       valid_3 = 0 or
       valid_4 = 0 or
       valid_5 = 0 or
       valid_6 = 0 or
       valid_7 = 0
    then
      dbms_output.put_line('NADA FOUND');
      raise no_data_found;
    else
      dbms_output.put_line('FOUND VALUES FOR ALL');
      return 1;
    end if;
  exception
    when others then
      dbms_output.put_line('ERROR '|| SQLERRM);
      return 0;
  end is_valid;
BEGIN
  bk_id := ip_backup_id;
  if is_valid > 0 then
    delete from x_serviceplanfeature_value;
    delete from MTM_PARTCLASS_X_SPF_VALUE_DEF;
    delete from mtm_sp_carrierfeatures;
    delete from mtm_sp_x_program_param ;
    delete from x_service_plan_feature ;
    delete from x_serviceplanfeaturevalue_def;
    delete from x_service_plan;
    for r6 in c6 loop
      insert into X_SERVICE_PLAN
      (OBJID,MKT_NAME,DESCRIPTION,CUSTOMER_PRICE,IVR_PLAN_ID,WEBCSR_DISPLAY_NAME)
       values (r6.objid,r6.mkt_name,r6.description,r6.customer_price,r6.ivr_plan_id,r6.webcsr_display_name);
    end loop;
    for r4 in c4 loop
      insert into X_SERVICEPLANFEATUREVALUE_DEF
      (OBJID,PARENT_OBJID,VALUE_NAME,CHILD_VALUE_OBJID,DISPLAY_NAME,DISPLAY_ORDER,
       OPTIONAL,TABLE_TYPE,LEAF,DESCRIPTION)
      values
      (r4.OBJID,r4.PARENT_OBJID,r4.VALUE_NAME,r4.CHILD_VALUE_OBJID,r4.DISPLAY_NAME,r4.DISPLAY_ORDER,
       r4.optional,r4.table_type,r4.leaf,r4.description);
    end loop;
    for r7 in c7 loop
      insert into X_SERVICE_PLAN_FEATURE
      (OBJID,SP_FEATURE2REST_VALUE_DEF,SP_FEATURE2SERVICE_PLAN)
      values (r7.objid,r7.sp_feature2rest_value_def,r7.sp_feature2service_plan);
    end loop;
    for r2 in c2 loop
      insert into MTM_SP_CARRIERFEATURES
       (X_SERVICE_PLAN_ID,X_CARRIER_FEATURES_ID,PRIORITY)
      values (r2.X_SERVICE_PLAN_ID,r2.X_CARRIER_FEATURES_ID,r2.PRIORITY);
    end loop;
    for r3 in c3 loop
      insert into MTM_SP_X_PROGRAM_PARAM
      (X_SP2PROGRAM_PARAM,PROGRAM_PARA2X_SP,X_RECURRING)
      values (r3.X_SP2PROGRAM_PARAM,r3.PROGRAM_PARA2X_SP,r3.X_RECURRING);
    end loop;
    for r5 in c5 loop
      insert into X_SERVICEPLANFEATURE_VALUE
      (OBJID,SPF_VALUE2SPF,VALUE_REF,CHILD_VALUE_REF)
       values(r5.OBJID,r5.SPF_VALUE2SPF,r5.VALUE_REF,r5.CHILD_VALUE_REF);
    end loop;
    for r1 in c1 loop
      insert into MTM_PARTCLASS_X_SPF_VALUE_DEF
      (PART_CLASS_ID,SPFEATUREVALUE_DEF_ID)
      values (r1.part_class_id,r1.spfeaturevalue_def_id);
    end loop;
   op_result:='Success';
           insert into deployment_tracking values (NULL,'BACKUP ID',bk_id,bk_id,op_result,sysdate,sys_context('USERENV','OS_USER'));
      commit;
  end if;
exception
when others then
   op_result:='Failed';
END SP_IMPORT_PRC;
/