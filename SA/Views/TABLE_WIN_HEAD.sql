CREATE OR REPLACE FORCE VIEW sa.table_win_head (objid,dlg_id,ver_clarify,ver_customer,"PRELOAD",dlg_time_stamp) AS
select table_rc_config.objid, table_window_db.id,
 table_window_db.ver_clarify, table_window_db.ver_customer,
 table_window_db.preload, table_window_db.dlg_time_stamp
 from mtm_window_db4_rc_config1, table_rc_config, table_window_db
 where table_window_db.objid = mtm_window_db4_rc_config1.window_db2rc_config
 AND mtm_window_db4_rc_config1.rc_config2window_db = table_rc_config.objid 
 ;
COMMENT ON TABLE sa.table_win_head IS 'Gets the rescources for a window_db object. Used by from Propagate Contextual Objects (10057)';
COMMENT ON COLUMN sa.table_win_head.objid IS 'Rc_config objid';
COMMENT ON COLUMN sa.table_win_head.dlg_id IS 'Form ID';
COMMENT ON COLUMN sa.table_win_head.ver_clarify IS 'Clarify version of the form';
COMMENT ON COLUMN sa.table_win_head.ver_customer IS 'Customer version of the form';
COMMENT ON COLUMN sa.table_win_head."PRELOAD" IS 'Concatenation of form resources to be cached';
COMMENT ON COLUMN sa.table_win_head.dlg_time_stamp IS 'Window_db timestamp';