CREATE OR REPLACE FORCE VIEW sa.table_subcase2rsrch (subcase_id,creation_time,elapsed_time) AS
select table_act_entry.act_entry2subcase, table_resrch_log.creation_time,
 table_resrch_log.elapsed_time
 from table_act_entry, table_resrch_log
 where table_act_entry.act_entry2subcase IS NOT NULL
 AND table_resrch_log.objid = table_act_entry.act_entry2resrch_log
 ;
COMMENT ON TABLE sa.table_subcase2rsrch IS 'Information on research logs for a subcase.  Used to calculate research time on the close subcase form';
COMMENT ON COLUMN sa.table_subcase2rsrch.subcase_id IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_subcase2rsrch.creation_time IS 'Date and time the research log was created';
COMMENT ON COLUMN sa.table_subcase2rsrch.elapsed_time IS 'Total elapsed time spent doing research in seconds';