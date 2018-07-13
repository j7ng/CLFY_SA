CREATE OR REPLACE FORCE VIEW sa.table_monitor_user (mon_obj_id,user_obj_id,user_name,s_user_name,mon_name,mon_type) AS
select table_monitor.objid, table_user.objid,
 table_user.login_name, table_user.S_login_name, table_monitor.title,
 table_monitor.type
 from mtm_user26_monitor2, table_monitor, table_user
 where table_user.objid = mtm_user26_monitor2.supvr_access2monitor
 AND mtm_user26_monitor2.super_monitor2user = table_monitor.objid 
 ;
COMMENT ON TABLE sa.table_monitor_user IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monitor_user.mon_obj_id IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monitor_user.user_obj_id IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monitor_user.user_name IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monitor_user.mon_name IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monitor_user.mon_type IS 'Reserved; obsolete';