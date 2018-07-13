CREATE OR REPLACE FORCE VIEW sa.table_win_init (objid,dlg_id,ver_clarify,ver_customer,"PRELOAD",dlg_time_stamp) AS
select table_rc_config.objid, table_window_db.id,
 table_window_db.ver_clarify, table_window_db.ver_customer,
 table_window_db.preload, table_window_db.dlg_time_stamp
 from mtm_window_db5_rc_config2, table_rc_config, table_window_db
 where table_window_db.objid = mtm_window_db5_rc_config2.window_db2rc_init
 AND mtm_window_db5_rc_config2.rc_init2window_db = table_rc_config.objid 
 ;
COMMENT ON TABLE sa.table_win_init IS 'Gets the preloaded fields for a window_db object';
COMMENT ON COLUMN sa.table_win_init.objid IS 'Rc_config objid';
COMMENT ON COLUMN sa.table_win_init.dlg_id IS 'Form ID';
COMMENT ON COLUMN sa.table_win_init.ver_clarify IS 'Clarify version of the form';
COMMENT ON COLUMN sa.table_win_init.ver_customer IS 'Customer version of the form';
COMMENT ON COLUMN sa.table_win_init."PRELOAD" IS 'Concatination of form resources to be cached';
COMMENT ON COLUMN sa.table_win_init.dlg_time_stamp IS 'Window_db timestamp';