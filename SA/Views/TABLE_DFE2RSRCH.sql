CREATE OR REPLACE FORCE VIEW sa.table_dfe2rsrch (dfe_id,creation_time,elapsed_time) AS
select table_disptchfe.objid, table_resrch_log.creation_time,
 table_resrch_log.elapsed_time
 from table_disptchfe, table_resrch_log, table_act_entry
 where table_resrch_log.objid = table_act_entry.act_entry2resrch_log
 ;
COMMENT ON TABLE sa.table_dfe2rsrch IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_dfe2rsrch.dfe_id IS 'Disptchfe internal record number';
COMMENT ON COLUMN sa.table_dfe2rsrch.creation_time IS 'Date and time research log was created';
COMMENT ON COLUMN sa.table_dfe2rsrch.elapsed_time IS 'Total elapsed time spent doing research in seconds';