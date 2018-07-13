CREATE OR REPLACE FORCE VIEW sa.table_onsite_select (objid,creation_time,perf_by,billable_time,non_bill_time,billable_exp,non_bill_exp,total_time,total_exp,case_objid) AS
select table_onsite_log.objid, table_onsite_log.creation_time,
 table_onsite_log.perf_by, table_onsite_log.billable_time,
 table_onsite_log.non_bill_time, table_onsite_log.billable_exp,
 table_onsite_log.non_bill_exp, table_onsite_log.total_time,
 table_onsite_log.total_exp, table_onsite_log.case_onsite2case
 from table_onsite_log
 where table_onsite_log.case_onsite2case IS NOT NULL
 ;
COMMENT ON TABLE sa.table_onsite_select IS 'Related TandE log for case. Used by form Select Time and Expense Logs (434)';
COMMENT ON COLUMN sa.table_onsite_select.objid IS 'Onsite log internal record number';
COMMENT ON COLUMN sa.table_onsite_select.creation_time IS 'Date and time the T&E log was created';
COMMENT ON COLUMN sa.table_onsite_select.perf_by IS 'Login name of the Person that performs the T&E task';
COMMENT ON COLUMN sa.table_onsite_select.billable_time IS 'Total T&E log time that is billable in seconds';
COMMENT ON COLUMN sa.table_onsite_select.non_bill_time IS 'Total T&E log time that is not billable in seconds';
COMMENT ON COLUMN sa.table_onsite_select.billable_exp IS 'Total T&E log expenses that are billable';
COMMENT ON COLUMN sa.table_onsite_select.non_bill_exp IS 'Total T&E log expenses that are not billable';
COMMENT ON COLUMN sa.table_onsite_select.total_time IS 'Total time, both billable and non-billable';
COMMENT ON COLUMN sa.table_onsite_select.total_exp IS 'Total non-billable and billable expenses';
COMMENT ON COLUMN sa.table_onsite_select.case_objid IS 'Case internal record number';