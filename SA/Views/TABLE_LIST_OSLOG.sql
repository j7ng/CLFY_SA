CREATE OR REPLACE FORCE VIEW sa.table_list_oslog (dfe_objid,elm_objid,creation_time,perf_by,total_time,total_exp) AS
select table_onsite_log.disfe_onsit2disptchfe, table_onsite_log.objid,
 table_onsite_log.creation_time, table_onsite_log.perf_by,
 table_onsite_log.total_time, table_onsite_log.total_exp
 from table_onsite_log
 where table_onsite_log.disfe_onsit2disptchfe IS NOT NULL
 ;
COMMENT ON TABLE sa.table_list_oslog IS 'Used by form Dispatch Engineer (452), Previous TandE Logs (453)';
COMMENT ON COLUMN sa.table_list_oslog.dfe_objid IS 'Disptchfe internal record number';
COMMENT ON COLUMN sa.table_list_oslog.elm_objid IS 'Onsite log internal record number';
COMMENT ON COLUMN sa.table_list_oslog.creation_time IS 'Date and time the T&E log was created';
COMMENT ON COLUMN sa.table_list_oslog.perf_by IS 'Login name of the Person that performs the T&E task';
COMMENT ON COLUMN sa.table_list_oslog.total_time IS 'Total time, both billable and non-billable';
COMMENT ON COLUMN sa.table_list_oslog.total_exp IS 'Total non-billable and billable expenses';