CREATE OR REPLACE FORCE VIEW sa.table_list_drtime (detail_objid,onsite_objid,objid,labor_type,start_time,duration,billable,bill_to,wrk_center,technician,total_time,rate) AS
select table_onsite_log.detail_onsite2demand_dtl, table_onsite_log.objid,
 table_time_log.objid, table_time_log.time_type,
 table_time_log.start_time, table_time_log.duration,
 table_time_log.billable, table_time_log.bill_to,
 table_time_log.wrk_center, table_onsite_log.perf_by,
 table_onsite_log.total_time, table_time_log.rate
 from table_onsite_log, table_time_log
 where table_onsite_log.detail_onsite2demand_dtl IS NOT NULL
 AND table_onsite_log.objid = table_time_log.time2onsite_log
 ;
COMMENT ON TABLE sa.table_list_drtime IS 'Used by form Depot Repair (8410)';
COMMENT ON COLUMN sa.table_list_drtime.detail_objid IS 'Demand Detail internal record number';
COMMENT ON COLUMN sa.table_list_drtime.onsite_objid IS 'Onsite_log internal record number';
COMMENT ON COLUMN sa.table_list_drtime.objid IS 'Time_log internal record number';
COMMENT ON COLUMN sa.table_list_drtime.labor_type IS 'Type of time; defined as a user-defined pop up list. Default list name is TIME_TYPE';
COMMENT ON COLUMN sa.table_list_drtime.start_time IS 'Start time of activity';
COMMENT ON COLUMN sa.table_list_drtime.duration IS 'Total elapsed time spent accomplishing task in seconds';
COMMENT ON COLUMN sa.table_list_drtime.billable IS 'Indicates whether the line item is considered billable; i.e., 0=non-billable, 1=billable';
COMMENT ON COLUMN sa.table_list_drtime.bill_to IS 'Organization, department, group to which the line item is to be billed';
COMMENT ON COLUMN sa.table_list_drtime.wrk_center IS 'Work Center where time activity took place';
COMMENT ON COLUMN sa.table_list_drtime.technician IS 'Login name of the technician that performed the work';
COMMENT ON COLUMN sa.table_list_drtime.total_time IS 'Total time, both billable and non-billable';
COMMENT ON COLUMN sa.table_list_drtime.rate IS 'Currency rate to be applied to the labor time';