CREATE OR REPLACE FORCE VIEW sa.table_monelm_case (mon_objid,elm_objid,id_number,dspch_age,total_age,"CONDITION",s_condition,status,s_status,title,s_title,owner_name,s_owner_name) AS
select table_monitor.objid, table_case.objid,
 table_case.id_number, table_condition.dispatch_time,
 table_case.creation_time, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_case.title, table_case.S_title,
 table_user.login_name, table_user.S_login_name
 from mtm_case34_monitor6, table_monitor, table_case, table_condition,
  table_gbst_elm, table_user
 where table_user.objid = table_case.case_owner2user
 AND table_case.objid = mtm_case34_monitor6.case_view2monitor
 AND mtm_case34_monitor6.monitor2case = table_monitor.objid 
 AND table_condition.objid = table_case.case_state2condition
 AND table_gbst_elm.objid = table_case.casests2gbst_elm
 ;
COMMENT ON TABLE sa.table_monelm_case IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_case.mon_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_case.elm_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_case.id_number IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_case.dspch_age IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_case.total_age IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_case."CONDITION" IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_case.status IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_case.title IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_case.owner_name IS 'Reserved; obsolete';