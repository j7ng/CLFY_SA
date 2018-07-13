CREATE OR REPLACE FORCE VIEW sa.table_case2rsrch (case_id,creation_time,elapsed_time,objid,resrch_objid) AS
select table_act_entry.act_entry2case, table_resrch_log.creation_time,
 table_resrch_log.elapsed_time, table_act_entry.objid,
 table_resrch_log.objid
 from table_act_entry, table_resrch_log
 where table_act_entry.act_entry2case IS NOT NULL
 AND table_resrch_log.objid = table_act_entry.act_entry2resrch_log
 ;
COMMENT ON TABLE sa.table_case2rsrch IS 'View used to access case research log times to calculate total research time for close case entry';
COMMENT ON COLUMN sa.table_case2rsrch.case_id IS 'Case object ID number';
COMMENT ON COLUMN sa.table_case2rsrch.creation_time IS 'Date and time the research log was created';
COMMENT ON COLUMN sa.table_case2rsrch.elapsed_time IS 'Elapsed time spent on research log item in seconds';
COMMENT ON COLUMN sa.table_case2rsrch.objid IS 'Act_entry internal record number';
COMMENT ON COLUMN sa.table_case2rsrch.resrch_objid IS 'Resrch_log internal record number';