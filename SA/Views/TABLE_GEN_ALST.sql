CREATE OR REPLACE FORCE VIEW sa.table_gen_alst (entry_time,act_code,add_info,login_name,s_login_name,parent_objid,objid,act_name,s_act_name,entry_objid,parent_type,parent_role) AS
select table_act_entry.entry_time, table_act_entry.act_code,
 table_act_entry.addnl_info, table_user.login_name, table_user.S_login_name,
 table_participant.focus_lowid, table_participant.objid,
 table_gbst_elm.title, table_gbst_elm.S_title, table_act_entry.objid,
 table_participant.focus_type, table_participant.role_code
 from table_act_entry, table_user, table_participant,
  table_gbst_elm
 where table_act_entry.objid = table_participant.participant2act_entry
 AND table_gbst_elm.objid = table_act_entry.entry_name2gbst_elm
 AND table_user.objid = table_act_entry.act_entry2user
 ;
COMMENT ON TABLE sa.table_gen_alst IS 'Used internally to select for generic queueable objects using Participant model';
COMMENT ON COLUMN sa.table_gen_alst.entry_time IS 'Activity log entry time';
COMMENT ON COLUMN sa.table_gen_alst.act_code IS 'Activity code';
COMMENT ON COLUMN sa.table_gen_alst.add_info IS 'Additional information such as notes';
COMMENT ON COLUMN sa.table_gen_alst.login_name IS 'Login name of user that made activity log entry';
COMMENT ON COLUMN sa.table_gen_alst.parent_objid IS 'Unique internal record number of focus object';
COMMENT ON COLUMN sa.table_gen_alst.objid IS 'Unique internal record number';
COMMENT ON COLUMN sa.table_gen_alst.act_name IS 'Name of activity';
COMMENT ON COLUMN sa.table_gen_alst.entry_objid IS 'Unique internal record number of activity log entry';
COMMENT ON COLUMN sa.table_gen_alst.parent_type IS 'Object type id of the focus object';
COMMENT ON COLUMN sa.table_gen_alst.parent_role IS 'Role of the focus object';