CREATE OR REPLACE FORCE VIEW sa.table_prod_svc_itm (objid,contr_id,s_contr_id,sch_id,s_sch_id,line_no,serial_no,s_serial_no,site_part_objid,warranty_date,quantity,start_date,end_date,"CONDITION",s_condition,line_no_txt,instance_name,sch_objid,contr_objid) AS
select table_contr_itm.objid, table_contract.id, table_contract.S_id,
 table_contr_schedule.schedule_id, table_contr_schedule.S_schedule_id, table_contr_itm.line_no,
 table_site_part.serial_no, table_site_part.S_serial_no, table_site_part.objid,
 table_site_part.warranty_date, table_contr_itm.quantity,
 table_contr_itm.start_date, table_contr_itm.end_date,
 table_condition.title, table_condition.S_title, table_contr_itm.line_no_txt,
 table_site_part.instance_name, table_contr_schedule.objid,
 table_contract.objid
 from table_contr_itm, table_contract, table_contr_schedule,
  table_site_part, table_condition
 where table_site_part.objid = table_contr_itm.contr_itm2site_part
 AND table_condition.objid = table_contract.contract2condition
 AND table_contract.objid = table_contr_schedule.schedule2contract
 AND table_contr_schedule.objid = table_contr_itm.contr_itm2contr_schedule
 ;
COMMENT ON TABLE sa.table_prod_svc_itm IS 'Used for Entitlement checking by forms Incoming Call (8110) and Select Contract (9180)';
COMMENT ON COLUMN sa.table_prod_svc_itm.objid IS 'Contr_itm internal record number';
COMMENT ON COLUMN sa.table_prod_svc_itm.contr_id IS 'Contract ID number';
COMMENT ON COLUMN sa.table_prod_svc_itm.sch_id IS 'Contract schedule ID number';
COMMENT ON COLUMN sa.table_prod_svc_itm.line_no IS 'Contract line item s line number';
COMMENT ON COLUMN sa.table_prod_svc_itm.serial_no IS 'Serial number of the installed part';
COMMENT ON COLUMN sa.table_prod_svc_itm.site_part_objid IS 'Site_part internal record number';
COMMENT ON COLUMN sa.table_prod_svc_itm.warranty_date IS 'Installed part warranty end date';
COMMENT ON COLUMN sa.table_prod_svc_itm.quantity IS 'Contracted/Quoted quantity of the part';
COMMENT ON COLUMN sa.table_prod_svc_itm.start_date IS 'The starting date for the line item';
COMMENT ON COLUMN sa.table_prod_svc_itm.end_date IS 'The ending date for the line item';
COMMENT ON COLUMN sa.table_prod_svc_itm."CONDITION" IS 'The condition of the contract';
COMMENT ON COLUMN sa.table_prod_svc_itm.line_no_txt IS 'Concatination of parent and child line numbers delimited by a period';
COMMENT ON COLUMN sa.table_prod_svc_itm.instance_name IS 'Default is the concatination of part name, part number, and part revision. May be customized';
COMMENT ON COLUMN sa.table_prod_svc_itm.sch_objid IS 'Schedule internal record number';
COMMENT ON COLUMN sa.table_prod_svc_itm.contr_objid IS 'Contract internal record number';