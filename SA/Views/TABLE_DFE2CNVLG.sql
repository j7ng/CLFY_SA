CREATE OR REPLACE FORCE VIEW sa.table_dfe2cnvlg (dfe_id,creation_time,stop_time) AS
select table_disptchfe.objid, table_phone_log.creation_time,
 table_phone_log.stop_time
 from table_disptchfe, table_phone_log, table_act_entry
 where table_phone_log.objid = table_act_entry.act_entry2phone_log
 ;
COMMENT ON TABLE sa.table_dfe2cnvlg IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_dfe2cnvlg.dfe_id IS 'Disptchfe internal record number';
COMMENT ON COLUMN sa.table_dfe2cnvlg.creation_time IS 'Date and time the phone log entry was created';
COMMENT ON COLUMN sa.table_dfe2cnvlg.stop_time IS 'Date and time user hung up the phone';