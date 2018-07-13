CREATE OR REPLACE FORCE VIEW sa.table_list_subcase (case_objid,elm_objid,clarify_state,user_objid,behavior,id_number,"OWNER",s_owner,"CONDITION",s_condition,status,s_status,title,s_title,sub_type) AS
select table_subcase.subcase2case, table_subcase.objid,
 table_condition.condition, table_user.objid,
 table_subcase.behavior, table_subcase.id_number,
 table_user.login_name, table_user.S_login_name, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_subcase.title, table_subcase.S_title,
 table_subcase.sub_type
 from table_subcase, table_condition, table_user,
  table_gbst_elm
 where table_subcase.subcase2case IS NOT NULL
 AND table_condition.objid = table_subcase.subc_state2condition
 AND table_gbst_elm.objid = table_subcase.subc_casests2gbst_elm
 AND table_user.objid = table_subcase.subc_owner2user
 ;
COMMENT ON TABLE sa.table_list_subcase IS 'Site for which the report was run. Used by form Select Subcases (433)';
COMMENT ON COLUMN sa.table_list_subcase.case_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_list_subcase.elm_objid IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_list_subcase.clarify_state IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_list_subcase.user_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_list_subcase.behavior IS 'Internal field indicating the behavior of the subcase type; i.e.,  1=normal, 2=administrative subcase';
COMMENT ON COLUMN sa.table_list_subcase.id_number IS 'Unique ID number for the subcase; consists of case number-#';
COMMENT ON COLUMN sa.table_list_subcase."OWNER" IS 'User login name';
COMMENT ON COLUMN sa.table_list_subcase."CONDITION" IS 'Title of condition';
COMMENT ON COLUMN sa.table_list_subcase.status IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_list_subcase.title IS 'Subcase title';
COMMENT ON COLUMN sa.table_list_subcase.sub_type IS 'Subcase type; general or administrative';