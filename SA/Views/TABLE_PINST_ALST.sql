CREATE OR REPLACE FORCE VIEW sa.table_pinst_alst (entry_time,act_code,add_info,login_name,s_login_name,parent_objid,objid,act_name,s_act_name) AS
select table_act_entry.entry_time, table_act_entry.act_code,
 table_act_entry.addnl_info, table_user.login_name, table_user.S_login_name,
 table_act_entry.act_entry2site_part, table_act_entry.objid,
 table_gbst_elm.title, table_gbst_elm.S_title
 from table_act_entry, table_user, table_gbst_elm
 where table_user.objid = table_act_entry.act_entry2user
 AND table_gbst_elm.objid = table_act_entry.entry_name2gbst_elm
 AND table_act_entry.act_entry2site_part IS NOT NULL
 ;
COMMENT ON TABLE sa.table_pinst_alst IS 'Used internally to feed Installed Part activity log display';
COMMENT ON COLUMN sa.table_pinst_alst.entry_time IS 'Date and time of entry into activity log';
COMMENT ON COLUMN sa.table_pinst_alst.act_code IS 'Activity code for the activity log entry; internally assigned with a unique code for each type of activity';
COMMENT ON COLUMN sa.table_pinst_alst.add_info IS 'Additional information about activity log entry';
COMMENT ON COLUMN sa.table_pinst_alst.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_pinst_alst.parent_objid IS 'Parent part internal record number';
COMMENT ON COLUMN sa.table_pinst_alst.objid IS 'Act_entry internal record number';
COMMENT ON COLUMN sa.table_pinst_alst.act_name IS 'Type of activity log entry from Clarify-defined pop up list';