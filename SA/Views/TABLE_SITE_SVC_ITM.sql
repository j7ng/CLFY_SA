CREATE OR REPLACE FORCE VIEW sa.table_site_svc_itm (objid,contr_id,s_contr_id,sch_id,s_sch_id,line_no,site_id,site_name,s_site_name,site_objid,quantity,start_date,end_date,"CONDITION",s_condition,line_no_txt,sch_objid,contr_objid) AS
select table_contr_itm.objid, table_contract.id, table_contract.S_id,
 table_contr_schedule.schedule_id, table_contr_schedule.S_schedule_id, table_contr_itm.line_no,
 table_site.site_id, table_site.name, table_site.S_name,
 table_site.objid, table_contr_itm.quantity,
 table_contr_itm.start_date, table_contr_itm.end_date,
 table_condition.title, table_condition.S_title, table_contr_itm.line_no_txt,
 table_contr_schedule.objid, table_contract.objid
 from table_contr_itm, table_contract, table_contr_schedule,
  table_site, table_condition
 where table_site.objid = table_contr_itm.covered_by2site
 AND table_contr_schedule.objid = table_contr_itm.contr_itm2contr_schedule
 AND table_contract.objid = table_contr_schedule.schedule2contract
 AND table_condition.objid = table_contract.contract2condition AND 1 = 2;
COMMENT ON TABLE sa.table_site_svc_itm IS 'Used for Entitlement checking. Used by forms Incoming Call (8110), Select Contract (9180) and My Clarify (12000)';
COMMENT ON COLUMN sa.table_site_svc_itm.objid IS 'Contract item internal record number';
COMMENT ON COLUMN sa.table_site_svc_itm.contr_id IS 'Contract ID number';
COMMENT ON COLUMN sa.table_site_svc_itm.sch_id IS 'Contract schedule ID number';
COMMENT ON COLUMN sa.table_site_svc_itm.line_no IS 'Contract item line number';
COMMENT ON COLUMN sa.table_site_svc_itm.site_id IS 'Site ID number';
COMMENT ON COLUMN sa.table_site_svc_itm.site_name IS 'Name of the site';
COMMENT ON COLUMN sa.table_site_svc_itm.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_site_svc_itm.quantity IS 'Contracted/Quoted quantity of the part';
COMMENT ON COLUMN sa.table_site_svc_itm.start_date IS 'The starting date for the line item';
COMMENT ON COLUMN sa.table_site_svc_itm.end_date IS 'The ending date for the line item';
COMMENT ON COLUMN sa.table_site_svc_itm."CONDITION" IS 'The condition of the contract';
COMMENT ON COLUMN sa.table_site_svc_itm.line_no_txt IS 'Dsiplays line number text of contr_itm';
COMMENT ON COLUMN sa.table_site_svc_itm.sch_objid IS 'Schedule internal record number';
COMMENT ON COLUMN sa.table_site_svc_itm.contr_objid IS 'Contract internal record number';