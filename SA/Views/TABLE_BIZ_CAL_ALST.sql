CREATE OR REPLACE FORCE VIEW sa.table_biz_cal_alst (entry_time,act_code,add_info,login_name,s_login_name,parent_objid,objid,act_name,s_act_name) AS
select table_act_entry.entry_time, table_act_entry.act_code,
 table_act_entry.addnl_info, table_user.login_name, table_user.S_login_name,
 table_act_entry.act_entry2biz_cal_hdr, table_act_entry.objid,
 table_gbst_elm.title, table_gbst_elm.S_title
 from table_act_entry, table_user, table_gbst_elm
 where table_user.objid = table_act_entry.act_entry2user
 AND table_act_entry.act_entry2biz_cal_hdr IS NOT NULL
 AND table_gbst_elm.objid = table_act_entry.entry_name2gbst_elm
 ;
COMMENT ON TABLE sa.table_biz_cal_alst IS 'Used internally to feed Business Calendar activity log display';
COMMENT ON COLUMN sa.table_biz_cal_alst.entry_time IS 'Date and time of entry in activity log';
COMMENT ON COLUMN sa.table_biz_cal_alst.act_code IS 'Activity code for the activity log entry; internally assigned';
COMMENT ON COLUMN sa.table_biz_cal_alst.add_info IS 'Additional information about activity log entry';
COMMENT ON COLUMN sa.table_biz_cal_alst.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_biz_cal_alst.parent_objid IS 'Business calendar internal record number';
COMMENT ON COLUMN sa.table_biz_cal_alst.objid IS 'Act_entry internal record number';
COMMENT ON COLUMN sa.table_biz_cal_alst.act_name IS 'Name of the activity log type';