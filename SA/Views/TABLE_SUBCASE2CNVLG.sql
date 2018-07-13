CREATE OR REPLACE FORCE VIEW sa.table_subcase2cnvlg (subcase_id,creation_time,stop_time) AS
select table_act_entry.act_entry2subcase, table_phone_log.creation_time,
 table_phone_log.stop_time
 from table_act_entry, table_phone_log
 where table_act_entry.act_entry2subcase IS NOT NULL
 AND table_phone_log.objid = table_act_entry.act_entry2phone_log
 ;
COMMENT ON TABLE sa.table_subcase2cnvlg IS 'Subcase for which activity is recorded';
COMMENT ON COLUMN sa.table_subcase2cnvlg.subcase_id IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_subcase2cnvlg.creation_time IS 'Date and time the phone log entry was created';
COMMENT ON COLUMN sa.table_subcase2cnvlg.stop_time IS 'Date and time user hung up the phone';