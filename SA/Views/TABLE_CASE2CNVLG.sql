CREATE OR REPLACE FORCE VIEW sa.table_case2cnvlg (case_id,creation_time,stop_time,objid,phone_objid) AS
select table_act_entry.act_entry2case, table_phone_log.creation_time,
 table_phone_log.stop_time, table_act_entry.objid,
 table_phone_log.objid
 from table_act_entry, table_phone_log
 where table_act_entry.act_entry2case IS NOT NULL
 AND table_phone_log.objid = table_act_entry.act_entry2phone_log
 ;
COMMENT ON TABLE sa.table_case2cnvlg IS 'View used to access case phone log start and stop times to calculate phone times for close case entry';
COMMENT ON COLUMN sa.table_case2cnvlg.case_id IS 'Case internal record number';
COMMENT ON COLUMN sa.table_case2cnvlg.creation_time IS 'Date and time the phone log entry was created';
COMMENT ON COLUMN sa.table_case2cnvlg.stop_time IS 'Date and time user hung up the phone';
COMMENT ON COLUMN sa.table_case2cnvlg.objid IS 'Act_entry internal record number';
COMMENT ON COLUMN sa.table_case2cnvlg.phone_objid IS 'Phone_log internal record number';