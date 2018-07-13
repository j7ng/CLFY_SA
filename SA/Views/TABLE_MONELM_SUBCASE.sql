CREATE OR REPLACE FORCE VIEW sa.table_monelm_subcase (mon_objid,elm_objid,id_number,dspch_age,total_age,"CONDITION",s_condition,status,s_status,title,s_title,owner_name,s_owner_name) AS
select table_monitor.objid, table_subcase.objid,
 table_subcase.id_number, table_condition.dispatch_time,
 table_subcase.creation_time, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_subcase.title, table_subcase.S_title,
 table_user.login_name, table_user.S_login_name
 from mtm_subcase21_monitor7, table_monitor, table_subcase, table_condition,
  table_gbst_elm, table_user
 where table_user.objid = table_subcase.subc_owner2user
 AND table_condition.objid = table_subcase.subc_state2condition
 AND table_subcase.objid = mtm_subcase21_monitor7.subc_view2monitor
 AND mtm_subcase21_monitor7.monitor2subcase = table_monitor.objid 
 AND table_gbst_elm.objid = table_subcase.subc_casests2gbst_elm
 ;
COMMENT ON TABLE sa.table_monelm_subcase IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_subcase.mon_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_subcase.elm_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_subcase.id_number IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_subcase.dspch_age IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_subcase.total_age IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_subcase."CONDITION" IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_subcase.status IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_subcase.title IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_subcase.owner_name IS 'Reserved; obsolete';