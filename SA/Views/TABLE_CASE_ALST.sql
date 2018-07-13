CREATE OR REPLACE FORCE VIEW sa.table_case_alst (entry_time,act_code,add_info,login_name,s_login_name,parent_objid,objid,act_name,s_act_name) AS
select table_act_entry.entry_time, table_act_entry.act_code,
 table_act_entry.addnl_info, table_user.login_name, table_user.S_login_name,
 table_act_entry.act_entry2case, table_act_entry.objid,
 table_gbst_elm.title, table_gbst_elm.S_title
 from table_act_entry, table_user, table_gbst_elm
 where table_user.objid = table_act_entry.act_entry2user
 AND table_act_entry.act_entry2case IS NOT NULL
 AND table_gbst_elm.objid = table_act_entry.entry_name2gbst_elm
 ;
COMMENT ON TABLE sa.table_case_alst IS 'Displays Case activity log. Used by forms Activity Log (391) and Activity Log Header (393)';
COMMENT ON COLUMN sa.table_case_alst.entry_time IS 'Activity log entry time';
COMMENT ON COLUMN sa.table_case_alst.act_code IS 'Activity code';
COMMENT ON COLUMN sa.table_case_alst.add_info IS 'Additional information such as notes';
COMMENT ON COLUMN sa.table_case_alst.login_name IS 'Login name of user that made activity log entry';
COMMENT ON COLUMN sa.table_case_alst.parent_objid IS 'Unique object ID number of parent object';
COMMENT ON COLUMN sa.table_case_alst.objid IS 'Unique object ID number';
COMMENT ON COLUMN sa.table_case_alst.act_name IS 'Name of activity';