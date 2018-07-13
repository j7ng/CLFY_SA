CREATE OR REPLACE FORCE VIEW sa.table_exch_alst (entry_time,act_code,add_info,login_name,s_login_name,exchange_objid,exch_log_objid,objid,act_name,s_act_name) AS
select table_act_entry.entry_time, table_act_entry.act_code,
 table_act_entry.addnl_info, table_user.login_name, table_user.S_login_name,
 table_act_entry.act_entry2exchange, table_act_entry.act_entry2exch_log,
 table_act_entry.objid, table_gbst_elm.title, table_gbst_elm.S_title
 from table_act_entry, table_user, table_gbst_elm
 where table_gbst_elm.objid = table_act_entry.entry_name2gbst_elm
 AND table_user.objid = table_act_entry.act_entry2user
 ;
COMMENT ON TABLE sa.table_exch_alst IS 'Feed Exchange and Exchange Log activity log displays. Used by forms e.link Exchange Log (8887), e.link Partner Selection (8888) and e.link Service Level Agreements (8889)';
COMMENT ON COLUMN sa.table_exch_alst.entry_time IS 'Date and time of entry into activity log';
COMMENT ON COLUMN sa.table_exch_alst.act_code IS 'Activity code for the activity log entry; internally assigned with a unique code for each type of activity';
COMMENT ON COLUMN sa.table_exch_alst.add_info IS 'Additional information about activity log entry';
COMMENT ON COLUMN sa.table_exch_alst.login_name IS 'Login name of user that made activity log entry';
COMMENT ON COLUMN sa.table_exch_alst.exchange_objid IS 'Exchange object internal record number';
COMMENT ON COLUMN sa.table_exch_alst.exch_log_objid IS 'Exch_log internal record number';
COMMENT ON COLUMN sa.table_exch_alst.objid IS 'Act entry internal record number';
COMMENT ON COLUMN sa.table_exch_alst.act_name IS 'Name of activity';