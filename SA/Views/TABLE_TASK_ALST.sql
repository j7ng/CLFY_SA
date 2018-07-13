CREATE OR REPLACE FORCE VIEW sa.table_task_alst (entry_time,act_code,add_info,login_name,s_login_name,parent_objid,objid,act_name,s_act_name) AS
select table_act_entry.entry_time, table_act_entry.act_code,
 table_act_entry.addnl_info, table_user.login_name, table_user.S_login_name,
 table_act_entry.act_entry2task, table_act_entry.objid,
 table_gbst_elm.title, table_gbst_elm.S_title
 from table_act_entry, table_user, table_gbst_elm
 where table_act_entry.act_entry2task IS NOT NULL
 AND table_user.objid = table_act_entry.act_entry2user
 AND table_gbst_elm.objid = table_act_entry.entry_name2gbst_elm
 ;
COMMENT ON TABLE sa.table_task_alst IS 'Used internally to feed Action Item activity log display';
COMMENT ON COLUMN sa.table_task_alst.entry_time IS 'Activity log entry time';
COMMENT ON COLUMN sa.table_task_alst.act_code IS 'Activity code';
COMMENT ON COLUMN sa.table_task_alst.add_info IS 'Additional information such as notes';
COMMENT ON COLUMN sa.table_task_alst.login_name IS 'Login name of user that made activity log entry';
COMMENT ON COLUMN sa.table_task_alst.parent_objid IS 'Unique internal record number of parent object';
COMMENT ON COLUMN sa.table_task_alst.objid IS 'Unique internal record number';
COMMENT ON COLUMN sa.table_task_alst.act_name IS 'Name of activity';