CREATE OR REPLACE FORCE VIEW sa.table_bug_view (usr_objid,elm_objid,id_number,dspch_age,total_age,"CONDITION",s_condition,response,s_response) AS
select table_user.objid, table_bug.objid,
 table_bug.id_number, table_condition.dispatch_time,
 table_bug.creation_time, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title
 from mtm_monitor9_bug20, mtm_user20_monitor0, table_user, table_bug, table_condition,
  table_gbst_elm, table_monitor
 where table_gbst_elm.objid = table_bug.bug_priority2gbst_elm
 AND table_condition.objid = table_bug.bug_condit2condition
 AND table_monitor.objid = mtm_monitor9_bug20.monitor2bug
 AND mtm_monitor9_bug20.bug_view2monitor = table_bug.objid 
 AND table_user.objid = mtm_user20_monitor0.user_access2monitor
 AND mtm_user20_monitor0.monitor2user = table_monitor.objid 
 ;
COMMENT ON TABLE sa.table_bug_view IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_bug_view.usr_objid IS 'User objid';
COMMENT ON COLUMN sa.table_bug_view.elm_objid IS 'Bug internal record number';
COMMENT ON COLUMN sa.table_bug_view.id_number IS 'Change request number; generated via auto-numbering';
COMMENT ON COLUMN sa.table_bug_view.dspch_age IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_bug_view.total_age IS 'Creation date/time of the change request';
COMMENT ON COLUMN sa.table_bug_view."CONDITION" IS 'Title of condition';
COMMENT ON COLUMN sa.table_bug_view.response IS 'Response priority of a CR; from a Clarify-defined pop up list';