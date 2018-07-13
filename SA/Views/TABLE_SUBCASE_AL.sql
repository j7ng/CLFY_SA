CREATE OR REPLACE FORCE VIEW sa.table_subcase_al (entry_time,act_code,add_info,login_name,s_login_name,parent_objid,objid,act_name,s_act_name,gsl_name) AS
select table_act_entry.entry_time, table_act_entry.act_code,
 table_act_entry.addnl_info, table_user.login_name, table_user.S_login_name,
 table_act_entry.act_entry2subcase, table_act_entry.objid,
 table_gbst_elm.title, table_gbst_elm.S_title, table_gbst_lst.title
 from table_act_entry, table_user, table_gbst_elm,
  table_gbst_lst
 where table_act_entry.act_entry2subcase IS NOT NULL
 AND table_user.objid = table_act_entry.act_entry2user
 AND table_gbst_lst.objid = table_gbst_elm.gbst_elm2gbst_lst
 AND table_gbst_elm.objid = table_act_entry.entry_name2gbst_elm
 ;
COMMENT ON TABLE sa.table_subcase_al IS 'Selects events on a subcase';
COMMENT ON COLUMN sa.table_subcase_al.entry_time IS 'Date and time of activity log entry';
COMMENT ON COLUMN sa.table_subcase_al.act_code IS 'Activity code';
COMMENT ON COLUMN sa.table_subcase_al.add_info IS 'Additional information such as notes';
COMMENT ON COLUMN sa.table_subcase_al.login_name IS 'Login name of the user that made the activity log entry';
COMMENT ON COLUMN sa.table_subcase_al.parent_objid IS 'Unique object ID number of parent object';
COMMENT ON COLUMN sa.table_subcase_al.objid IS 'Unique object ID number of object';
COMMENT ON COLUMN sa.table_subcase_al.act_name IS 'Activity Name';
COMMENT ON COLUMN sa.table_subcase_al.gsl_name IS 'Name of the Clarify-defined pop up list on which act name is found';