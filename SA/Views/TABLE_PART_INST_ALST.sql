CREATE OR REPLACE FORCE VIEW sa.table_part_inst_alst (entry_time,act_code,add_info,login_name,s_login_name,parent_objid,to_objid,objid,act_name,s_act_name) AS
select table_act_entry.entry_time, table_act_entry.act_code,
 table_act_entry.addnl_info, table_user.login_name, table_user.S_login_name,
 table_part_trans.from_inst2part_inst, table_part_trans.to_inst2part_inst,
 table_act_entry.objid, table_gbst_elm.title, table_gbst_elm.S_title
 from table_act_entry, table_user, table_part_trans,
  table_gbst_elm
 where table_part_trans.objid = table_act_entry.act_entry2part_trans
 AND table_part_trans.from_inst2part_inst IS NOT NULL
 AND table_part_trans.to_inst2part_inst IS NOT NULL
 AND table_user.objid = table_act_entry.act_entry2user
 AND table_gbst_elm.objid = table_act_entry.entry_name2gbst_elm
 ;
COMMENT ON TABLE sa.table_part_inst_alst IS 'Used internally to feed Inventory Part activity log display';
COMMENT ON COLUMN sa.table_part_inst_alst.entry_time IS 'Date and time of activity log entry';
COMMENT ON COLUMN sa.table_part_inst_alst.act_code IS 'Activity code';
COMMENT ON COLUMN sa.table_part_inst_alst.add_info IS 'Additional information such as notes';
COMMENT ON COLUMN sa.table_part_inst_alst.login_name IS 'Login name of user that made activity log entry';
COMMENT ON COLUMN sa.table_part_inst_alst.parent_objid IS 'Unique object ID number of parent object';
COMMENT ON COLUMN sa.table_part_inst_alst.to_objid IS 'Unique object ID number of TO object';
COMMENT ON COLUMN sa.table_part_inst_alst.objid IS 'Unique object ID number of activity object';
COMMENT ON COLUMN sa.table_part_inst_alst.act_name IS 'Activity name';