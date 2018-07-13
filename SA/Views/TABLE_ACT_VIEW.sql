CREATE OR REPLACE FORCE VIEW sa.table_act_view (objid,entry_time,act_code,addnl_info,drillin_type,drillin_objid,login_name,s_login_name,act_name,s_act_name,user_objid,gbst_elm_objid) AS
select table_act_entry.objid, table_act_entry.entry_time,
 table_act_entry.act_code, table_act_entry.addnl_info,
 table_act_entry.focus_type, table_act_entry.focus_lowid,
 table_user.login_name, table_user.S_login_name, table_gbst_elm.title, table_gbst_elm.S_title,
 table_user.objid, table_gbst_elm.objid
 from table_act_entry, table_user, table_gbst_elm
 where table_user.objid = table_act_entry.act_entry2user
 AND table_gbst_elm.objid = table_act_entry.entry_name2gbst_elm
 ;
COMMENT ON TABLE sa.table_act_view IS 'Used by form Consol (Sales) (12000), Opportunity Mgr (13000) and Generic LookUP -modal and non-modal (20000, 40000)';
COMMENT ON COLUMN sa.table_act_view.objid IS 'Unique object ID number';
COMMENT ON COLUMN sa.table_act_view.entry_time IS 'Activity log entry time';
COMMENT ON COLUMN sa.table_act_view.act_code IS 'Activity code';
COMMENT ON COLUMN sa.table_act_view.addnl_info IS 'Additional information such as notes';
COMMENT ON COLUMN sa.table_act_view.drillin_type IS 'Object type ID of the default drill down object for the event';
COMMENT ON COLUMN sa.table_act_view.drillin_objid IS 'Internal record number of the default drill down object for the event';
COMMENT ON COLUMN sa.table_act_view.login_name IS 'Login name of user that made activity log entry';
COMMENT ON COLUMN sa.table_act_view.act_name IS 'Name of activity';
COMMENT ON COLUMN sa.table_act_view.user_objid IS 'User internal record number of the user that made activity log entry';
COMMENT ON COLUMN sa.table_act_view.gbst_elm_objid IS 'Gbst_elm internal record number';