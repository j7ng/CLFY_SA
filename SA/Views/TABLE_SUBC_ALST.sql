CREATE OR REPLACE FORCE VIEW sa.table_subc_alst (entry_time,act_code,add_info,login_name,s_login_name,subcase_objid,case_objid,subcase_id_number,objid,act_name,s_act_name,gsl_name,gse_objid,user_objid,gsl_objid) AS
select table_act_entry.entry_time, table_act_entry.act_code,
 table_act_entry.addnl_info, table_user.login_name, table_user.S_login_name,
 table_subcase.objid, table_subcase.subcase2case,
 table_subcase.id_number, table_act_entry.objid,
 table_gbst_elm.title, table_gbst_elm.S_title, table_gbst_lst.title,
 table_gbst_elm.objid, table_user.objid,
 table_gbst_lst.objid
 from table_act_entry, table_user, table_subcase,
  table_gbst_elm, table_gbst_lst
 where table_subcase.objid = table_act_entry.act_entry2subcase
 AND table_user.objid = table_act_entry.act_entry2user
 AND table_subcase.subcase2case IS NOT NULL
 AND table_gbst_lst.objid = table_gbst_elm.gbst_elm2gbst_lst
 AND table_gbst_elm.objid = table_act_entry.entry_name2gbst_elm
 ;
COMMENT ON TABLE sa.table_subc_alst IS 'Used internally for Subcase activity log display';
COMMENT ON COLUMN sa.table_subc_alst.entry_time IS 'Date and time of activity log entry';
COMMENT ON COLUMN sa.table_subc_alst.act_code IS 'Activity code for the activity log entry; internally assigned with a unique code for each type of activity';
COMMENT ON COLUMN sa.table_subc_alst.add_info IS 'Additional information such as notes';
COMMENT ON COLUMN sa.table_subc_alst.login_name IS 'Login name of the user that made the activity log entry';
COMMENT ON COLUMN sa.table_subc_alst.subcase_objid IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_subc_alst.case_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_subc_alst.subcase_id_number IS 'Unique ID number for the subcase; consists of case number-#';
COMMENT ON COLUMN sa.table_subc_alst.objid IS 'Act_entry internal record number';
COMMENT ON COLUMN sa.table_subc_alst.act_name IS 'Activity Name';
COMMENT ON COLUMN sa.table_subc_alst.gsl_name IS 'Name of the Clarify-defined pop up list on which act name is found';
COMMENT ON COLUMN sa.table_subc_alst.gse_objid IS 'Gbst_elm internal record number';
COMMENT ON COLUMN sa.table_subc_alst.user_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_subc_alst.gsl_objid IS 'Gbst_lst internal record number';