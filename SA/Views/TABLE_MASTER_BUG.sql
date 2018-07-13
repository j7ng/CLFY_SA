CREATE OR REPLACE FORCE VIEW sa.table_master_bug (master_objid,dummy_objid,type_label,s_type_label,id_number,owner_name,s_owner_name,"CONDITION",s_condition,status,s_status) AS
select table_bug.objid, table_bug.objid,
 table_bug.release_rev, table_bug.S_release_rev, table_bug.id_number,
 table_user.login_name, table_user.S_login_name, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title
 from table_bug, table_user, table_condition,
  table_gbst_elm
 where table_condition.objid = table_bug.bug_condit2condition
 AND table_gbst_elm.objid = table_bug.bug_sts2gbst_elm
 AND table_user.objid = table_bug.bug_owner2user
 ;
COMMENT ON TABLE sa.table_master_bug IS 'Displays change request status information';
COMMENT ON COLUMN sa.table_master_bug.master_objid IS 'Bug internal record number';
COMMENT ON COLUMN sa.table_master_bug.dummy_objid IS 'Bug internal record number';
COMMENT ON COLUMN sa.table_master_bug.type_label IS 'Fixed in release version';
COMMENT ON COLUMN sa.table_master_bug.id_number IS 'Change request number; generated via auto-numbering';
COMMENT ON COLUMN sa.table_master_bug.owner_name IS 'User login name';
COMMENT ON COLUMN sa.table_master_bug."CONDITION" IS 'Title of condition';
COMMENT ON COLUMN sa.table_master_bug.status IS 'Reserved; not used';