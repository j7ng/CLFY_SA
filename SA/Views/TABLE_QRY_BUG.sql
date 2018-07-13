CREATE OR REPLACE FORCE VIEW sa.table_qry_bug (elm_objid,id_number,"OWNER",s_owner,"CONDITION",s_condition,status,s_status,product,s_product,title,s_title) AS
select table_bug.objid, table_bug.id_number,
 table_user.login_name, table_user.S_login_name, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_part_num.description, table_part_num.S_description,
 table_bug.title, table_bug.S_title
 from table_bug, table_user, table_condition,
  table_gbst_elm, table_part_num, table_mod_level
 where table_condition.objid = table_bug.bug_condit2condition
 AND table_user.objid = table_bug.bug_owner2user
 AND table_mod_level.objid = table_bug.bug_product2part_info
 AND table_gbst_elm.objid = table_bug.bug_sts2gbst_elm
 AND table_part_num.objid = table_mod_level.part_info2part_num
 ;
COMMENT ON TABLE sa.table_qry_bug IS 'Change request information used in Query list';
COMMENT ON COLUMN sa.table_qry_bug.elm_objid IS 'Bug internal record number';
COMMENT ON COLUMN sa.table_qry_bug.id_number IS 'Change request number; generated via auto-numbering';
COMMENT ON COLUMN sa.table_qry_bug."OWNER" IS 'User login name';
COMMENT ON COLUMN sa.table_qry_bug."CONDITION" IS 'Title of condition';
COMMENT ON COLUMN sa.table_qry_bug.status IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_qry_bug.product IS 'Maps to sales and mfg systems';
COMMENT ON COLUMN sa.table_qry_bug.title IS 'Title of the change request';