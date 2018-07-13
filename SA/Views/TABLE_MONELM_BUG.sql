CREATE OR REPLACE FORCE VIEW sa.table_monelm_bug (mon_objid,elm_objid,id_number,dspch_age,total_age,"CONDITION",s_condition,status,s_status,title,s_title,owner_name,s_owner_name) AS
select table_monitor.objid, table_bug.objid,
 table_bug.id_number, table_condition.dispatch_time,
 table_bug.creation_time, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_bug.title, table_bug.S_title,
 table_user.login_name, table_user.S_login_name
 from mtm_monitor9_bug20, table_monitor, table_bug, table_condition,
  table_gbst_elm, table_user
 where table_condition.objid = table_bug.bug_condit2condition
 AND table_user.objid = table_bug.bug_owner2user
 AND table_monitor.objid = mtm_monitor9_bug20.monitor2bug
 AND mtm_monitor9_bug20.bug_view2monitor = table_bug.objid 
 AND table_gbst_elm.objid = table_bug.bug_sts2gbst_elm
 ;
COMMENT ON TABLE sa.table_monelm_bug IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_bug.mon_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_bug.elm_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_bug.id_number IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_bug.dspch_age IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_bug.total_age IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_bug."CONDITION" IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_bug.status IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_bug.title IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_bug.owner_name IS 'Reserved; obsolete';