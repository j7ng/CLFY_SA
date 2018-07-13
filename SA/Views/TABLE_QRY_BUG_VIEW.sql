CREATE OR REPLACE FORCE VIEW sa.table_qry_bug_view (elm_objid,id_number,"OWNER",s_owner,"CONDITION",s_condition,status,s_status,product,s_product,title,s_title,"PRIORITY",s_priority,"TYPE",s_type,creation_time) AS
select table_bug.objid, table_bug.id_number,
 table_owner.login_name, table_owner.S_login_name, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_part_num.description, table_part_num.S_description,
 table_bug.title, table_bug.S_title, table_gse_priority.title, table_gse_priority.S_title,
 table_gse_type.title, table_gse_type.S_title, table_bug.creation_time
 from table_gbst_elm table_gse_priority, table_gbst_elm table_gse_status, table_gbst_elm table_gse_type, table_user table_owner, table_bug, table_condition, table_part_num,
  table_mod_level
 where table_gse_priority.objid = table_bug.bug_priority2gbst_elm
 AND table_gse_type.objid = table_bug.bug_type2gbst_elm
 AND table_gse_status.objid = table_bug.bug_sts2gbst_elm
 AND table_owner.objid = table_bug.bug_owner2user
 AND table_mod_level.objid = table_bug.bug_product2part_info
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_condition.objid = table_bug.bug_condit2condition
 ;
COMMENT ON TABLE sa.table_qry_bug_view IS 'Used by form CRs from Query (803)';
COMMENT ON COLUMN sa.table_qry_bug_view.elm_objid IS 'Bug internal record number';
COMMENT ON COLUMN sa.table_qry_bug_view.id_number IS 'Change request number; generated via auto-numbering';
COMMENT ON COLUMN sa.table_qry_bug_view."OWNER" IS 'User login name';
COMMENT ON COLUMN sa.table_qry_bug_view."CONDITION" IS 'Condition of the bug';
COMMENT ON COLUMN sa.table_qry_bug_view.status IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_qry_bug_view.product IS 'Maps to sales and mfg systems';
COMMENT ON COLUMN sa.table_qry_bug_view.title IS 'Title of the change request';
COMMENT ON COLUMN sa.table_qry_bug_view."PRIORITY" IS 'Priority of the change request';
COMMENT ON COLUMN sa.table_qry_bug_view."TYPE" IS 'Type of the change request';
COMMENT ON COLUMN sa.table_qry_bug_view.creation_time IS 'Creation date/time of the change request';